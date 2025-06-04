output_version="20250603";
pic="Vi";
maindir="/mnt/NAS_PROJECT/vol_ECDteam/hieunho/output/batch_22112022";
main_outputdir="/mnt/DATASM14/DATA_HIEUNGUYEN/outdir/ampliconSeq";
path_to_fa="/mnt/archiving/DATA_HIEUNGUYEN/2024/resources/hg19";
control450="../CONTROL114_ref_data";
beddir="../panel_design/beds"

all_regions=$(ls ./runs_group_by_panels/${pic}/*.txt | xargs -n 1 basename);
for region in ${all_regions}; do \
    region_version=$(echo ${region%.txt*});
    echo -e "working on region: ${region_version}";
    all_runs=$(cat ./runs_group_by_panels/${pic}/${region});
    for run in ${all_runs};do \
        for mode in directional non_directional;do \
            python ../src/get_methylation_data.py \
                --input "${maindir}/${run}${pic}" \
                --output ${main_outputdir}/${run} \
                --fa ${path_to_fa} \
                --output_version ${output_version} \
                --mode ${mode} \
                --run ${run} \
                --region_version ${region_version} \
                --pic ${pic} \
                --control450 ${control450} \
                --beddir ${beddir};
        done;
    done;
done;
echo -e "All done!";
# EOF
