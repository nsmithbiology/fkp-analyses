## Perform the analysis for GDP-Fucose Pyrophosphorylases
# Prior to starting, ensure the directory has the hmmDatabaseFiles directory, the Intermediate directory with the combined proteomes, and the Scripts folder
# Also have a folder called downloaded_HMM_files with the HMM files of interest

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
echo PF07959 > HMM_files/HMM_list.txt # create a txt file containing the name of the desired HMM
cp downloaded_HMM_files/PF07959.hmm HMM_files/ # move txt file to the HMM_files directory 

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
perl Scripts/parseHMMscanHits_pf07959.pl HMMscanTop/allHits_2.csv > HMMscanTop/pf07959_names.txt # a script to extract the names of proteins that have top hits to the desired HMMs
perl Scripts/extractHMMscanHits.pl HMMscanTop/pf07959_names.txt > HMMscanTop/pf07959scan.faa # extract the proteins
pullseq -i HMMscanTop/pf07959scan.faa -m 406 -a 1745 > HMMscanTop/pf07959_sizefilter.faa # filter by size

# Align and trim the hits, then make a phylogeny
mafft --thread 16 --maxiterate 1000 --localpair HMMscanTop/pf07959_sizefilter.faa > HMMscanTop/pf07959_mafft.faa # align the proteins
trimal -in HMMscanTop/pf07959_mafft.faa -out HMMscanTop/pf07959_trimal.faa -fasta -automated1 # trim alignment
cp HMMscanTop/pf07959_trimal.faa Phylogeny1/pf07959_trimmed_alignment.faa # Copy the trimmed alignment to the Phylogeny folder
cd Phylogeny
iqtree2 -s pf07959_trimmed_alignment.faa -m MF --mset LG,WAG,JTT,Q.pfam,JTTDCMut,DCMut,VT,PMB,Blosum62,Dayhoff -T 4 --prefix pf07959_model # Determine the best fit model and use it for the next step
best_model=$(grep 'Best-fit' pf07959_model.log | cut -f3 -d' ')
echo $best_model #LG+F+R8
iqtree2 -s pf07959_trimmed_alignment.faa -m $best_model --alrt 1000 -B 1000 -T 4 --prefix pf07959_phylogeny # Create the final phylogeny

# Conduct rootstrap analysis
iqtree2 -s pf07959_trimmed_alignment.faa --model-joint NONREV -B 1000 -T 4 --prefix nonrev_pf07959 # generate a tree with predicted rootstrap values
cd ..

# Move relevant files to the output directories
mkdir Output
cp Phylogeny/pf07959_trimmed_alignment.faa Output/pf07959_trimmed_alignment.faa # gdp-fucose pyrophosphorylase alignment
cp Phylogeny/pf07959_phylogeny.treefile Output/pf07959_phylogeny.treefile # gdp-fucose pyrophosphorylase phylogeny
cp Phylogeny/nonrev_pf07959.treefile Output/nonrev_pf07959.treefile # rootstrap prediction

# Clean directory
mkdir Pyrophosphorylase_Complete
mv HMM_files Pyrophosphorylase_Complete
mv HMMscan Pyrophosphorylase_Complete
mv HMMscanParsed Pyrophosphorylase_Complete
mv HMMscanTop Pyrophosphorylase_Complete
mv HMMsearch Pyrophosphorylase_Complete
mv HMMsearchHits Pyrophosphorylase_Complete
mv HMMsearchParsed Pyrophosphorylase_Complete
mv Phylogeny Pyrophosphorylase_Complete
mv Output Pyrophosphorylase_Complete

