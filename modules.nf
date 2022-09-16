nextflow.enable.dsl = 2
	

	// Process 1: Quality control analysis --tool: fastqc
	

	process QUALITY_CHECK {
	    publishDir path: "${params.outdir}/Qc", mode: 'copy'
	    tag "Quality Checking:"
	

	    input:
	    tuple val(sample_id), path(reads)
	

	    output:
	    path "${sample_id}_logs"
	

	    script:
	    """
	    mkdir ${sample_id}_logs
	    fastqc -o ${sample_id}_logs -f fastq -t 8 -q ${reads}
	    """
	}
	

	// Process 2 : MultiQC Summary Report --tool: multiqc
	

	process RAWMULTIQC {
		publishDir path: "${params.outdir}/multiqc_untrimmed", mode: 'copy'
		tag "MultiQC report for raw reads:"
		
		input:
		file(fastqc)
	

		output:
		file('multiqc_report.html')
	

		script:
		
		"""
		multiqc . 
	
		"""
	}
	
	// Process 3: Alignment --tool: bowtie
	

	process ALIGNMENTS {
	    publishDir path: "${params.outdir}/aligned", mode: 'copy'
	    tag "Alignment:"
	

	    input:
	    path(ref_ch)
	    tuple path(Reads)
		
	    output:
	    path "${sample_id}.sam", emit: aligned_sam
	

	    script:
	

	    sample_id = ( Read =~ /(.+)_.fastq/ )[0][1]
	    aligned = "${sample_id}.sam"
	

	    template 'align.sh'
	

	}
	
	

	// Process 4: Converting to bam format --tool: samtools
	

	process CONVERT_TO_BAM {
	      publishDir path : "${params.outdir}/conversion", mode: 'copy'
	      tag "Conversion"
	

	      input:
	      path align_sam
	

	      output:
	      path "SRR*_aligned.bam", emit: aligned_bam
	

	      script:
	      aligned = "SRR*_aligned.bam"
	

	      """
	      samtools view -Sb ${align_sam} > ${aligned}
	      """
	}
	

	// Process 5: Sorting bam file --tool: samtools 
	

	process SORTING {
	      publishDir path: "${params.outdir}/sorting", mode : 'copy'
	      tag "Sorting"
	

	      input:
	      path align_bam
	

	      output:
	      path "SRR*_aligned_sorted.bam", emit: sorted_bam
	      path "SRR*_aligned_sorted.bam.bai", emit: sorted_bai
		
	      script:
	      sort = "SRR_aligned_sorted.bam"
	      sortidx = "SRR_aligned_sorted.bam.bai"
	      """
	      samtools sort -O bam -o ${sort} ${align_bam}
	      samtools index ${sort} > ${sortidx}
	
	      """
	}
	

	// Process 6: Removing Duplicates --tool: Picard
	

	process REMOVE_DUPLICATES {
	      publishDir path: "${params.outdir}/Dedups", mode:'copy'
	      tag "Removing Duplicates"
	

	      input:
	      path sort_bam
	

	      output:
	      path "marked_dups.bam", emit: marked_dups
	      path "marked_dups_metrics.txt", emit: met_dedups
	

	      script:
	      dedups = "marked_dups.bam"
	      metdedups = "marked_dups_metrics.txt"
	

	      """
	      MarkDuplicates --INPUT ${sort_bam} --OUTPUT ${dedups} \
	      --METRICS_FILE ${metdedups} --REMOVE_DUPLICATES true
	
	      samtools index ${dedups} 
	      """
	}
	

	// Process 7: Scaling Data --tool: Deeptools
	process SCALING_DATA {
		publishDir path: "${params.outdir}"
	        tag " Scaling Data:""
	

	        input:
		path sort_dedup__bam_out
	

	        output:
	        path "SRR_nodup.bw", emit: bw_file
	        
	

	        script:
	        bw_file = SRR_nodup.bw
	

	        """
		bamCoverage --bam ${dedup_bam} \
--outFileName ${bw_file} --outFileFormat bigwig --effectiveGenomeSize 4639675 \
--normalizeUsing RPGC --skipNonCoveredRegions --extendReads 200 --ignoreDuplicates

	        """
	}
	

	// Process 8: PEAK_CALLING   --tool: MACS
	

	process PEAK_CALLING {
		publishDir path: "${params.outdir}/peakcalling", mode:'copy'
		
		tag "Peak_calling:"
	

		input:
		path sort_bam
		path sort_bam_ctrl
	        
	        output:
		path "MACS_out", emit: MACS.out
		
		script:
		
	

		"""

		macs -t ${sort_bam} -c ${sort_bam_ctrl} --format BAM  --gsize mm \
                --bw 500 --diag &> ${MACS.out}

		"""
