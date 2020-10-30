#!/usr/bin/env nextflow
nextflow.preview.dsl=2

// Initialize Framework
include { INIT; } from './lib/modules/utils/workflows/utils' params(params)
INIT(params)

// Import Global Utils
include { getDataChannel; } from './lib/modules/channels/channels' params(params)


workflow scanpy {
    include { DIM_REDUCTION as DIM_REDUCTION; } from './lib/modules/scanpy/workflows/dim_reduction' params(params)
    include {
        clean;
        SC__FILE_CONVERTER;
        SC__FILE_CONCATENATOR;
    } from './lib/modules/utils/processes/utils.nf' params(params)
    getDataChannel | SC__FILE_CONVERTER | DIM_REDUCTION
}