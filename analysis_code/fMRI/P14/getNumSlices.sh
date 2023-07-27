#!/bin/sh
### Extract number of slices from nifii
# Inputs:
#   $1: Path to source .nii.gz file. Bash wildcard characters ok.
fslinfo $1 | grep -w dim3 | awk '{print $2}'
