## align GLM cope betas to subject highres

# Parameters
subjects="P12"
data_dir="/isilon/LFMI/VMdrive/Lua/Temp2A/Temp2A_fMRI_pilot/proc_data/"
copesMain1="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50"
runsMain="run09 run10 run11 run12 run13 run14 run15 run16 run17 run18 run19 run20 run21 run22 run23"

for subj in $subjects; do
    echo "processing subject $subj data"
    subj_dir=$data_dir/$subj
    cd $subj_dir
    for block in $runsMain; do
        echo "processing block $block"
        epi_reg --epi=${block}/GLMsingletrial_CorrectST.feat/example_func --t1=T1 --t1brain=T1_brain --out=${block}/GLMsingletrial_CorrectST.feat/reg/example_func2highres
        for cope in $copesMain1; do
            flirt -in ${block}/GLMsingletrial_CorrectST.feat/stats/cope${cope}_PSC.nii.gz -ref T1_brain.nii.gz -init ${block}/GLMsingletrial_CorrectST.feat/reg/example_func2highres.mat -out ${block}/GLMsingletrial_CorrectST.feat/stats/cope${cope}_PSC_2highres.nii.gz -applyisoxfm 2
            gunzip ${block}/GLMsingletrial_CorrectST.feat/stats/cope${cope}_PSC_2highres.nii.gz
       done
       echo "finished converting $block 2highres"
    done
    cd ${data_dir}
done
