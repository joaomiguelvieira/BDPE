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

for line in reram_file:
	[] = line.rstrip().split(" ")
