BUILDROOT_DIR=buildroot-master
BUILDROOT_DEFCONFIG=qemu_x86_defconfig
#BUILDROOT_DEFCONFIG=raspberrypi3_qt5we_defconfig

dep-add:
	sudo apk add perl bc rsync

dep-apk:
	sudo apt install perl bc rsync

get:
	wget -qc https://github.com/buildroot/buildroot/archive/master.zip 
	unzip -o master.zip

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
	rm -rf buildroot-master master.zip
