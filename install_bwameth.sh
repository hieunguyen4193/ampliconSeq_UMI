    source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
    # these 4 lines are only needed if you don't have toolshed installed
    wget https://pypi.python.org/packages/source/t/toolshed/toolshed-0.4.0.tar.gz
    tar xzvf toolshed-0.4.0.tar.gz
    cd toolshed-0.4.0
    python setup.py install

    wget https://github.com/brentp/bwa-meth/archive/master.zip
    unzip master.zip
    cd bwa-meth-master/
    python setup.py install
