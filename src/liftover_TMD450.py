import pandas as pd 
from liftover import ChainFile
def liftOver_hg38_to_hg19(inputdf: pd.DataFrame) -> pd.DataFrame:
    '''
    Download the chain file from: https://hgdownload.cse.ucsc.edu/goldenpath/hg38/liftOver/hg38ToHg19.over.chain.gz 
    e.g. for lifting from hg38 to hg19.
    # or from: https://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
    '''
    converter = ChainFile('../chain/hg38ToHg19.over.chain.gz', one_based=True)
    inputdf.columns = ["chrom", "start", "end", "meth_density", "countC", "countT"]
    inputdf["new_start"] = inputdf[["chrom", "start"]].apply(lambda x: converter[x[0]][x[1]][0][1], axis = 1)
    inputdf["new_end"] = inputdf[["chrom", "end"]].apply(lambda x: converter[x[0]][x[1]][0][1], axis = 1)
    outputdf = inputdf[["chrom", "new_start", "new_end", "meth_density", "countC", "countT"]].copy()
    outputdf.columns = ["chrom", "start", "end", "meth_density", "countC", "countT"]
    return outputdf
