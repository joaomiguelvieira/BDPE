import numpy
import argparse


# to print colorful tags on the shell
class Tags:
	WARNING = "\033[93m\033[1mWARNING: \033[0m\033[0m"
	INFO = "\033[94m\033[1mINFO: \033[0m\033[0m"
	ERROR = "\033[91m\033[1mERROR: \033[0m\033[0m"
	SUCCESS = "\033[92m\033[1mSUCCESS: \033[0m\033[0m"


# parse script arguments
parser = argparse.ArgumentParser(description = "Generate the content of the ReRAM based on the most used kernels")
parser.add_argument("--file", "-f", help = "Name of the file that contains the dump of all kernels and respective addresses used by darknet in some run", required = True)
parser.add_argument("--min_occupacy", "-min", help = "Minimum occupancy of the ReRAM", type = float, default = float(0))
parser.add_argument("--output", "-o", help = "Name of the file to dump the ReRAM content after running analysis", default = "reram.txt")
args = parser.parse_args()

# open the file that contains all the addresses of the used kernel segments
kernel_addresses = open(args.file, "r")

print Tags.INFO + "Analysing file {}".format(args.file)

# profile memory and calculate how many times each kernel is used
kernel_mem = {}
call_freq = {}
segments = 0
dot_products = 0
for line in kernel_addresses:
	dot_products += 1

	[address, kernel] = numpy.uint64(line.rstrip().split(","))

	if address not in kernel_mem:
		kernel_mem[address] = kernel

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

# calculate ReRam usage
highest_freq = max(freq_count.keys())
most_used = freq_count[max(freq_count.keys())]

print Tags.INFO + "There are {} kernels being used {} times".format(most_used, highest_freq)

reram_occupancy = float(most_used) / float(128)

if reram_occupancy < args.min_occupacy:
	print Tags.WARNING + "Real ReRAM occupancy {}% is lower than specified occupancy {}%".format(int(reram_occupancy * 100), int(args.min_occupacy * 100))
else:
	print Tags.INFO + "Real ReRAM occupancy is {}%".format(int(reram_occupancy * 100))

print Tags.INFO + "Populating ReRAM"

# populate ReRAM
reram = {}
for address, freq in call_freq.iteritems():
	if freq == highest_freq:
		if address not in reram:
			reram[address] = kernel_mem[address]

mem_file = open(args.output, "w")

for address, data in reram.iteritems():
	mem_file.write("reram[{}] = {};\n".format(address, data))

mem_file.close()

print Tags.SUCCESS + "All done! Outputs written to {}".format(args.output)
