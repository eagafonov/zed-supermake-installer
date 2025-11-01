.PHONY: all purge download unpack link releases latest refresh

all: zed.app link

ARCH:=$(shell uname -m)
LOCAL_BIN:=$(shell readlink -f ~/.local/bin)
DOWNLOADS_DIR:=downloads

LATEST_RELEASE:=$(shell jq -r .tag_name latest.json 2> /dev/null)

TARBALL_LATEST:=zed-linux-${ARCH}.tar.gz

TARBALL:=${DOWNLOADS_DIR}/zed-linux-${ARCH}-${LATEST_RELEASE}.tar.gz

purge:
	rm -rf ${DOWNLOADS_DIR}/*.tar.gz
	rm -rf zed.app

download: ${TARBALL}
unpack: ${LATEST_RELEASE}/zed.app
link: $(LOCAL_BIN)/zed

${TARBALL}:
	@test -n "${LATEST_RELEASE}" || (echo "LATEST_RELEASE is empty. run 'make refresh' to fetch releases" && exit 1)
	mkdir -p ${DOWNLOADS_DIR}
	wget https://github.com/zed-industries/zed/releases/download/${LATEST_RELEASE}/zed-linux-${ARCH}.tar.gz -O $@.tmp || (rm -f $@.tmp && exit 1)
	mv $@.tmp $@

zed.app: ${LATEST_RELEASE}/zed.app
	ln -fs ${LATEST_RELEASE}/zed.app zed.app

${LATEST_RELEASE}/zed.app: ${TARBALL}
	mkdir -p ${LATEST_RELEASE}
	touch ${LATEST_RELEASE}/.nobackup
	tar -C ${LATEST_RELEASE} -xf ${TARBALL}
	# zed.app is part of archive, so make sure it's newer than tarball
	test -d $@ && touch $@

$(LOCAL_BIN)/zed: zed.app
	test -d "${LOCAL_BIN}"
	ln -fs $(shell pwd)/zed.app/bin/zed ${LOCAL_BIN}

GITHUB_TOKEN?=
AUTH_ARGS:=

ifneq ("${GITHUB_TOKEN}", "")
	AUTH_ARGS:=-H "Authorization: Bearer ${GITHUB_TOKEN}"
endif

# Get releases from GitHub
releases.json:
	curl --fail -s ${AUTH_ARGS} https://api.github.com/repos/zed-industries/zed/releases > .releases.json
	jq " . | map(select(.prerelease == false))" .releases.json > $@.tmp
	mv $@.tmp $@
	rm -f .releases.json

latest.json: releases.json
	jq -r " . | map(select(.prerelease == false)) | .[0]" releases.json > $@.tmp
	mv $@.tmp $@

releases: releases.json
	@jq -r .[].tag_name releases.json

latest: latest.json
	@jq -r .tag_name latest.json

refresh::
	@-rm -f *.json
refresh:: latest
