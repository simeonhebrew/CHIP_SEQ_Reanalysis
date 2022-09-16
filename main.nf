nextflow.enable.dsl = 2

// import modules here

include { QUALITY_CHECK; RAWMULTIQC; TRIMMING; ;ALIGNMENTS; ; CONVERT_TO_BAM; SORTING; REMOVE_DUPLICATES; SCALE_DATA; PEAK_CALLING};  from "./modules/gatkHC.nf"

// set input channels
Channel.fromFile ( params.reads, checkIfExists:true)
	.set { read_ch }
	
Channel.fromPath ( params.reference, checkIfExists:true )
        .set { reference_ch }


 
// Run the workflow
workflow {
// Process 1 Quality Checking
QUALITY_CHECK(read_ch)

// Process 2 MultiQC for raw reads
RAWMULTIQC(QUALITY_CHECK.out.collect())

// Process 3 Alignment
ALIGNMENTS(reference_ch.collect(), read_ch))

// Process 4 Bam Conversion
CONVERT_TO_BAM(ALIGNMENTS.out)

// Process 5 Sorting
SORTING(CONVERT_TO_BAM.out)

// Process 6 Remove duplicates
REMOVE_DUPLICATES(SORTING.out.sorted_bam)

// Process 7 Scaling data
SCALE_DATA(REMOVE_DUPLICATES.out))

// Process 8 Baserecalibration
PEAK_CALLING(reads_ch))


