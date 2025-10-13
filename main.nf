#!/usr/bin/env nextflow
/*
========================================================================================
                         lehtiolab/nf-msconvert
========================================================================================
 lehtiolab/nf-msconvert Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/lehtiolab/nf-msconvert
----------------------------------------------------------------------------------------
*/



process runMsconvert {
  container params.container
  publishDir "${params.outdir}", mode: 'copy', overwrite: true
  cpus = '--combineIonMobilitySpectra' in params.options ? 4 : 2

  input:
  tuple path(x), val(filters), val(options)

  output:
  path(outfile)

  script:
  outfile = "${x.baseName}.mzML"
  
  """
  # Resolve directory if necessary, pwiz tries to read NF soft links as if they are files, which
  # does not work in case of directory
  ${x.isDirectory() ?  "mv ${x} tmpdir && cp -rL tmpdir ${x}" : ''}
  wine msconvert ${x} ${filters} ${options}
  """
}


workflow {

  // Show help message
  if (params.help) {
      log.info"""
  
      Usage:
  
      The typical command for running the pipeline is as follows:
  
      nextflow run lehtiolab/nf-msconvert --raws '/path/to/*.raw' -profile docker --filters "'peakPicking true 2'"
  	OR e.g.
      nextflow run lehtiolab/nf-msconvert --raws '/path/to/1.raw;/path/to/2.raw' -profile docker --filters "'peakPicking true 2';'precursorRefine'"
  
      Mandatory arguments:
        -profile                      Configuration profile to use. Can use multiple (comma separated)
                                      Available: conda, docker, singularity, awsbatch, test and more.
  
      Options:
        --filters                     Filters to msconvert, in quotes, separate by semicolons, e.g.
                                          --filters '"peakPicking true 2";"precursorRefine"'
        --options                     Options passed to msconvert, in quotes with semicolons,  e.g. 
                                          --options 'optionOne 2;optionTwo', will be passed as --optionOne 2 --optionTwo
  
      Other options:
        --outdir                      The output directory where the results will be saved
        -name                         Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.
  
      AWSBatch options:
        --awsqueue                    The AWSBatch JobQueue that needs to be set when running on AWSBatch
        --awsregion                   The AWS Region for your AWS Batch job to run on
      """.stripIndent()
      exit 0
  }
  
  Channel.fromPath(params.raws.tokenize(';'), type: 'any').set { raws }
  filters = params.filters.tokenize(';').collect() { x -> "--filter ${x}" }.join(' ')
  options = params.options.tokenize(';').collect() {x -> "--${x}"}.join(' ')

  runMsconvert(raws.map { [it, filters, options] })
}
