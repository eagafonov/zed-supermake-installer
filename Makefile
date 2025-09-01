.PHONY: all purge download unpack link releases latest refresh

all: zed.app link

ARCH:=$(shell uname -m)
LOCAL_BIN:=$(shell readlink -f ~/.local/bin)

LATEST_RELEASE:=$(shell jq -r .tag_name latest.json 2> /dev/null)

TARBALL_LATEST:=zed-linux-${ARCH}.tar.gz

TARBALL:=zed-linux-${ARCH}-${LATEST_RELEASE}.tar.gz

purge:
	rm -f ${TARBALL}
	rm -rf zed.app

download: ${TARBALL}
unpack: ${LATEST_RELEASE}/zed.app
link: $(LOCAL_BIN)/zed

${TARBALL}:
	@test -n "${LATEST_RELEASE}" || (echo "LATEST_RELEASE is empty. run 'make refresh' to fetch releases" && exit 1)
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

# Get releases from GitHub
releases.json:
	curl -s https://api.github.com/repos/zed-industries/zed/releases | jq " . | map(select(.prerelease == false))" > $@.tmp
	mv $@.tmp $@

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
