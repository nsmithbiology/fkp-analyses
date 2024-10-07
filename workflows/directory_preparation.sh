# Download and prepare HMM libraries (Feb 2024)
mkdir hmmDatabaseFiles/ # make a directory to hold the HMM files
wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam36.0/Pfam-A.hmm.gz # get the Pfam HMM files
wget ftp://ftp.ncbi.nlm.nih.gov/hmm/TIGRFAMs/release_15.0/TIGRFAMs_15.0_HMM.LIB.gz # get the TIGRFAM HMM files
gunzip Pfam-A.hmm.gz # unzip the Pfam files
gunzip TIGRFAMs_15.0_HMM.LIB.gz # unzip the TIGRFAM files
mv Pfam-A.hmm hmmDatabaseFiles/Pfam-A.hmm # move the Pfam files
mv TIGRFAMs_15.0_HMM.LIB hmmDatabaseFiles/TIGRFAMs_15.0_HMM.LIB # move the TIGRFAM files

wget https://ftp.ncbi.nih.gov/pub/mmdb/cdd/fasta.tar.gz # Download CDD database
tar -xzf fasta.tar.gz -C CDD_database # Unzip CDD database
rm fasta.tar.gz # Remove zip file
cd CDD_database # Change directory
for f in $(ls COG*.FASTA) # Loop to make HMMs from COG files
  do
    echo "Processing file: ${f}"
    hmmbuild ${f}_profile.hmm ${f}
  done
for f in $(ls cd*.FASTA) # Loop to make HMMs from cd files
  do
    echo "Processing file: ${f}"
    hmmbuild ${f}_profile.hmm ${f}
  done
cd .. # Change directory
cat CDD_database/COG*.hmm > hmmDatabaseFiles/COG.hmm # Combine COG HMMs
cat CDD_database/cd*.hmm > hmmDatabaseFiles/cd.hmm # Combine cd HMMs
hmmconvert hmmDatabaseFiles/Pfam-A.hmm > hmmDatabaseFiles/Pfam-A_converted.hmm # convert the database to the necessary format
hmmconvert hmmDatabaseFiles/TIGRFAMs_15.0_HMM.LIB > hmmDatabaseFiles/TIGRFAM_converted.hmm # convert the database to the necessary format
hmmconvert hmmDatabaseFiles/COG.hmm > hmmDatabaseFiles/COG-converted.hmm # convert the database to the necessary format
hmmconvert hmmDatabaseFiles/cd.hmm > hmmDatabaseFiles/cd-converted.hmm # convert the database to the necessary format
cat hmmDatabaseFiles/Pfam-A_converted.hmm hmmDatabaseFiles/TIGRFAM_converted.hmm hmmDatabaseFiles/COG.hmm hmmDatabaseFiles/cd-converted.hmm > hmmDatabaseFiles/converted_combined.hmm # combined all hidden Markov models into a single file
hmmpress hmmDatabaseFiles/converted_combined.hmm # prepare files for hmmscan searches

# download and format the proteomes
# prior to starting, the "combined_proteomes.faa" file, corresponding to the UniRef50 database, was downloaded from the FTP
mkdir Intermediate
perl Scripts/modifyFasta.pl Intermediate/combined_proteomes.faa > Intermediate/combined_proteomes_modified.faa # modify the fasta file for easy extraction