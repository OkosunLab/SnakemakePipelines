packages <- c("ASCAT", "GenomicRanges", "IRanges", "optparse")

for ( package in packages ) {
	suppressPackageStartupMessages(require(package, character.only = TRUE))
}

option_list <- list(
	make_option(c("-t", "--tumour-bam"), help = "Tumour bam file"),
	make_option(c("-n", "--normal-bam"), help = "Normal bam file, tumour only if not provided", default = ""),
	make_option(c("-T", "--tumour-name"), help = "Tumour sample name [default %default]", default = "tumour"),
	make_option(c("-N", "--normal-name"), help = "Normal sample name [default %default]", default = "normal"),
	make_option(c("-A", "--allele"), help = "Allele file [default %default]", 
			default = "/data/BCI-OkosunLab/Ref/GRCh38/ASCAT/G1000_allelesAll_hg38/G1000_alleles_hg38_chr"),
	make_option(c("-L", "--loci"), help = "Loci file [default %default]", 
			default = "/data/BCI-OkosunLab/Ref/GRCh38/ASCAT/G1000_lociAll_hg38/G1000_loci_hg38_chr"),
	make_option(c("-G", "--gc"), help = "GC file [default %default]", 
			default = "/data/BCI-OkosunLab/Ref/GRCh38/ASCAT/GC_G1000_hg38.txt"),
	make_option(c("-z", "--rt"), help = "RT file [default %default]", 
			default = "/data/BCI-OkosunLab/Ref/GRCh38/ASCAT/RT_G1000_hg38.txt"),
	make_option(c("-s", "--sex-chr"), help = "Chromosomal sex of patient (XX/XY) [default %default]", default = "XX"),
	make_option(c("-g", "--genome"), help = "genome version [default %default]", default = "hg38"),
	make_option(c("-c", "--threads"), type = "numeric", help = "number of cores to use [default %default]", default = 1),
	make_option(c("-r", "--logr"), help = "LogR output file [default %default]", default = "Tumour_LogR.txt"),
	make_option(c("-b", "--baf"), help = "BAF output file [default %default]", default = "Tumour_BAF.txt"),
	make_option(c("-R", "--norm-logr"), help = "Normal LogR output file [default %default]", default = "Normal_LogR.txt"),
	make_option(c("-K", "--norm-baf"), help = "Normal BAF output file [default %default]", default = "Normal_BAF.txt"),
	make_option(c("-B", "--loci-bin"), type = "numeric", help = "Loci bin size [default %default]", default = 500),
	make_option(c("-q", "--phred"), type = "numeric", help = "Minimum base quality [default %default]", default = 10),
	make_option(c("-a", "--allele-flags"), 
			help = "Additional flags for allele counter (use -f 0 for WES/targeted) [default %default]", 
			default = "-f 0")
)

opt <- parse_args(OptionParser(option_list=option_list))

ascat.prepareHTS(
	tumourseqfile = opt$`tumour-bam`,
	normalseqfile = opt$`normal-bam`,
	tumourname = opt$`tumour-name`,
	normalname = opt$`normal-name`,
	allelecounter_exe = "alleleCounter",
	skip_allele_counting_tumour=FALSE,
	skip_allele_counting_normal=FALSE,
	gender = opt$`sex-chr`,
	alleles.prefix = opt$allele,
	loci.prefix = opt$loci,
	genomeVersion = opt$genome,
	nthreads = opt$threads,
	tumourLogR_file = opt$logr,
	tumourBAF_file = opt$baf,
	normalLogR_file = opt$`norm-logr`,
	normalBAF_file = opt$`norm-baf`,
	loci_binsize = opt$`loci-bin`,
	min_base_qual= opt$phred,
	additional_allelecounter_flags= opt$`allele-flags`)


dir.create(opt$`tumour-name`)
## Load data
ascat.bc = ascat.loadData(Tumor_LogR_file = opt$logr, 
	Tumor_BAF_file = opt$baf, 
	Germline_LogR_file = opt$`norm-log`,
	Germline_BAF_file = opt$`norm-baf`,
	gender = opt$`sex-chr`, 
	genomeVersion = opt$genome)
## Plot raw data
ascat.plotRawData(ascat.bc, 
	img.prefix = paste0(opt$`tumour-name`, "_before_correction_"), img.dir = opt$`tumour-name`)
## Run GC correction
ascat.bc = ascat.correctLogR(ascat.bc, 
	GCcontentfile = opt$gc, 
	replictimingfile = opt$rt)
## Plot post correction values
ascat.plotRawData(ascat.bc, 
	img.prefix = paste0(opt$`tumour-name`, "_after_correction_"), img.dir = opt$`tumour-name`)
## Run aspcf
ascat.bc = ascat.aspcf(ascat.bc)
## Plot segments
ascat.plotSegmentedData(ascat.bc, img.prefix = paste0(opt$`tumour-name`, "_segments_"), img.dir = opt$`tumour-name`)
## 
ascat.output = ascat.runAscat(ascat.bc, 
	gamma=1, 
	write_segments = TRUE,
	img.prefix = paste0(opt$`tumour-name`, "_output_"),
	img.dir = opt$`tumour-name`)
QC = ascat.metrics(ascat.bc,ascat.output)
saveRDS(
	list(
		ascat.bc,
		ascat.output, 
		QC
	), 
	file = paste0(opt$`tumour-name`, '.rds'))


