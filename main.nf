#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// Initialize Framework
include { INIT; } from './lib/modules/utils/workflows/utils' params(params)
INIT(params)

// Import Global Utils
include { getDataChannel; } from './lib/modules/channels/channels' params(params)


workflow scanpy {
    include { HVG_SELECTION } from './lib/modules/scanpy/workflows/hvg_selection' params(params)
    include { DIM_REDUCTION_PCA } from './lib/modules/scanpy/workflows/dim_reduction_pca' params(params)
    include { NEIGHBORHOOD_GRAPH } from './lib/modules/scanpy/workflows/neighborhood_graph' params(params)
    include { DIM_REDUCTION_TSNE_UMAP } from './lib/modules/scanpy/workflows/dim_reduction' params(params)
    include { NORMALIZE_TRANSFORM } from './lib/modules/scanpy/workflows/normalize_transform.nf'
    include { QC_FILTER } from './lib/modules/scanpy/workflows/qc_filter.nf'
    include {
        clean;
        SC__FILE_CONVERTER;
        SC__FILE_CONCATENATOR;
    } from './lib/modules/utils/processes/utils.nf' params(params)
    out = getDataChannel | SC__FILE_CONVERTER 
    filtered = QC_FILTER(out).filtered
    transformed_normalized = NORMALIZE_TRANSFORM(filtered)
    out = HVG_SELECTION( transformed_normalized )
    DIM_REDUCTION_PCA( out.hvg )
    NEIGHBORHOOD_GRAPH( DIM_REDUCTION_PCA.out )
    DIM_REDUCTION_TSNE_UMAP( NEIGHBORHOOD_GRAPH.out )
    
    

    // NEIGHBORHOOD_GRAPH | DIM_REDUCTION
}