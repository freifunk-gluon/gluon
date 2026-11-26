#!/usr/bin/env python3
"""Test rig: run Gluon mesh tests against an x86-64 image.

Tests live next to the package they exercise, in
package/<package>/tests/*.py. A test runs when its own package is
installed on the image, plus any extra packages it declares in a
'# requires: <package>...' comment line, where 'a|b' means either name
will do. The installed set is read from a booted node, so the image
itself decides which tests apply.

Each test runs in its own process (pynet keeps global state), pynet
slot and tests/run/<test>/ directory; two run at a time by default.

    ./run.py --image ../output/.../gluon-*-x86-64.img.gz -j 2
"""

import argparse
import concurrent.futures
import glob
import gzip
import os
import queue
import re
import shutil
import subprocess
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(BASE)


MARKER = '.gluon_tests'


def discover_tests():
    """Tests from gluon's own packages and every checked-out feed
    (including GLUON_SITE_FEEDS). Only directories with a .gluon_tests
    marker count; upstream packages ship unrelated tests/ directories."""
    paths = set()
    for pattern in (os.path.join(ROOT, 'package', '**', MARKER),
                    os.path.join(ROOT, 'packages', '**', MARKER)):
        for marker in glob.glob(pattern, recursive=True):
            tests = glob.glob(os.path.join(os.path.dirname(marker), '*.py'))
            paths.update(os.path.abspath(p) for p in tests)
    return sorted(paths)


def prepare_image(path):
    """Accept a .img or a .img.gz; a gzipped image is unpacked next to
    the archive and reused while it stays newer than it."""
    if not path.endswith('.gz'):
        return path

    unpacked = path[:-3]
    if (not os.path.exists(unpacked)
            or os.path.getmtime(unpacked) < os.path.getmtime(path)):
        print('unpacking %s' % path, flush=True)
        with gzip.open(path, 'rb') as src, open(unpacked, 'wb') as dst:
            shutil.copyfileobj(src, dst)
    return unpacked


def required_packages(path):
    """Packages a test needs: the one owning it, plus its '# requires:'.
    Each entry is a set of alternatives ('new-name|old-name'); naming
    the owning package in one replaces the implicit requirement."""
    owner = os.path.basename(os.path.dirname(os.path.dirname(path)))
    declared = []
    with open(path) as f:
        for line in f:
            match = re.match(r'#\s*requires:\s*(.+)', line)
            if match:
                declared = [set(token.split('|'))
                            for token in match.group(1).split()]
                break

    if any(owner in alternatives for alternatives in declared):
        return declared
    return [{owner}] + declared


def installed_packages(env, image):
    """The packages the image has installed, from a '<image>.packages'
    cache next to it, or by booting a node when that is missing or older
    than the image."""
    cache = image + '.packages'
    if (os.path.exists(cache)
            and os.path.getmtime(cache) >= os.path.getmtime(image)):
        with open(cache) as f:
            tokens = f.read().split()
        print('using cached package list %s' % cache, flush=True)
        return expand_package_names(tokens)

    tokens = probe_packages(env)
    with open(cache, 'w') as f:
        f.write('\n'.join(tokens) + '\n')
    print('cached package list to %s' % cache, flush=True)
    return expand_package_names(tokens)


def expand_package_names(tokens):
    """apk reports "name-1.2-r3"; index both the full token and the name."""
    packages = set()
    for token in tokens:
        token = token.strip()
        if token:
            packages.add(token)
            packages.add(re.sub(r'-\d[^-]*(-r\d+)?$', '', token))
    return packages


def probe_packages(env):
    """Boot a node and report what it has installed."""
    print('probing image for installed packages', flush=True)
    workdir = os.path.join(BASE, 'run', '.probe')
    shutil.rmtree(workdir, ignore_errors=True)
    os.makedirs(workdir)
    result = subprocess.run(
        [sys.executable, '-u', os.path.join(BASE, 'probe_packages.py')],
        cwd=workdir, env=dict(env, PYNET_SLOT='0'),
        capture_output=True, text=True)

    if result.returncode != 0:
        sys.exit('probing the image failed:\n'
            + result.stdout[-2000:] + result.stderr[-2000:])

    lines = result.stdout.splitlines()
    try:
        marker = lines.index('--- packages ---')
    except ValueError:
        sys.exit('probe produced no package list:\n' + result.stdout[-2000:])

    tokens = [line.strip() for line in lines[marker + 1:] if line.strip()]
    print('image has %d packages' % len(tokens), flush=True)
    return tokens


def print_log(path, lines=200):
    """Print a failing test's output, indented. The node consoles stay
    in the test's directory."""
    try:
        with open(path, errors='replace') as f:
            content = f.read().splitlines()
    except OSError as err:
        print('    (no output: %s)' % err, flush=True)
        return

    if not content:
        print('    (no output)', flush=True)
        return

    if len(content) > lines:
        print('    ... %d earlier lines, see %s'
            % (len(content) - lines, path))
        content = content[-lines:]
    for line in content:
        print('    | ' + line)
    print(flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--image', default=os.environ.get('GLUON_IMAGE', 'image.img'),
        help='firmware image, .img or .img.gz'
        ' (default: $GLUON_IMAGE or ./image.img)')
    parser.add_argument('-j', '--jobs', type=int, default=2,
                        help='tests to run concurrently (default: 2, max 8)')
    parser.add_argument('--all', action='store_true',
                        help='skip the probe and run every test')
    parser.add_argument('tests', nargs='*',
                        help='test names or paths (default: all applicable)')
    args = parser.parse_args()

    if not 1 <= args.jobs <= 8:
        parser.error('--jobs must be 1..8')

    available = discover_tests()

    if args.tests:
        paths = []
        for name in args.tests:
            matches = [
                p for p in available
                if os.path.splitext(os.path.basename(p))[0] == name
                or p == os.path.abspath(name)]
            if not matches and os.path.isfile(name):
                matches = [os.path.abspath(name)]
            if not matches:
                parser.error('no such test: ' + name)
            paths += matches
    else:
        paths = available

    image = os.path.abspath(prepare_image(args.image))
    env = dict(
        os.environ, GLUON_IMAGE=image,
        PYTHONPATH=BASE + os.pathsep + os.environ.get('PYTHONPATH', ''))

    todo = []
    if args.all:
        todo = [(os.path.splitext(os.path.basename(p))[0], p) for p in paths]
    else:
        packages = installed_packages(env, image)
        for path in paths:
            name = os.path.splitext(os.path.basename(path))[0]
            missing = [
                alternatives for alternatives in required_packages(path)
                if not alternatives & packages]
            if missing:
                lacks = ' '.join('|'.join(sorted(a)) for a in missing)
                print('~~~ %s: skipped (%s not installed)'
                    % (name, lacks), flush=True)
                continue
            todo.append((name, path))

    # A slot shifts the host ports pynet binds; the directory keeps
    # images, logs and ssh keys apart.
    slots = queue.Queue()
    for slot in range(args.jobs):
        slots.put(slot)

    def run_test(name, path):
        slot = slots.get()
        try:
            workdir = os.path.join(BASE, 'run', name)
            shutil.rmtree(workdir, ignore_errors=True)
            os.makedirs(workdir)
            logfile = os.path.join(workdir, 'test.log')
            with open(logfile, 'wb') as log:
                rc = subprocess.run([sys.executable, '-u', path], cwd=workdir,
                                    env=dict(env, PYNET_SLOT=str(slot)),
                                    stdout=log, stderr=subprocess.STDOUT).returncode
            return name, rc, logfile
        finally:
            slots.put(slot)

    print('running %d tests, %d at a time' % (len(todo), args.jobs), flush=True)
    failed = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = [pool.submit(run_test, name, path) for name, path in todo]
        for future in concurrent.futures.as_completed(futures):
            name, rc, logfile = future.result()
            if rc != 0:
                print('!!! %s: FAILED, node logs in %s'
                    % (name, os.path.join(os.path.dirname(logfile), 'logs')),
                    flush=True)
                print_log(logfile)
                failed.append(name)
            else:
                print('=== %s: ok' % name, flush=True)

    if failed:
        print('failed tests: ' + ' '.join(failed))
        sys.exit(1)


if __name__ == '__main__':
    main()
