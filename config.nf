
/* -------------------------------------------------
 * Variant-calling Nextflow config file
 * ------------------------------------------------
*/

// Global default params, used in configs

params {
	outdir = ''/shared/home/shebrew/cours_chipseq/Open_analysis/Nextflow_Results/*'
	reads = '/shared/home/shebrew/cours_chipseq/Open_analysis/data/*'
        reference = '/shared/projects/form_2022_23/data/chipseq/mouse_index/mm9'
	tracedir = "${params.outdir}/workflow_files"
}


dag {
	enabled = true
	file = "${params.tracedir}/ChIP_pipeline_dag.png"
}


report {
	enabled = true
	file = "${params.tracedir}/ChIP_execution_report.html"
}

timeline {
	enabled = true
	file = "${params.tracedir}/ChIP_execution_timeline.html"
}

trace {
	enabled = true
	file = "${params.tracedir}/ChIP_execution_trace.html"
}



manifest {
	name = "ChIP_seq analysis""
	homePage = "https://github.com/simeonhebrew/ChIP_SEQ_Reanalysis"
	description = "ChIP seq analysis for Sox2 and Oct4 reanalysis"
	mainScript = "main.nf"
	nextflowVersion = ">=20.10.0"
}


profiles {
    slurm {
           process.executor = 'slurm'
      }
} 


