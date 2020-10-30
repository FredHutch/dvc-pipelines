nextflow.preview.dsl=2

binDir = !params.containsKey("test") ? "${workflow.projectDir}/lib/modules/scenic/bin/" : ""

toolParams = params.sc.scenic
processParams = params.sc.scenic.aucell

process AUCELL {

    cache 'deep'
    container toolParams.container
    publishDir "${toolParams.scenicoutdir}/${sampleId}/aucell/${"numRuns" in toolParams && toolParams.numRuns > 1 ? "run_" + runId : ""}", mode: 'link', overwrite: true
    label 'compute_resources__scenic_aucell'

    input:
        tuple \
           val(sampleId), \
           path(filteredLoom), \
           path(regulons), \
           val(runId)
        val type

    output:
        tuple \
           val(sampleId), \
           path(filteredLoom), \
           path("${outputFileName}"), \
           val(runId)

    script:
        if(toolParams.numRuns > 2 && task.maxForks > 1 && task.executor == "local")
            throw new Exception("Running multi-runs SCENIC is quite computationally extensive. Please submit it as a job instead.")

        outputFileName = "numRuns" in toolParams && toolParams.numRuns > 1 ? 
            sampleId + "__run_" + runId +"__auc_" + type + ".loom": 
            sampleId + "__auc_" + type + ".loom"
        seed = "numRuns" in toolParams && toolParams.numRuns > 1 ? 
            (params.global.seed + runId) : 
            params.global.seed
        """
        pyscenic aucell \
            $filteredLoom \
            $regulons \
            -o "${outputFileName}" \
            --cell_id_attribute ${toolParams.cell_id_attribute} \
            --gene_attribute ${toolParams.gene_attribute} \
            --seed ${seed} \
            --num_workers ${task.cpus}
        """

}

