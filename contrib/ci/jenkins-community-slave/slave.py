from jenkins import Jenkins, JenkinsError, NodeLaunchMethod
import os
import signal
import sys
import urllib
import subprocess
import shutil
import requests
import time

slave_jar = '/var/lib/jenkins/slave.jar'
slave_name = os.environ['SLAVE_NAME'] if os.environ['SLAVE_NAME'] != '' else 'docker-slave-' + os.environ['HOSTNAME']
jnlp_url = os.environ['JENKINS_URL'] + '/computer/' + slave_name + '/slave-agent.jnlp'
slave_jar_url = os.environ['JENKINS_URL'] + '/jnlpJars/slave.jar'
print(slave_jar_url)
process = None

def clean_dir(dir):
    for root, dirs, files in os.walk(dir):
        for f in files:
            os.unlink(os.path.join(root, f))
        for d in dirs:
            shutil.rmtree(os.path.join(root, d))

def slave_create(node_name, working_dir, executors, labels):
    j = Jenkins(os.environ['JENKINS_URL'], os.environ['JENKINS_USER'], os.environ['JENKINS_PASS'])
    j.node_create(node_name, working_dir, num_executors = int(executors), labels = labels, launcher = NodeLaunchMethod.JNLP)

def slave_delete(node_name):
    j = Jenkins(os.environ['JENKINS_URL'], os.environ['JENKINS_USER'], os.environ['JENKINS_PASS'])
    j.node_delete(node_name)

def slave_download(target):
    if os.path.isfile(slave_jar):
        os.remove(slave_jar)

    loader = urllib.URLopener()
    loader.retrieve(os.environ['JENKINS_URL'] + '/jnlpJars/slave.jar', '/var/lib/jenkins/slave.jar')

def slave_run(slave_jar, jnlp_url):
    params = [ 'java', '-jar', slave_jar, '-jnlpUrl', jnlp_url ]
    if os.environ['JENKINS_SLAVE_ADDRESS'] != '':
        params.extend([ '-connectTo', os.environ['JENKINS_SLAVE_ADDRESS' ] ])

    if os.environ['SLAVE_SECRET'] == '':
        params.extend([ '-jnlpCredentials', os.environ['JENKINS_USER'] + ':' + os.environ['JENKINS_PASS'] ])
    else:
        params.extend([ '-secret', os.environ['SLAVE_SECRET'] ])
    return subprocess.Popen(params, stdout=subprocess.PIPE)

def signal_handler(sig, frame):
    if process != None:
        process.send_signal(signal.SIGINT)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def h():
    print("ERROR!: please specify environment variables")
    print("")
    print('docker run -e "SLAVE_NAME=test" -e "SLAVE_SECRET=..." jenkins')

if os.environ.get('SLAVE_NAME') is None:
    h()
    sys.exit(1)

if os.environ.get('SLAVE_SECRET') is None:
    h()
    sys.exit(1)

def master_ready(url):
    try:
        r = requests.head(url, verify=False, timeout=None)
        return r.status_code == requests.codes.ok
    except:
        return False

while not master_ready(slave_jar_url):
    print("Master not ready yet, sleeping for 10sec!")
    time.sleep(10)

slave_download(slave_jar)
print 'Downloaded Jenkins slave jar.'

if os.environ['SLAVE_WORING_DIR']:
    os.setcwd(os.environ['SLAVE_WORING_DIR'])

if os.environ['CLEAN_WORKING_DIR'] == 'true':
    clean_dir(os.getcwd())
    print "Cleaned up working directory."

if os.environ['SLAVE_NAME'] == '':
    slave_create(slave_name, os.getcwd(), os.environ['SLAVE_EXECUTORS'], os.environ['SLAVE_LABELS'])
    print 'Created temporary Jenkins slave.'

process = slave_run(slave_jar, jnlp_url)
print 'Started Jenkins slave with name "' + slave_name + '" and labels [' + os.environ['SLAVE_LABELS'] + '].'
process.wait()

print 'Jenkins slave stopped.'
if os.environ['SLAVE_NAME'] == '':
    slave_delete(slave_name)
    print 'Removed temporary Jenkins slave.'
