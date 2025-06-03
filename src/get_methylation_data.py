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
from panel_configs import *
from helper_functions import *

# EXAMPLES  
# inputdir = "/media/hieunguyen/HNHD01/raw_data/targetMethyl_analysis/target_methylation_R6782_no_dedup_without_non_directional/06_methylation_extract"
# outputdir = "/media/hieunguyen/HNHD01/outdir/ampliconSeq/data_analysis/test_get_methylation_data"
# path_to_all_fa = "/media/hieunguyen/GSHD_HN01/storage/resources/hg19"
# output_version = "20250601"
# mode = "directional"
# run = "R6782"
# region_version = "CRC_1.1"
# pic = "Vi"
# path_to_control450 = "/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/CONTROL114_ref_data"
# beddir = "/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/panel_design/beds"

##### MAIN RUN
def main():
    parser = argparse.ArgumentParser(description='Generate processed COV file, calculate methylation for all CpGs in the panel.')
    parser.add_argument('--input', type=str, required=True, help='Input directory, path to directory storing all .cov files to calculate methylation data')
    parser.add_argument('--output', type=str, required=True, help='Output directory')
    parser.add_argument('--beddir', type=str, required=True, help='Directory containing bed files for regions')
    parser.add_argument('--fa', type=str, required=True, help='Path to all reference fasta files')
    parser.add_argument('--output_version', type=str, required=True, help='Output version')
    parser.add_argument('--mode', type=str, required=True, help='Mode of bismark alignment: directional or non-directional')
    parser.add_argument('--run', type=str, required=False, help='Run name')
    parser.add_argument('--region_version', type=str, required=False, help='region version')
    parser.add_argument('--pic', type=str, required=False, help='Person in charge')
    parser.add_argument('--control450', type=str, required=True, help='Path to the processed data of the TMD450 control sample')
    
    args = parser.parse_args()

    inputdir = args.input
    outputdir = args.output
    path_to_all_fa = args.fa
    output_version = args.output_version
    mode = args.mode
    run = args.run
    region_version = args.region_version
    pic = args.pic
    path_to_control450 = args.control450
    beddir = args.beddir
    
    print(f'Input directory containing all .cov files for this run: {inputdir}')
    
    path_to_main_output = os.path.join(outputdir,
                                    output_version, 
                                    f"{pic}_output", 
                                    mode, 
                                    f"region_version_{region_version}", 
                                    run)

    os.system(f"mkdir -p {path_to_main_output}")

    all_cov_files = [item for item in pathlib.Path(os.path.join(inputdir)).glob("*/06_methylation_extract/*.cov")]

    print(f"Number of samples in this run {run}: {len(all_cov_files)}")

    metadata_dict = {
        "filename"  : [item.name.split(".no_deduplicated")[0] for item in all_cov_files],
        # "Run" : [str(item).split("/")[6].replace("_no_dedup", "").replace("target_methylation_", "") for item in all_cov_files],
        "Run" : [str(item).split("/")[-3] for item in all_cov_files],
        "path": [str(item) for item in all_cov_files]
    }

    metadata = pd.DataFrame.from_dict(metadata_dict, orient="columns")
    metadata["mode"] = metadata["Run"].apply(lambda x: "directional" if "_without_non_directional" in x else "non_directional")
    metadata["Run"] = run
    metadata["PIC"] = pic

    # harcode: structure of the pipeline output.
    metadata["bam_path"] = metadata["path"].apply(lambda x: str(x)\
                                                    .replace("06_methylation_extract", "05_sorted_bam")\
                                                    .replace(".bedGraph.gz.bismark.zero.cov", ".sorted.bam"))
    
    # depending on the input mode, use non-directional or directional input data.
    metadata = metadata[(metadata["mode"] == mode) & (metadata["PIC"] == pic)]
    metadata.to_excel(os.path.join(path_to_main_output, "metadata.xlsx"), index = False)

    ##### regiondf for hg19
    regiondf = pd.read_csv(os.path.join(beddir, regions[pic][region_version]), sep = "\t", header = None)
    regiondf.columns = ["chrom", "start", "end", "amplicon_name"]
    regiondf = regiondf[["chrom", "start", "end", "amplicon_name"]]
    regiondf["region_name"] = regiondf[["chrom", "start", "end"]].apply(
        lambda x: f"region_{x[0]}_{x[1]}_{x[2]}", axis = 1
    )
    regiondf["bam_region"] = regiondf[["chrom", "start", "end"]].apply(
        lambda x: f"{x[0].replace('chr', '')}:{x[1]}-{x[2]}", axis = 1
    )

    ##### get list of all real cpg for this panel
    cpgdf = pd.DataFrame()
    for region in regiondf.region_name.unique():
        chrom = region.split("_")[1].replace("chr", "")
        start = int(region.split("_")[2])
        end = int(region.split("_")[3])
        refseq = pyfaidx.Fasta(os.path.join(path_to_all_fa, "chr{}.fa".format(chrom)))
        refseq_at_region = str.upper(refseq.get_seq(name = "chr{}".format(chrom), start = start, end = end).seq)

        all_cpg_in_cluster = [m.start(0) for m in re.finditer("CG", refseq_at_region)]
        cpg_coords = [f"chr{chrom}:{item + start}-{item + start + 1}" for item in all_cpg_in_cluster]

        tmp_cpgdf = pd.DataFrame(data = cpg_coords, columns = ["CpG"])
        tmp_cpgdf["region"] = region
        cpgdf = pd.concat([cpgdf, tmp_cpgdf], axis = 0)

    cpgdf = cpgdf[["region", "CpG"]]

    cpgdf.to_excel(os.path.join(path_to_main_output, f"{pic}_panel_correct_cpgdf.xlsx"), index = False)

    ###### count on/off target reads
    metadata["num_total_reads"] = metadata["bam_path"].apply(lambda x: int(pysam.samtools.view("-c", x, catch_stdout=True)))

    if os.path.isfile(os.path.join(path_to_main_output, f"read_count_in_region.xlsx")) == False:
        for region_name in regiondf.region_name.unique():
            bam_region = regiondf[regiondf["region_name"] == region_name]["bam_region"].values[0]
            metadata[region_name] = metadata["bam_path"].apply(lambda x: count_read_in_region(x, bam_region))
            metadata[f"pct_{region_name}"] = metadata[region_name] / metadata["num_total_reads"] * 100
            
        metadata.to_excel(os.path.join(path_to_main_output, f"read_count_in_region.xlsx"), index = False)
    else:
        print("File already exists, skip counting reads in regions. Reading existing data... ")
        metadata = pd.read_excel(os.path.join(path_to_main_output, f"read_count_in_region.xlsx"))

    ##### Process the main COV filesss
    all_covdf = dict()
    for run in metadata.Run.unique():
        for filename in metadata[metadata["Run"] == run]["filename"].unique():
                path_to_save_cov = os.path.join(path_to_main_output, filename)
                os.system(f"mkdir -p {path_to_save_cov}")

                covdf = pd.read_csv(metadata[metadata["filename"] == filename]["path"].values[0], header = None, sep = "\t")
                covdf.columns = ["chrom", "start", "end", "meth_density", "countC", "countT"]
                covdf = covdf[covdf["chrom"].isin(["X", "Y", "MT"]) == False]
                covdf["seq"] = covdf[["chrom", "start"]].progress_apply(lambda x: get_refseq(path_to_all_fa= path_to_all_fa, 
                                                                        chrom = x[0], start = x[1], end = x[1] + 1), axis = 1)
                covdf["strand"] = covdf["seq"].apply(lambda x: "+" if x != "CG" else "-")
                covdf_raw = covdf.copy()
                covdf_raw.to_excel(f"{path_to_save_cov}/{filename}_before_modifying_start_coords.xlsx", index = False)
                covdf["start"] = covdf[["seq", "start"]].apply(lambda x: x[1] + 1 if x[0] != "CG" else x[1], axis = 1)

                all_covdf[filename] = covdf
                covdf["chrom"] = covdf["chrom"].apply(lambda x: str(x))
                strand_name = {"+": "plus", "-": "minus"}
                for strand in ["+", "-"]:
                    for region in regiondf.region_name.unique():
                        chrom = str(region.split("_")[1].replace("chr", ""))
                        start = int(region.split("_")[2])
                        end = int(region.split("_")[3])
                        save_covdf = covdf[(covdf["chrom"] == chrom) & 
                                (covdf["start"] >= start) & 
                                (covdf["start"] <= end) & 
                                (covdf["strand"] == strand)]
                        save_covdf["CpG"] = save_covdf[["chrom", "start"]].apply(lambda x: f"chr{str(x[0])}:{x[1]}-{x[1] + 1}", axis = 1)
                        save_covdf["check_context"] = save_covdf["CpG"].apply(lambda x: "CpG_context" if x in cpgdf["CpG"].values else "False")
                        save_covdf.to_excel(f"{path_to_save_cov}/{region}_{strand_name[strand]}.xlsx", index = False)

    if path_to_control450 != "not_given":
        mean_methyldf = pd.DataFrame(data = regiondf.region_name.unique(), columns = ["region"])
        def get_mean_methyl_in_region(region, filename, strand, remove_non_cpg = True):
            '''
            Calculate average methylation density in a region for a given filename and strand.
            If remove_non_cpg is True, it will only keep CpG context sites and remove others.
            '''
            strand_name = {"+": "plus", "-": "minus"}
            if filename == "CONTROL114":
                df = pd.read_excel(f"{path_to_control450}/region_version_{region_version}/{region}_strand_{strand_name[strand]}.xlsx")
                run = "R6447"
            else:
                run = metadata[metadata["filename"] == filename]["Run"].values[0]
                df = pd.read_excel(f"{os.path.join(path_to_main_output, filename)}/{region}_{strand_name[strand]}.xlsx")
            if df.shape[0] == 0:
                return "no data available"
            else:
                if remove_non_cpg:
                    # keep only CpG context Cs
                    df = df[df["check_context"] == "CpG_context"]
                df_strand = df[df["strand"] == strand]
                if df_strand.shape[0] == 0:
                    mean_methyl = f"no read in this region at strand {strand}"
                else:
                    mean_methyl = df_strand.meth_density.mean()
                return mean_methyl

        for filename in list(all_covdf.keys()) + ["CONTROL114"]:
            for strand in ["+", "-"]:
                mean_methyldf[f"{filename}_{strand}"] = mean_methyldf["region"].apply(lambda x: get_mean_methyl_in_region(x, filename, strand = strand, remove_non_cpg = True))

        mean_methyldf.to_excel(os.path.join(path_to_main_output, f"mean_methyl_in_region_compare_CONTROL114.xlsx"), index = False)
             
if __name__ == '__main__':
    main()