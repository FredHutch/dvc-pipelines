nextflow.preview.dsl=2

process SC__STAR__UNLOAD_GENOME {

	container params.sc.star.container
    label 'compute_resources__default'

	input:
		file(transcriptome)
		val allDone

	script:
		"""
		echo "--genomeDir ${transcriptome}"
		STAR \
			--genomeLoad Remove \
			--genomeDir ${transcriptome}
		"""

}
