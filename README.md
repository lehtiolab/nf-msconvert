# lehtiolab/nf-msconvert

**Runs conversion of .raw/.d files to .mzML format**

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A525.04.1-brightgreen.svg)](https://www.nextflow.io/)

## Introduction

This is a small lehtiolab-internal [Nextflow](https://www.nextflow.io) pipeline that just wraps and runs the 
Proteowizard or ThermoRawFileParser container to convert files in a nextflow pipeline

## Quick Start

i. Install [`nextflow`](https://www.nextflow.io/docs/latest/install.html)

ii. Install one of [`docker`](https://docs.docker.com/engine/installation/), [`singularity`](https://www.sylabs.io/guides/3.0/user-guide/), ['apptainer'](https://apptainer.org/docs/admin/latest/installation.html)

iii. Download the pipeline and run on your raw files to convert. Example:

```bash
# Semicolons to separate raws, options, filters, remove the `--` from the options as they are otherwise passed to nextflow, and use double quoting for options/filters.
# --reportout gives a small amount of pipeline run reports (process trace, CPU usage, etc).
nextflow run lehtiolab/nf-msconvert -profile docker -resume \
  --raws '/path/to/*.raw' \
  --options 'mz5;numpressAll' \
  --filters "precursorRefine"' \
  --centroid '1,2' \
  --reportout

# Default uses proteowizard, if that does not work or another tool is preferred, you can use `--mzmltool thermorawfileparser`. Here we also pass --md5out to get MD5 sums of each mzML file.
# NB it does not take --options and --filters
nextflow run lehtiolab/nf-msconvert -profile singularity -resume \
  --raws '/path/to/1.raw;/path/to/2.raw' \
  --centroid 2 \
  --md5out \
  --mzmltool thermorawfileparser
```
