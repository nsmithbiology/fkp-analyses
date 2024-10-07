## perform the analysis for Fucokinase/GDP-Fucose Pyrophosphorylase (FKP) enzymes
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
echo PRK13412 > HMM_files/HMM_list.txt # create a txt file containing the name of the desired HMM
cp downloaded_HMM_files/PRK13412.hmm HMM_files/ # move txt file to the HMM_files directory 

# Perform the HMMsearch
perl Scripts/performHMMsearch.pl HMM_files/HMM_list.txt # a short script to repeat for all HMM files, the build, hmmsearch, parsing, and hit extraction
mv HMMsearchHits/*.faa HMMsearchHits/allHits.fasta # rename the parsed file
perl Scripts/modifyFasta.pl HMMsearchHits/allHits.fasta > HMMsearchHits/allHits_modified.fasta # modify the fasta file for easy sorting
sort -u HMMsearchHits/allHits_modified.fasta > HMMsearchHits/allHits_temp.faa # get just the unique hits
perl Scripts/splitFasta.pl HMMsearchHits/allHits_temp.faa > HMMsearchHits/allHits.faa # modify fasta format

# Perform the HMMscan screens for pf05830
hmmscan --cpu 16 hmmDatabaseFiles/converted_combined.hmm HMMsearchHits/allHits.faa > HMMscan/allHits.txt # run the hmmscan analysis
perl Scripts/parseHMMscan.pl HMMscan/allHits.txt > HMMscanParsed/allHits.csv # parse the hmmscan output file
perl Scripts/HMMscanTop3Hits.pl HMMscanParsed/allHits.csv > HMMscanTop/allHits_3.csv # find the top three hits for each protein
perl Scripts/delete_excess_columns.pl HMMscanTop/allHits_3.csv HMMscanTop/allHits_3_reduced.csv # remove columns that will interfere with hit extraction
perl Scripts/parseTop3Hits.pl HMMscanTop/allHits_3_reduced.csv > HMMscanTop/parsed_3hits.csv # modify CSV for easier hit extraction
perl Scripts/parseHMMscanHits_prk13412.pl HMMscanTop/parsed_3hits.csv HMMscanTop/prk13412_names.txt # isolate entries with any combination of 'Fucokinase' (PF07959), COG2605, PRK13412 in the top 3 hits
perl Scripts/extractHMMscanHits.pl HMMscanTop/prk13412_names.txt > HMMscanTop/prk13412scan.faa # extract the proteins
pullseq -i HMMscanTop/prk13412scan.faa -m 739 -a 1745 > HMMscanTop/prk13412sizefilter.faa # extract only sequences between 739 and 1745 in length 

# Align the proteins and make phylogeny
mafft --thread 16 --maxiterate 1000 --localpair HMMscanTop/prk13412sizefilter.faa > HMMscanTop/prk13412_mafft.faa # align the proteins
trimal -in HMMscanTop/prk13412_mafft.faa -out HMMscanTop/prk13412_trimal.faa -fasta -automated1 # trim alignment
cp HMMscanTop/prk13412_trimal.faa Phylogeny1/prk13412_trimmed_alignment.faa # Copy the trimmed alignment to the Phylogeny1 folder
cd Phylogeny1
iqtree2 -s prk13412_trimmed_alignment.faa -m MF --mset LG,WAG,JTT,Q.pfam,JTTDCMut,DCMut,VT,PMB,Blosum62,Dayhoff -T 4 --prefix prk13412_model # Determine the best fit model and use it for the next step
best_model=$(grep 'Best-fit' prk13412_model.log | cut -f3 -d' ')
echo "Best model extracted: $best_model" #LG+F+R8
iqtree2 -s prk13412_trimmed_alignment.faa -m $best_model --alrt 1000 -B 1000 -T 4 --prefix prk13412_phylogeny # Create the final phylogeny

# Conduct rootstrap analysis
iqtree2 -s prk13412_trimmed_alignment.faa --model-joint NONREV -B 1000 -T 4 --prefix nonrev_prk13412 # generate a tree with predicted rootstrap values
cd ..

# Move relevant files to the output directory
mkdir Output
cp Phylogeny/prk13412_trimmed_alignment.faa Output/prk13412_trimmed_alignment.faa # FKP alignment
cp Phylogeny/prk13412_phylogeny.treefile Output/prk13412_phylogeny.treefile # FKP phylogeny
cp Phylogeny/nonrev_prk13412.treefile Output/nonrev_prk13412.treefile # rootstrap prediction

# Clean directory
mkdir FKP_Complete
mv Output FKP_Complete
mv HMM_files FKP_Complete
mv HMMscan FKP_Complete
mv HMMscanParsed FKP_Complete
mv HMMscanTop FKP_Complete
mv HMMsearch FKP_Complete
mv HMMsearchHits FKP_Complete
mv HMMsearchParsed FKP_Complete
mv Phylogeny FKP_Complete

