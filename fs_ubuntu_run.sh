./build/ARM/gem5.opt --remote-gdb-port=0 \
	-d test_fs \
	configs/example/fs.py \
	--kernel=vmlinux \
	--machine-type=VExpress_GEM5_V1 \
	--dtb-file=armv8_gem5_v1_4cpu.dtb \
	--disk-image=gem5_base.img \
	-n 4 \
	--cpu-clock=2GHz \
	--caches \
	--l2cache \
	--l1i_size=32kB \
	--l1d_size=32kB \
	--l2_size=1MB \
	--l2_assoc=2 \
	--mem-type=DDR4_2400_4x16 \
	--mem-ranks=4 \
	--mem-size=4GB \
	--sys-clock=1600MHz
	