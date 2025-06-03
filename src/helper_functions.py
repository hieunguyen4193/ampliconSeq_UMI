import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt 
import seaborn as sns 
import os
import pathlib
import pysam
import pyfaidx
import warnings
import re
import argparse
import sys
from tqdm import tqdm 
tqdm.pandas()
warnings.filterwarnings("ignore")

##### HELPER FUNCTIONS
def count_read_in_region(bam_path, region, chr_mode = False):
    all_reads = []
    bamfile = pysam.AlignmentFile(bam_path, "rb")
    if chr_mode:
        region = f"chr{region}"
    fetched_obj = bamfile.fetch(region = region)
    for read in fetched_obj:
        all_reads.append(read)
    return(len(all_reads))
    
##### get refseq function
def get_refseq(path_to_all_fa, chrom, start, end):
    if "chr" in str(chrom):
        chrom = chrom.replace("chr", "")
    refseq = pyfaidx.Fasta(os.path.join(path_to_all_fa, "chr{}.fa".format(chrom)))
    outputseq = str.upper(refseq.get_seq(name = "chr{}".format(chrom), start = start, end = end).seq)
    return(outputseq)
