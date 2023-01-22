#! /bin/bash

# Creating basic variables
SAMPLEDIR="data/mothur/raw"
OUTDIR="data/mothur/process"
LOGS="data/mothur/logs"
METADIR="data/mothur/metadata"

echo PROGRESS: Assembling the paired-end and screening unique sequences.

mkdir -p "${OUTDIR}"  "${LOGS}" "${METADIR}"
# Making contigs from fastq.gz files, aligning reads to references, removing any non-bacterial sequences, calculating distance matrix, making shared file, and classifying OTUs
mothur "#set.logfile(name=${LOGS}/make_files.logfile);
      make.file(type=fastq, inputdir="${SAMPLEDIR}", outputdir="${OUTDIR}", prefix=test);"
 
# cp ${OUTDIR}/test.files ${METADIR}/sample.files