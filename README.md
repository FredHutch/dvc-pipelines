# dvc-pipelines

This repo is based on VSN Pipelines with 3 main differences

1.  Upgraded To Work With NF 20.07.1 + Latest DSL 2.0 Syntax
2.  Remove Requirement To Mount Bin Directory To Docker For Easier Use On AWS
3.  Includes PubWeb Workflows + Input Forms

## Quick Notes

### Run
nextflow -C scanpy.conf run main.nf -entry scanpy
nextflow -C aws.conf run main.nf -entry scanpy -w s3://dvc-wf-data/gottardo_r


### Gen A Config Based On Modules
nextflow config main.nf -profile h5ad,docker,scanpy

### Clone A Sub Repo
git subrepo clone https://github.com/vib-singlecell-nf/scanpy.git lib/modules/scanpy

