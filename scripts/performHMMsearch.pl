#!usr/bin/perl
use 5.010;

# Get HMM files
while(<>) {
	chomp;
	push(@HMMs,$_);
}

# Perform the HMMsearches for pf07959
foreach $i (@HMMs) {
	#system("hmmbuild HMM_files_fbp/$i.hmm HMM_files_fbp/$i.FASTA"); # build the HMM profiles - don't need if using pre-built ones
	system("hmmsearch --cpu 16 HMM_files/$i.hmm Intermediate/combined_proteomes.faa > HMMsearch/$i.txt"); # do the hmmsearch
	system("perl Scripts/parseHMMsearch.pl HMMsearch/$i.txt > HMMsearchParsed/$i.txt"); # parse the hmmsearch output
	system("perl Scripts/extractHMMsearchHits.pl HMMsearchParsed/$i.txt > HMMsearchHits/$i.faa"); # extract the hmmsearch hits
}

