nextflow.preview.dsl=2

import static groovy.json.JsonOutput.*



//////////////////////////////////////////////////////
//  Import sub-workflows from the modules:

include { 
    INIT;
    getDataChannel;
} from './lib/modules/utils/workflows/utils' params(params)
INIT(params)
include {
    SC__FILE_CONVERTER
} from './lib/modules/utils/processes/utils' params(params)
include {
    getDataChannel
} from './lib/modules/channels/channels' params(params)

include {
    SINGLE_SAMPLE
} from './workflows/single_sample.nf' params(params)


workflow single_sample {

    main:
        // run the pipeline
        getDataChannel | \
            SC__FILE_CONVERTER | \
            SINGLE_SAMPLE

}
