## Perform the analysis for Fucokinases
# Prior to starting, ensure the directory has the hmmDatabaseFiles directory, the Intermediate directory with the combined proteomes, and the Scripts folder
# Plso have a folder called downloaded_HMM_files with the HMM files of interest

# Make working directories and set up file organization
mkdir HMMsearch
mkdir HMMsearchParsed
mkdir HMMsearchHits
mkdir HMMscan
mkdir HMMscanParsed
mkdir HMMscanTop
mkdir Phylogeny
mkdir HMM_files

# Prepare HMM files
echo COG2605 > HMM_files/HMM_list.txt # create a reference file containing the name of the HMM used
cp downloaded_HMM_files/COG2605.hmm HMM_files/ # move .hmm file to the HMM_files directory 

# Perform the HMMsearch
perl Scripts/performHMMsearch.pl HMM_files/HMM_list.txt # a short script to repeat for all HMM files, the build, hmmsearch, parsing, and hit extraction
mv HMMsearchHits/*.faa HMMsearchHits/allHits.fasta # rename the parsed file
perl Scripts/modifyFasta.pl HMMsearchHits/allHits.fasta > HMMsearchHits/allHits_modified.fasta # modify the fasta file for easy sorting
sort -u HMMsearchHits/allHits_modified.fasta > HMMsearchHits/allHits_temp.faa # get just the unique hits
perl Scripts/splitFasta.pl HMMsearchHits/allHits_temp.faa > HMMsearchHits/allHits.faa # modify fasta format

# Perform the HMMscan screens
hmmscan --cpu 16 hmmDatabaseFiles/converted_combined.hmm HMMsearchHits/allHits.faa > HMMscan/allHits.txt # run the hmmscan analysis
perl Scripts/parseHMMscan.pl HMMscan/allHits.txt > HMMscanParsed/allHits.csv # parse the hmmscan output file
perl Scripts/HMMscanTopHit_2.pl HMMscanParsed/allHits.csv > HMMscanTop/allHits_2.csv # find the top two hits for each protein
perl Scripts/parseHMMscanHits_cog2605_2.pl HMMscanTop/allHits_2.csv > HMMscanTop/cog2605_names.txt # a script to extract the names of proteins that have top hits to the desired HMMs
perl Scripts/extractHMMscanHits.pl HMMscanTop/cog2605_names.txt > HMMscanTop/cog2605scan.faa # extract the proteins
pullseq -i HMMscanTop/cog2605scan.faa -m 333 -a 1745 > HMMscanTop/cog2605scan_sizefilter.faa # filter by size

# Align and trim the hits, then make a phylogeny
mafft --thread 16 --maxiterate 1000 --localpair HMMscanTop/cog2605scan_sizefilter.faa  > HMMscanTop/cog2605_mafft.faa # align the proteins
trimal -in HMMscanTop/cog2605_mafft.faa -out HMMscanTop/cog2605_trimal.faa -fasta -automated1 # trim alignment
cp HMMscanTop/cog2605_trimal.faa Phylogeny/cog2605_trimmed_alignment.faa # Copy the trimmed alignment to the Phylogeny folder
cd Phylogeny
iqtree2 -s cog2605_trimmed_alignment.faa -m MF --mset LG,WAG,JTT,Q.pfam,JTTDCMut,DCMut,VT,PMB,Blosum62,Dayhoff -T 4 --prefix cog2605_model # Determine the best fit model and use it for the next step
best_model=$(grep 'Best-fit' cog2605_model.log | cut -f3 -d' ')
echo $best_model # Q.pfam+R10
iqtree2 -s cog2605_trimmed_alignment.faa -m $best_model --alrt 1000 -B 1000 -T 4 --prefix cog2605_phylogeny # Create the final phylogeny

# Conduct rootstrap analysis
iqtree2 -s cog2605_trimmed_alignment.faa --model-joint NONREV -B 1000 -T 4 --prefix nonrev_cog2605 # generate a tree with predicted rootstrap values
cd ..

# Move relevant files to the output directory
mkdir Output
cp Phylogeny/cog2605_trimmed_alignment.faa Output/cog2605_trimmed_alignment.faa # fucokinase alignment
cp Phylogeny/cog2605_phylogeny.treefile Output/cog2605_phylogeny.treefile # fucokinase phylogeny
cp Phylogeny/nonrev_cog2605.treefile Output/nonrev_cog2605.treefile # rootstrap prediction

# Clean directory
mkdir Fucokinase_Complete
mv HMM_files Fucokinase_Complete
mv HMMscan Fucokinase_Complete
mv HMMscanParsed Fucokinase_Complete
mv HMMscanTop Fucokinase_Complete
mv HMMsearch Fucokinase_Complete
mv HMMsearchHits Fucokinase_Complete
mv HMMsearchParsed Fucokinase_Complete
mv Phylogeny Fucokinase_Complete
mv Output Fucokinase_Complete
