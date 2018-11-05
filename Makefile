MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := "$(dir $(MKFILE_PATH))"

UID  := $(shell id -u $(USER))
GID  := $(shell id -u $(USER))

BUILDROOT_DIR=buildroot
BUILDROOT_DEFCONFIG=qemu_x86_defconfig
#BUILDROOT_DEFCONFIG=raspberrypi3_qt5we_defconfig

#BUILDROOT_URL=https://github.com/buildroot/buildroot/archive/master.tar.gz
BUILDROOT_URL=https://buildroot.org/downloads/buildroot-2018.08.2.tar.gz

docker-build:
	docker build -t buildroot-builder .

run:	docker-build
	docker run \
	-v $(MKFILE_DIR):/br \
	-w /br \
	-u $(UID):$(GID) \
	-ti buildroot-builder
	
get:
	wget --no-check-certificate -qO- $(BUILDROOT_URL) | tar xvfz -
	ln -s buildroot-* buildroot

build:	get
	cd $(BUILDROOT_DIR) && \
	make $(BUILDROOT_DEFCONFIG) && \
	time make

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
	rm -rf buildroot-*
