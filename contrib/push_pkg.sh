#!/bin/sh

set -e

topdir="$(realpath "$(dirname "${0}")/../openwrt")"

# defaults to qemu run script
ssh_host=localhost
build_only=0
preserve_config=1

print_help() {
	echo "$0 [OPTIONS] PACKAGE_DIR [PACKAGE_DIR] ..."
	echo ""
	echo " -h          print this help"
	echo " -r HOST     use a remote machine as target machine. By default if this"
	echo "             option is not given, push_pkg.sh will use a locally"
	echo "             running qemu instance started by run_qemu.sh."
	echo " -p PORT     use PORT as ssh port (default is 22)"
	echo " -b          build only, do not push"
	echo " -P          do not preserve /etc/config. By default, if a package"
	echo "             defines a config file in /etc/config, this config file"
	echo "             will be preserved. If you specify this flag, the package"
	echo "             default will be installed instead."
	echo ""
	echo ' To change gluon variables, run e.g. "make config GLUON_MINIFY=0"'
	echo ' because then the gluon logic will be triggered, and openwrt/.config'
	echo ' will be regenerated. The variables from openwrt/.config are already'
	echo ' automatically used for this script.'
	echo
}

while getopts "p:r:hbP" opt
do
	case $opt in
		P) preserve_config=0;;
		p) ssh_port="${OPTARG}";;
		r) ssh_host="${OPTARG}"; [ -z "$ssh_port" ] && ssh_port=22;;
		b) build_only=1;;
		h) print_help; exit 0;;
		*) ;;
	esac
done
shift $(( OPTIND - 1 ))

[ -z "$ssh_port" ] && ssh_port=2223

if [ "$build_only" -eq 0 ]; then
	remote_info=$(ssh -p "${ssh_port}" "root@${ssh_host}" '
		source /etc/os-release
		printf "%s\\t%s\\n" "$OPENWRT_BOARD" "$OPENWRT_ARCH"
	')
	REMOTE_OPENWRT_BOARD="$(echo "$remote_info" | cut -f 1)"
	REMOTE_OPENWRT_ARCH="$(echo "$remote_info" | cut -f 2)"

	# check target
	if ! grep -q "CONFIG_TARGET_ARCH_PACKAGES=\"${REMOTE_OPENWRT_ARCH}\"" "${topdir}/.config"; then
		echo "Configured OpenWrt Target is not matching with the target machine!" 1>&2
		echo
		printf "%s" "    Configured architecture: " 1>&2
		grep "CONFIG_TARGET_ARCH_PACKAGES" "${topdir}/.config" 1>&2
		echo "Target machine architecture: ${REMOTE_OPENWRT_ARCH}" 1>&2
		echo 1>&2
		echo "To switch the local with the run with the corresponding GLUON_TARGET:"  1>&2
		echo "  make GLUON_TARGET=... config" 1>&2
		exit 1
	fi
fi

if [ $# -lt 1 ]; then
	echo ERROR: Please specify a PACKAGE_DIR. For example:
	echo
	echo " \$ $0 package/gluon-core"
	exit 1
fi

while [ $# -gt 0 ]; do

	pkgdir="$1"; shift
	echo "Package: ${pkgdir}"

	if ! [ -f "${pkgdir}/Makefile" ]; then
		echo "ERROR: ${pkgdir} does not contain a Makefile"
		exit 1
	fi

	if ! grep -q BuildPackage "${pkgdir}/Makefile"; then
		echo "ERROR: ${pkgdir}/Makefile does not contain a BuildPackage command"
		exit 1
	fi

	opkg_packages="$(make TOPDIR="${topdir}" -C "${pkgdir}" DUMP=1 | awk '/^Package: / { print $2 }')"

	search_package() {
		find "$2" -name "$1_*.ipk" -printf '%f\n'
	}

	make TOPDIR="${topdir}" -C "${pkgdir}" clean
	make TOPDIR="${topdir}" -C "${pkgdir}" compile

	if [ "$build_only" -eq 1 ]; then
		continue
	fi

	# IPv6 addresses need brackets around the ${ssh_host} for scp!
	if echo "${ssh_host}" | grep -q :; then
		BL=[
		BR=]
	fi

	for pkg in ${opkg_packages}; do

		for feed in "${topdir}/bin/packages/${REMOTE_OPENWRT_ARCH}/"*/ "${topdir}/bin/targets/${REMOTE_OPENWRT_BOARD}/packages/"; do
			printf "%s" "searching ${pkg} in ${feed}: "
			filename=$(search_package "${pkg}" "${feed}")
			if [ -n "${filename}" ]; then
				echo found!
				break
			else
				echo not found
			fi
		done

		if [ "$preserve_config" -eq 0 ]; then
			opkg_flags=" --force-maintainer"
		fi

		# shellcheck disable=SC2029
		if [ -n "$filename" ]; then
			scp -O -P "${ssh_port}" "$feed/$filename" "root@${BL}${ssh_host}${BR}:/tmp/${filename}"
			ssh -p "${ssh_port}" "root@${ssh_host}" "
				set -e
				echo Running opkg:
				opkg install --force-reinstall ${opkg_flags} '/tmp/${filename}'
				rm '/tmp/${filename}'
				gluon-reconfigure
			"
		else
			# Some packages (e.g. procd-seccomp) seem to contain BuildPackage commands
			# which do not generate *.ipk files. Till this point, I am not aware why
			# this is happening. However, dropping a warning if the corresponding
			# *.ipk is not found (maybe due to other reasons as well), seems to
			# be more reasonable than aborting. Before this commit, the command
			# has failed.
			echo "Warning: ${pkg}*.ipk not found! Ignoring." 1>&2
		fi

	done
done
