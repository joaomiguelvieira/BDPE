import numpy
import argparse
import time
from tqdm import *


# to print colorful tags on the shell
class Tags:
	WARNING = "\033[93m\033[1mWARNING: \033[0m\033[0m"
	INFO = "\033[94m\033[1mINFO: \033[0m\033[0m"
	ERROR = "\033[91m\033[1mERROR: \033[0m\033[0m"
	SUCCESS = "\033[92m\033[1mSUCCESS: \033[0m\033[0m"


# parse script arguments
parser = argparse.ArgumentParser(description = "Generate the content of the ReRAM based on the most used kernels")
parser.add_argument("--input", "-i", help = "Name of the file that contains the dump of all kernels and respective addresses used by darknet in some run", required = True)
parser.add_argument("--template", "-t", help = "File that contains the template to be used to generate the gem5 source file", default = "src/arch/arm/isa/insts/data64.template")
parser.add_argument("--output", "-o", help = "Name of the file to dump the ReRAM content after running analysis", default = "src/arch/arm/isa/insts/data64.isa")
parser.add_argument("--size", "-s", help = "Number of 64-bit words that fit the ReRAM", type = int, default = 128)
parser.add_argument("--hitrate", "-r", help = "Desired hitrate for the ReRAM that overrides its size", type = int, choices = range(0,101), default = 0)
parser.add_argument("--verbose", "-v", help = "See detailed log information", type = bool, default = False)
args = parser.parse_args()

# open the file that contains all the addresses of the used kernel segments
kernel_addresses = open(args.input, "r")

print Tags.INFO + "Analysing file {}".format(args.input)

# profile memory and calculate how many times each kernel is used
kernel_mem = {}
call_freq = {}
segments = 0
dot_products = 0
for line in tqdm(kernel_addresses):
	dot_products += 1

	[address, kernel] = numpy.uint64(line.rstrip().split(","))

	if address not in kernel_mem:
		kernel_mem[address] = kernel
	else:
		if kernel_mem[address] != kernel:
			print Tags.ERROR + "File has different values for address {}".format(address)

	if address in call_freq:
		call_freq[address] += 1
	else:
		segments += 1
		call_freq[address] = 1

kernel_addresses.close()

print Tags.INFO + "Number of binary dot products is {}".format(dot_products)
print Tags.INFO + "Number of kernel segments is {}".format(segments)

# count the kernels with different call frequencies
freq_count = {}
for address, calls in call_freq.iteritems():
	if calls in freq_count:
		freq_count[calls] += 1
	else:
		freq_count[calls] = 1

# populating reram based on the kernels that are used the most
hits = 0.0
reram = {}
try:
	for high_freq in sorted(freq_count.keys(), reverse=True):
		if args.verbose:
			print Tags.INFO + "Populating ReRAM with {} kernels that are used {:.2f}% of the time".format(freq_count[high_freq], high_freq * freq_count[high_freq] * 100.0 / dot_products)

		for address, freq in call_freq.iteritems():
			if hits / dot_products * 100 >= args.hitrate and len(reram) >= args.size:
				raise Exception

			if freq == high_freq and address not in reram:
				reram[address] = kernel_mem[address]
				hits += freq
except Exception:
	pass

print Tags.INFO + "ReRAM occupancy is {:.2f}%".format(len(reram) * 100.0 / args.size)
print Tags.INFO + "Hit rate is {:.2f}%".format(hits / dot_products * 100)

# writing output
print Tags.INFO + "Parsing results in gem5 source file {}".format(args.output)

template = open(args.template, "r")
output = open(args.output, "w")

for line in template:
	output.write(line)

	if "populate reram here" in line:
		for address, data in reram.iteritems():
			output.write("reram[{0}] = {1:#0{2}x};\n".format(address, data, 18))

output.close()
template.close()

print Tags.SUCCESS + "All done! Recompile gem5 using scons build/ARM/gem5.opt -j"
