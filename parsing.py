import os
import sys
import subprocess
from Bio import Align

folder = sys.argv[1]
files = os.listdir(folder)
#############
#unzip files#
#############
for f in files:
    subprocess.call("unxz "+folder+"/"+f, shell = "True")

#################
#parse sequences#
#################
files = os.listdir(folder)
sequencemetadata = open(folder+"/"+files[2], "r", encoding = "unicode_escape").readlines()[1:]
num_sequences = len(sequencemetadata)
sequencefile = open(folder+"/"+files[0], "r", encoding = "unicode_escape").readlines()
sequences = []
s = ""
for l in sequencefile:
    if ">" in l:
        sequences.append(s.replace("\n", ""))
        s = ""
    else:
        s = s+l
sequences = sequences[1:]

#################
#align sequences#
#################    
for sequence in sequences:
    nf = open("query.txt", "w")
    nf.write(sequence)
    subprocess.call("python wateraligner.py --email judge.ciara@gmail.com --stype dna --asequence spike.txt --bsequence query.txt --outfile results", shell = "true")
    #some parsing will go here
    subprocess.call("rm results*", shell = "true")
    subprocess.call("rm query.txt", shell = "true")
