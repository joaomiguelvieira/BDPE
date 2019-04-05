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
	--mem-type=DDR4_2400_4x16 \
	--mem-ranks=4 \
	--mem-size=4GB \
	--sys-clock=1600MHz \
	--cpu-type=TimingSimpleCPU \
	--cmd "$BIN"
