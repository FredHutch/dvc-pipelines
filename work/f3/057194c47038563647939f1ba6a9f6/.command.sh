#!/bin/bash -ue
/Users/zager/Documents/Projects/dvc-pipelines/src/scanpy/bin/dim_reduction/sc_dim_reduction.py 			--seed 210 			--method pca 			 			 			--n-comps 50 			             --n-jobs 16 			 			test.SC__FILE_CONVERTER.h5ad 			"test.SC__SCANPY__DIM_REDUCTION_PCA.h5ad"
