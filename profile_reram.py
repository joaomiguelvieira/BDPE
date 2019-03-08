import numpy
import argparse


# to print colorful tags on the shell
class Tags:
	WARNING = "\033[93m\033[1mWARNING: \033[0m\033[0m"
	INFO = "\033[94m\033[1mINFO: \033[0m\033[0m"
	ERROR = "\033[91m\033[1mERROR: \033[0m\033[0m"
	SUCCESS = "\033[92m\033[1mSUCCESS: \033[0m\033[0m"


# parse arguments of the script
parser = argparse.ArgumentParser(description = "Profile the ReRAM content")
parser.add_argument("--file", "-f", help = "Name of the file that contains the content of the ReRAM parsed for C++", required = True)
args = parser.parse_args()

reram_file = open(args.file, "r")

reram = {}
cache = {}
for line in reram_file:
	data = numpy.uint64(int(line.rstrip().split(" ")[-1].split(";")[0].split("x")[1], 16))
	address = numpy.uint64(line.split("[")[1].split("]")[0])
	
	reram[address] = data

	cache_addr = address & numpy.uint64(0x7f)
	if cache_addr not in cache:
		cache[cache_addr] = []
	cache[cache_addr].append(hex(address))

min_addr = min(reram.keys())
max_addr = max(reram.keys())
addr_space = max_addr - min_addr
n_entries = (addr_space / 8) + 1

print Tags.INFO + "Lower cached address is {}".format(min_addr)
print Tags.INFO + "Higher cached address is {}".format(max_addr)
print Tags.INFO + "Cached address space is {} bytes, or {} entries".format(addr_space, n_entries)

for key, value in cache.iteritems():
	if len(value) > 1:
		print Tags.WARNING + "Detected colision for addresses {}".format(value)
