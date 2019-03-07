if [ $# -eq 0 ]; then
	BIN='tests/test-progs/hello/bin/arm/linux/hello'
else
	BIN=$1
fi

if [ $# -eq 2 ]; then
        OUT=$2
else
        OUT='m5out'
fi

build/ARM/gem5.opt -d "$OUT" configs/example/se.py \
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
	--sys-clock=1600MHz \
	--cpu-type=MinorCPU \
	--cmd "$BIN"
