nextflow.preview.dsl=2

include {
    isParamNull;
} from './../../utils/processes/utils.nf' params(params)

toolParams = params.sc.cellranger


def generateCellRangerCountCommandDefaults = {
	processParams,
	transcriptome,
	expectCells,
	chemistry ->
	_expectCells = null
	// --expect-cells argument
	if(!isParamNull(expectCells)) {
		_expectCells = expectCells
	} else if (processParams.containsKey('expectCells')) {
		_expectCells = processParams.expectCells
	}
	_chemistry = null
	// --chemistry argument
	if(!isParamNull(chemistry)) {
		_chemistry = chemistry
	} else if (processParams.containsKey('chemistry')) {
		_chemistry = processParams.chemistry
	}
	return (
		"""
		cellranger count \
			--transcriptome=${transcriptome} \
			${_expectCells ? '--expect-cells ' + _expectCells: ''} \
			${_chemistry ? '--chemistry ' + _chemistry: ''} \
			${(processParams.containsKey('forceCells')) ? '--force-cells ' + processParams.forceCells: ''} \
			${(processParams.containsKey('nosecondary')) ? '--nosecondary ' + processParams.nosecondary: ''} \
			${(processParams.containsKey('r1Length')) ? '--r1-length ' + processParams.r1Length: ''} \
			${(processParams.containsKey('r2Length')) ? '--r2-length ' + processParams.r2Length: ''} \
			${(processParams.containsKey('lanes')) ? '--lanes ' + processParams.lanes: ''} \
            --localcores=${task.cpus} \
            --localmem=${task.memory.toGiga()} \
		"""
	)
}

def runCellRangerCount = {
	processParams,
	transcriptome,
    task,
	id,
	sample,
	fastqs,
	expectCells = null,
	chemistry = null ->
	return (
		generateCellRangerCountCommandDefaults(processParams, transcriptome, expectCells, chemistry) + \
		"""	\
		--id=${id} \
		--sample=${sample} \
		--fastqs=${fastqs}
		"""
	)
}

def runCellRangerCountLibraries = {
	processParams,
	transcriptome,
    task,
	id,
	featureRef,
	libraries = null,
	expectCells = null,
	chemistry = null ->
	return (
		generateCellRangerCountCommandDefaults(processParams, transcriptome, expectCells, chemistry) + \
		""" \
		--id ${id} \
		--libraries ${libraries} \
		--feature-ref ${featureRef}
		"""
	)
}

process SC__CELLRANGER__COUNT {

	cache 'deep'
	container toolParams.container
	publishDir "${params.global.outdir}/counts", saveAs: {"${sampleId}/outs"}, mode: 'link', overwrite: true
    label 'compute_resources__cellranger_count'

    input:
		path(transcriptome)
		tuple \
			val(sampleId), 
			path(fastqs, stageAs: "fastqs_??/*")

  	output:
    	tuple val(sampleId), path("${sampleId}/outs")

  	script:
	  	def sampleParams = params.parseConfig(sampleId, params.global, toolParams.count)
		processParams = sampleParams.local
		if(processParams.sample == '') {
			throw new Exception("Regards params.sc.cellranger.count: sample parameter cannot be empty")
		}
		// Check if the current sample has multiple sequencing runs
		fastqs = fastqs instanceof List ? fastqs.join(',') : fastqs
		runCellRangerCount(
			processParams,
			transcriptome,
            task,
			sampleId,
			sampleId,
			fastqs
		)

}

process SC__CELLRANGER__COUNT_WITH_LIBRARIES {

	cache 'deep'
	container toolParams.container
	publishDir "${params.global.outdir}/counts", saveAs: {"${sampleId}/outs"}, mode: 'link', overwrite: true
    label 'compute_resources__cellranger'

    input:
		path(transcriptome)
		path(featureRef)
		tuple \
			val(sampleId), \
			path(fastqs, stageAs: "fastqs_??/*"),
			val(sampleNames),
			val(assays)

  	output:
    	tuple val(sampleId), path("${sampleId}/outs")

  	script:
	  	def sampleParams = params.parseConfig(sampleId, params.global, toolParams.count)
		processParams = sampleParams.local

		if(processParams.sample == '') {
			throw new Exception("Regards params.sc.cellranger.count: sample parameter cannot be empty")
		}

		// We need to create the libraries.csv file here because it needs absolute paths

		csvData = "fastqs,sample,library_type\n"
		fastqs.eachWithIndex { fastq, ix -> 
			csvData += "\$PWD/${fastq},${sampleNames[ix]},${assays[ix]}\n"
		}

		"""
		echo "${csvData}" > libraries.csv
		""" + runCellRangerCountLibraries(
			processParams,
			transcriptome,
            task,
			sampleId,
			featureRef,
			"libraries.csv"
		)

}

process SC__CELLRANGER__COUNT_WITH_METADATA {

	cache 'deep'
	container toolParams.container
	publishDir "${params.global.outdir}/counts", saveAs: {"${sampleId}/outs"}, mode: 'link', overwrite: true
    label 'compute_resources__cellranger'

    input:
		path(transcriptome)
		tuple \
			val(sampleId), \
			val(samplePrefix), \
			path(fastqs, stageAs: "fastqs_??/*"), \
			val(expectCells), \
			val(chemistry)

  	output:
    	tuple \
			val(sampleId), \
			path("${sampleId}/outs")

  	script:
	  	def sampleParams = params.parseConfig(sampleId, params.global, toolParams.count)
		processParams = sampleParams.local
		fastqs = fastqs instanceof List ? fastqs.join(',') : fastqs

		runCellRangerCount(
			processParams,
			transcriptome,
            task,
			sampleId,
			samplePrefix,
			fastqs,
			expectCells,
			chemistry
		)

}
