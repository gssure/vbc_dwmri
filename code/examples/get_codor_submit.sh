#!/bin/bash
# v1.3

CPUS='4'
RAM='48G'
DISK='120G'
LOGS_DIR=~/htcondor-templates/vbc_dwmri/logs
VBC_DWMRI='/data/project/singularity/vbc_dwmri_1.1.0.simg'
SOFTWARE_DIR='/data/project/SC_pipeline/01_MRI_pipelines/Container/vbc_dwmri'
DATA_DIR='/data/project/SC_pipeline/02_MRI_data'
ATLAS_DIR='/data/project/SC_pipeline/02_MRI_data/Atlases'
OUTPUT_DIR='/data/project/SC_pipeline/03_Structural_Connectivity'
FREESURFER_OUTPUT='/data/project/SC_pipeline/Neuroimage/Tools/freesurfer/subjects'
FREESURFER_LICENSE='/opt/freesurfer/6.0/license.txt'
INPUT_PARAMETERS='/data/project/SC_pipeline/03_Structural_Connectivity/input_HCP_500K_Schaefer100P17N.txt'

SHELL_SCRIPT=$(pwd)/${1}

# create the logs dir if it doesn't exist
[ ! -d "${LOGS_DIR}" ] && mkdir -p "${LOGS_DIR}"

# print the .submit header
printf "# The environment
universe       = vanilla
getenv         = True
request_cpus   = ${CPUS}
request_memory = ${RAM}
request_disk   = ${DISK}

# Execution
initial_dir    = \$ENV(HOME)/htcondor-templates/vbc_dwmri
executable     = /usr/bin/singularity
\n"

# loop over all subjects
for sub in 101309 102311; do
    printf "arguments = exec --cleanenv \
                        -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SHELL_SCRIPT}:/opt/script.sh,${INPUT_PARAMETERS}:/opt/input.txt \
                        ${VBC_DWMRI} \
                        /mnt_sw/code/container_SC_pipeline.sh \
                        /opt/input.txt \
                        ${CPUS} \
                        ${sub}\n"
    printf "log       = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.log\n"
    printf "output    = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.out\n"
    printf "error     = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.err\n"
    printf "Queue\n\n"
done
