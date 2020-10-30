nextflow.preview.dsl=2

binDir = !params.containsKey("test") ? "${workflow.projectDir}/lib/modules/scenic/bin/" : ""

toolParams = params.sc.scenic

process AGGR_MULTI_RUNS_REGULONS {

    cache 'deep'
    container toolParams.container
    publishDir "${toolParams.scenicoutdir}/${sampleId}", mode: 'link', overwrite: true
    label 'compute_resources__scenic_multiruns'

    input:
		tuple val(sampleId), path(f)
		val type

    output:
    	tuple val(sampleId), path("multi_runs_regulons_${type}")

	script:
		"""
		${binDir}aggregate_multi_runs_regulons.py \
			${f} \
			--output "multi_runs_regulons_${type}" \
		"""

}

/* options to implement:
*/
