# ![lehtiolab/nf-msconvert]

**Runs msconvert in docker to convert RAW to mzML**.

[![Build Status](https://travis-ci.com/lehtiolab/nf-msconvert.svg?branch=master)](https://travis-ci.com/lehtiolab/nf-msconvert)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.32.0-brightgreen.svg)](https://www.nextflow.io/)
[![Docker](https://img.shields.io/docker/automated/nfcore/nf-msconvert.svg)](https://hub.docker.com/r/nfcore/nf-msconvert)

## Introduction

This is a small [Nextflow](https://www.nextflow.io) pipeline that just wraps and runs the Proteowizard docker container to leverage msconvert from that software package.

## Quick Start

i. Install [`nextflow`](https://nf-co.re/usage/installation)

ii. Install one of [`docker`](https://docs.docker.com/engine/installation/), [`singularity`](https://www.sylabs.io/guides/3.0/user-guide/)

iii. Download the pipeline and run on your raw files to convert. Example:

```bash
# Semicolons to separate raws, options, filters, remove the `--` from the options as they are otherwise passed to nextflow, and use double quoting for options/filters.
nextflow run lehtiolab/nf-msconvert -profile <docker/singularity> --raws '/path/to/*.raw' --options 'mz5;numpressAll' --filters '"peakPicking true 2";"precursorRefine"'
nextflow run lehtiolab/nf-msconvert -profile <docker/singularity> --raws '/path/to/1.raw;/path/to/2.raw' --options 'mz5;numpressAll' --filters '"peakPicking true 2";"precursorRefine"'
```

See [usage docs](docs/usage.md) for all of the available options when running the pipeline.

## Documentation

The lehtiolab/nf-msconvert pipeline comes with documentation about the pipeline, found in the `docs/` directory:

1. [Installation](https://nf-co.re/usage/installation)
2. Pipeline configuration
    * [Local installation](https://nf-co.re/usage/local_installation)
3. [Running the pipeline](docs/usage.md)
4. [Troubleshooting](https://nf-co.re/usage/troubleshooting)
