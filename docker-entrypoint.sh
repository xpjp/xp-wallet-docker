#!/usr/bin/env bash

# if command starts with an option, prepend XPd
if [ "${1:0:1}" = '-' ]; then
	set -- XPd "$@"
fi

#FILEID="1uKV7vd4FTm457rG9CoUPzZgP2j4W_TYd"
FILEID="1DZx3mzj81MYwV1QXtGXTEQ-1CXFfaHUX"
ZIP_TEMP_FILE=bootstrap.zip
ZIP_TEMP_DIR=ziptemp

_init_datafiles() {
	echo "Initializing data files..."
	XPd --printtoconsole | while read i
	do
		echo $i
		echo $i | grep -q 'ThreadDNSAddressSeed exited'
		if [ $? = "0" ]; then
			kill -TERM $(pidof XPd)
			break
		fi
	done
	echo "done"
}

_download_from_gdrive() {
	echo "Downloading bootstrap..."
	curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=$1" > /dev/null
	local download_code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
	curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${download_code}&id=$1" -o $2
	echo "done"
}

_download_from_dropbox() {
	echo "Downloading bootstrap..."
	curl -Ls "https://www.dropbox.com/s/wz8sg14ujmx1dnm/xpcoin-bootstrap-peers.zip?dl=0" -o $1
	echo "done"
}

_download_from_conoha() {
	echo "Downloading bootstrap..."
	curl -Ls "https://object-storage.tyo1.conoha.io/v1/nc_c17ae3d951a84d7ba2a9d28bf2bbfbd7/XPbootstrap/xpcoin-bootstrap-peers.zip" -o $1
	echo "done"
}

_deploy_bootstrap() {
	echo "Extracting bootstrap..."
	if [ -d ${XPD_DATA_DIR}/database ]; then
		rm -f ${XPD_DATA_DIR}/database/*
	else
		mkdir -p ${XPD_DATA_DIR}/database
	fi
	rm -fr $2/*
	unzip -d $2 $1
	for CONTENT_FILE in $(find ${2} -type f -and -not -name readme.txt -and -not -name xpcoin-startkit_v1.0.bat -and -not -name wallet.dat)
	do
		mv ${CONTENT_FILE} ${XPD_DATA_DIR}/$(echo ${CONTENT_FILE} | sed -r 's/^([^\/]*\/){2}//')
	done
	rm -fr $2
	rm -f $1
	echo "done"
}

_update_init_node() {
	echo "Updating XPd initial nodes..."
	sed -i -e '/^addnode/d' ${XPD_DATA_DIR}/XP.conf
	cat << EOS >> ${XPD_DATA_DIR}/XP.conf
addnode=45.32.45.43
addnode=45.77.2.104
addnode=45.63.94.41
addnode=45.32.220.209
addnode=45.63.65.48
addnode=45.77.107.76
addnode=45.32.175.194
EOS
    echo "done"
}

if [ ! -d ${XPD_DATA_DIR}/database ]; then
	_init_datafiles
	_download_from_conoha bootstrap-latest.zip
	_deploy_bootstrap bootstrap-latest.zip ziptemp
	_update_init_node
fi

exec "$@"
