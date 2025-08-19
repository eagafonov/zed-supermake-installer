all: zed.app link

ARCH:=$(shell uname -m)
LOCAL_BIN:=$(shell readlink -f ~/.local/bin)

TARBALL:=zed-linux-${ARCH}.tar.gz

force:
	rm -f ${TARBALL}
	rm -rf zed.app

download: ${TARBALL}
unpack: zed.app
link: $(LOCAL_BIN)/zed

${TARBALL}:
	wget https://zed.dev/api/releases/stable/latest/zed-linux-${ARCH}.tar.gz -O $@.tmp || (rm -f $@.tmp && exit 1)
	mv $@.tmp $@

zed.app: ${TARBALL}
	tar -xf $<
	touch $@/.nobackup

$(LOCAL_BIN)/zed: zed.app
	test -d "${LOCAL_BIN}"
	ln -fs $(shell pwd)/zed.app/bin/zed ${LOCAL_BIN}
