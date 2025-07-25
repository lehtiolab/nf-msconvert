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

def helpMessage() {
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
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

/*
 * SET UP CONFIGURATION VARIABLES
 */


if ( workflow.profile == 'awsbatch') {
  // AWSBatch sanity checking
  if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
  // Check outdir paths to be S3 buckets if running on AWSBatch
  // related: https://github.com/nextflow-io/nextflow/issues/813
  if (!params.outdir.startsWith('s3:')) exit 1, "Outdir not on S3 - specify S3 Bucket to run on AWSBatch!"
  // Prevent trace files to be stored on S3 since S3 does not support rolling files.
  if (workflow.tracedir.startsWith('s3:')) exit 1, "Specify a local tracedir or run without trace! S3 cannot be used for tracefiles."
}

nextflow.enable.dsl = 1
params.options = ''
params.filters = ''
params.raws = false

Channel.fromPath(params.raws.tokenize(';'), type: 'any').set { raws }
filters = params.filters.tokenize(';').collect() { x -> "--filter ${x}" }.join(' ')
options = params.options.tokenize(';').collect() {x -> "--${x}"}.join(' ')
msconv_cpus = '--combineIonMobilitySpectra' in options ? 4 : 2

// Header log info
def summary = [:]
if (workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Raw files']        = params.raws
summary['Options']        = params.raws
summary['Filters']        = params.raws
summary['Max Resources']    = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
if (workflow.containerEngine) summary['Container'] = "$workflow.containerEngine - $workflow.container"
summary['Output dir']       = params.outdir
summary['Launch dir']       = workflow.launchDir
summary['Working dir']      = workflow.workDir
summary['Script dir']       = workflow.projectDir
summary['User']             = workflow.userName
if (workflow.profile == 'awsbatch') {
  summary['AWS Region']     = params.awsregion
  summary['AWS Queue']      = params.awsqueue
}
summary['Config Profile'] = workflow.profile


process msconvert {
  container params.container
  publishDir "${params.outdir}"

  cpus = msconv_cpus

  input:
  file(x) from raws

  output:
  file(outfile) into mzmls

  script:
  outfile = "${x.baseName}.mzML"
  
  """
  # Resolve directory if necessary, pwiz tries to read NF soft links as if they are files, which
  # does not work in case of directory
  ${x.isDirectory() ?  "mv ${x} tmpdir && cp -rL tmpdir ${x}" : ''}
  wine msconvert ${x} ${filters} ${options}
  """
}
