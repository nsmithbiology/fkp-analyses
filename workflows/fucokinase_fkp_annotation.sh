# find proteins from a previous analsyis that have pf07959 hits (call these FKPs)
# ensure all previous directories have been moved to an output folder
# copy the cog2605scan_sizefilter.faa file into the working directory

# make new directory layout
mkdir HMM_files
mkdir HMMsearch
mkdir HMMsearchParsed
mkdir HMMsearchHits
mkdir Annotation

#run HMMsearch for PF07959 query
echo PF07959 > HMM_files/HMM_list.txt # create a txt file containing the name of the desired HMM
cp downloaded_HMM_files/PF07959.hmm HMM_files/ # move txt file to the HMM_files directory 
hmmsearch --cpu 16 HMM_files/*.hmm cog2605scan_sizefilter.faa > HMMsearch/pf07959.txt # search for hits to the other enzymatic domain
perl Scripts/parseHMMsearch.pl HMMsearch/pf07959.txt > HMMsearchParsed/pf07959.txt # parse the output
perl Scripts/extractHMMsearchHits.pl HMMsearchParsed/pf07959.txt > HMMsearchHits/pf07959.faa # extract protein sequences for hits
pullseq -i HMMsearchHits/pf07959.faa -m 400 > HMMsearchHits/pf07959_sizefilter.faa # remove some very short proteins that are likely false positives
awk '/^>/ {print substr($1, 2)}' HMMsearchHits/pf07959_sizefilter.faa > HMMsearchHits/FKP_names.csv # extract the accession names
awk -F'\t' 'BEGIN {OFS="\t"} {print $0, "#44AF31"}' HMMsearchHits/FKP_names.csv > Annotation/FKP_names_colours.csv # add some colour
echo -e "DATASET_COLORSTRIP\nSEPARATOR TAB\n\nDATASET_LABEL\tFKP \n\nDATA" > Annotation/FKP_header.txt # make iTOL headers
cat Annotation/FKP_header.txt Annotation/FKP_names_colours.csv > Annotation/FKP_annotation_cog2605tree.txt # combine headers with data

#clean up the directory
mkdir Fucokinase_Annotation
mv HMM_files Fucokinase_Annotation
mv HMMsearch Fucokinase_Annotation
mv HMMsearchParsed Fucokinase_Annotation
mv HMMsearchHits Fucokinase_Annotation
mv Annotation Fucokinase_Annotation


