# Snakefile
# Snakemake file for 16S pipeline

# Configuration file containing all user-specified settings
configfile: "config/config.yaml"

# Function for aggregating list of raw sequencing files.
mothurSamples = list(set(glob_wildcards(os.path.join('data/mothur/raw/', '{sample}_{readNum, R[12]}_001.fastq.gz')).sample))

sraSamples = list(set(glob_wildcards(os.path.join('data/mothur/raw/', '{sample}_{sraNum, [12]}.fastq.gz')).sample))

# Master rule for controlling workflow.

"""
Preprocess results using mothur
"""

rule all:
    input:
        expand("{outdir}/{dataset}.files", outdir=config["outdir"], dataset=config["dataset"]),
        expand("{outdir}/{dataset}.trim.contigs.good.unique.fasta", outdir=config["outdir"], dataset=config["dataset"]),
        expand("{outdir}/{dataset}.trim.contigs.good.count_table", outdir=config["outdir"], dataset=config["dataset"]),
        "data/mothur/references/silva.seed.align",
        "data/mothur/references/silva.v4.align",
        "data/mothur/references/trainset16_022016.pds.fasta",
        "data/mothur/references/trainset16_022016.pds.tax",
        "data/mothur/references/zymo.mock.16S.v4.fasta"

############
# RULES
############		
# SILVA database for use as reference alignment.
rule get_silva_alignements:
	input:
		script="workflow/scripts/mothur_silva.sh"
	output:
		silvaSeed="data/mothur/references/silva.seed.align",
		silvaV4="data/mothur/references/silva.v4.align",
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script}"


# RDP database for use as reference classifier.
rule get_rdp_classifier:
	input:
		script="workflow/scripts/mothur_rdp.sh"
	output:
		rdpFasta="data/mothur/references/trainset16_022016.pds.fasta",
		rdpTax="data/mothur/references/trainset16_022016.pds.tax"
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script}"


# Downloading the Zymo mock sequence files and extracting v4 region for error estimation.
rule get_zymo_mock:
	input:
		script="workflow/scripts/mothur_zymo_mock.sh",
		silvaV4=rules.get_silva_alignements.output.silvaV4
	output:
		mockV4="data/mothur/references/zymo.mock.16S.v4.fasta"
	conda:
		"envs/mothur.yaml"
	shell:
		"bash {input.script}"


rule make_files:
    input:
        script="workflow/scripts/make_files.sh",
    output:
        files="{outdir}/{dataset}.files",
    shell:
        "bash {input.script}"


rule make_contigs:
    input:
        script="workflow/scripts/make_contigs.sh",
        files=rules.make_files.output.files
    output:
        fasta = "{outdir}/{dataset}.trim.contigs.good.unique.fasta",
        ctable = "{outdir}/{dataset}.trim.contigs.good.count_table",
    threads: 2
    shell:
        "bash {input.script} {input.files}"


rule align_n_filter:
    input:
        script="workflow/scripts/align_n_filter.sh",
        fasta=rules.make_contigs.output.fasta,
        ctable=rules.make_contigs.output.ctable,
        refs=rules.get_silva_alignements.output.silvaV4,
    output:
        fasta = "{outdir}/{dataset}.trim.contigs.good.unique.good.filter.unique.fasta",
        ctable = "{outdir}/{dataset}.trim.contigs.good.unique.good.filter.count_table",
    shell:
        "bash {input.script} {input.files}"


	# input: stability.trim.contigs.good.unique.good.filter.count_table, stability.trim.contigs.good.unique.good.filter.unique.fasta