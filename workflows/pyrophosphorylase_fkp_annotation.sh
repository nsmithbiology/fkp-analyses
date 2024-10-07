# find proteins from a previous analsyis that have cog2605 hits (call these FKPs)
# ensure all previous directories have been moved to an output folder
# copy the pf07959_sizefilter.faa file into the working directory

# make new directory layout
mkdir HMM_files
mkdir HMMsearch
mkdir HMMsearchParsed
mkdir HMMsearchHits
mkdir Annotation

#run HMMsearch for PF07959 query
echo COG2605 > HMM_files/HMM_list.txt # create a txt file containing the name of the desired HMM
cp downloaded_HMM_files/COG2605.hmm HMM_files/ # move txt file to the HMM_files directory 
hmmsearch --cpu 16 HMM_files/*.hmm pf07959sizefilter.faa > HMMsearch/cog2605.txt # search for hits to the other enzymatic domain
perl Scripts/parseHMMsearch.pl HMMsearch/cog2605.txt > HMMsearchParsed/cog2605.txt # parse the output
perl Scripts/extractHMMsearchHits.pl HMMsearchParsed/cog2605.txt > HMMsearchHits/cog2605.faa # extract protein sequences for hits
pullseq -i HMMsearchHits/cog2605.faa -m 490 > HMMsearchHits/cog2605_sizefilter.faa # remove some very short proteins that are likely false positives
awk '/^>/ {print substr($1, 2)}' HMMsearchHits/cog2605_sizefilter.faa > HMMsearchHits/FKP_names.csv # extract the accession names
awk -F'\t' 'BEGIN {OFS="\t"} {print $0, "#44AF31"}' HMMsearchHits/FKP_names.csv > Annotation/FKP_names_colours.csv # add some colour
echo -e "DATASET_COLORSTRIP\nSEPARATOR TAB\n\nDATASET_LABEL\tFKP \n\nDATA" > Annotation/FKP_header.txt # make iTOL headers
cat Annotation/FKP_header.txt Annotation/FKP_names_colours.csv > Annotation/FKP_annotation_pf07959tree.txt # combine headers with data

#clean up the directory
mkdir 3_pf07959_tree_annotation
mv HMM_files 3_pf07959_tree_annotation
mv HMMsearch 3_pf07959_tree_annotation
mv HMMsearchParsed 3_pf07959_tree_annotation
mv HMMsearchHits 3_pf07959_tree_annotation
mv Annotation 3_pf07959_tree_annotation