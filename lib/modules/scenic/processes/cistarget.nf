nextflow.preview.dsl=2

binDir = !params.containsKey("test") ? "${workflow.projectDir}/src/scenic/bin/" : ""

toolParams = params.sc.scenic
processParams = params.sc.scenic.cistarget

process CISTARGET {

    cache 'deep'
    container toolParams.container
    publishDir "${toolParams.scenicoutdir}/${sampleId}/cistarget/${"numRuns" in toolParams && toolParams.numRuns > 1 ? "run_" + runId : ""}", mode: 'link', overwrite: true
    label 'compute_resources__scenic_cistarget'

    input:
        tuple \
            val(sampleId), \
            path(filteredLoom), \
            path(f), \
            val(runId)
        file featherDB
        file annotation
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
        outputFileName = "numRuns" in toolParams && toolParams.numRuns > 1 ? sampleId + "__run_" + runId +"__reg_" + type + ".csv" : sampleId + "__reg_" + type + ".csv"
        """
        pyscenic ctx \
            ${f} \
            ${featherDB} \
            ${processParams.containsKey('all_modules') && processParams.all_modules ? '--all_modules': ''} \
            --annotations_fname ${annotation} \
            --expression_mtx_fname ${filteredLoom} \
            --cell_id_attribute ${toolParams.cell_id_attribute} \
            --gene_attribute ${toolParams.gene_attribute} \
            --mode "dask_multiprocessing" \
            --output ${outputFileName} \
            --num_workers ${task.cpus} \
        """

}

/* options to implement:

        // motif enrichment arguments:
        --rank_threshold RANK_THRESHOLD
        --auc_threshold AUC_THRESHOLD
        --nes_threshold NES_THRESHOLD

        // motif annotation arguments:
        --min_orthologous_identity MIN_ORTHOLOGOUS_IDENTITY
        --max_similarity_fdr MAX_SIMILARITY_FDR
        --annotations_fname ANNOTATIONS_FNAME


        // module generation arguments:
        --thresholds THRESHOLDS [THRESHOLDS ...]
        --top_n_targets TOP_N_TARGETS [TOP_N_TARGETS ...]
        --top_n_regulators TOP_N_REGULATORS [TOP_N_REGULATORS ...]
        --min_genes MIN_GENES
        --expression_mtx_fname EXPRESSION_MTX_FNAME
*/
