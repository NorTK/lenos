.PHONY: build-live build-disk clean distclean test-live test-disk
version=0.1.0

build-live:
	-setenforce 0
	kiwi-ng --profile=Live system build --description=. --target-dir=result-live/
	-setenforce 1

build-disk:
	-setenforce 0
	kiwi-ng --profile=Disk system build --description=. --target-dir=result-disk/
	-setenforce 1

test-live:
	qemu-kvm -enable-kvm -machine pc,vmport=off -cpu host -smp 4 -m 8192 -bios /usr/share/edk2/ovmf/OVMF_CODE.fd -drive file=result-live/TacOS.x86_64-$(version).iso,media=cdrom -nic user,hostfwd=tcp::2222-:22 -usb -device usb-tablet

test-disk:
	qemu-img create -f qcow2 test-disk.qcow2 20G
	cp /usr/share/edk2/ovmf/OVMF_VARS.fd test-vars.fd
	-qemu-kvm -enable-kvm -machine pc,vmport=off -cpu host -smp 4 -m 8192 \
		-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2/ovmf/OVMF_CODE.fd,readonly=on \
		-drive if=pflash,format=raw,unit=1,file=test-vars.fd \
		-drive file=test-disk.qcow2,if=none,id=drive0,format=qcow2 \
		-device virtio-blk-pci,drive=drive0,bootindex=0 \
		-drive file=result-disk/TacOS.x86_64-$(version).install.iso,if=none,id=drive1,media=cdrom,readonly=on \
		-device ide-cd,drive=drive1,bootindex=1 \
		-nic user,hostfwd=tcp::2222-:22 -usb -device usb-tablet -boot menu=on
	rm -f test-disk.qcow2 test-vars.fd

clean:
	sudo rm -fr result-live/build/image-root*
	sudo rm -f result-live/TacOS*
	sudo rm -fr result-disk/build/image-root*
	sudo rm -f result-disk/TacOS*
	rm -f *.qcow2 test-vars.fd


distclean:
	rm -fr result-*
