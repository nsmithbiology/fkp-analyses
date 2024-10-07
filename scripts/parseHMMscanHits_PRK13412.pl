use strict;
use warnings;
use Text::CSV;
use 5.010;

# Get command line arguments for input and output file names
my ($input_file, $output_file) = @ARGV;

# Validate that both input and output file names are provided
die "Usage: perl script.pl <input_csv> <output_txt>\n" unless $input_file && $output_file;

# Open the input CSV file
open(my $csv_fh, '<', $input_file) or die "Could not open input file '$input_file': $!";

# Initialize a CSV parser
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });

# Read the header row
my $header = $csv->getline($csv_fh);

# Hash to store accessions with required models
my %accessions_with_required_models;

# List of required models
my @required_models = ('PRK13412', 'COG2605', 'Fucokinase');

# Read and parse the CSV lines
while (my $row = $csv->getline($csv_fh)) {
    my ($uniref50_accession, @models) = @$row;

    # Convert @models into a hash for easier lookup
    my %models_hash = map { $_ => 1 } @models;

    # Check if all required models are present
    my $all_present = 1;
    foreach my $model (@required_models) {
        unless ($models_hash{$model}) {
            $all_present = 0;
            last;
        }
    }

    # If all required models are present, add the UniRef50 accession to the hash
    if ($all_present) {
        $accessions_with_required_models{$uniref50_accession} = 1;
    }
}

# Close the input CSV file
close($csv_fh);

# Open the output text file for writing
open(my $out_fh, '>', $output_file) or die "Could not open output file '$output_file': $!";

# Write the UniRef50 accessions to the output text file
foreach my $accession (sort keys %accessions_with_required_models) {
    print $out_fh "$accession\n";
}

# Close the output file
close($out_fh);

print "Output written to '$output_file'.\n";