MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))

BUILDROOT_DIR=buildroot-master
BUILDROOT_DEFCONFIG=qemu_x86_defconfig
#BUILDROOT_DEFCONFIG=raspberrypi3_qt5we_defconfig

docker:
	docker run -v $(MKFILE_DIR):/br -w /br -ti sublimino/debian-build-essential

dep:
	apt update -y && \
	apt install -y git build-essential wget unzip time file cpio python bc rsync

get:	dep
	wget --no-check-certificate -qO- https://github.com/buildroot/buildroot/archive/master.tar.gz | tar xvfz -

build:	get
	cd $(BUILDROOT_DIR) && \
	make $(BUILDROOT_DEFCONFIG) && \
	time make -j

qemu:
	qemu-system-i386 \
	-enable-kvm \
	-M pc \
	-m 512 \
	-kernel $(BUILDROOT_DIR)/output/images/bzImage \
	-drive file=$(BUILDROOT_DIR)/output/images/rootfs.ext2,if=virtio,format=raw \
	-append root=/dev/vda \
	-net nic,model=virtio \
	-net user

clean:
	rm -rf buildroot-master
