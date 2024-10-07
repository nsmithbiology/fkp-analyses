use strict;
use warnings;
use 5.010;

# Check if an input file is provided via command line
if (scalar(@ARGV) != 1) {
    die "Usage: perl script.pl <input.csv>";
}

# Read the input file from command-line argument
my $filename = $ARGV[0];
open my $fh, '<', $filename or die "Cannot open file '$filename': $!";

# A hash to store models with their corresponding scores for each UniRef50 accession
my %uniref50_models;

while (my $line = <$fh>) {
    chomp $line;

    # Split the line into columns, ensure there are enough columns
    my @columns = split /,/, $line;
    next if scalar(@columns) < 2; # Ignore lines with fewer than 2 columns

    # Get the UniRef50 accession and model hit (second-to-last column)
    my $uniref50 = $columns[0];
    my $model = $columns[-1]; # This assumes the model is the second-to-last column

    # Store the model for each UniRef50 accession
    push @{$uniref50_models{$uniref50}}, $model unless exists($uniref50_models{$uniref50}) && grep { $_ eq $model } @{$uniref50_models{$uniref50}};
}

close $fh;

# Output each unique UniRef50 accession with the top 3 scoring models
print "UniRef50 accession,Model1,Model2,Model3\n";
foreach my $uniref50 (sort keys %uniref50_models) {
    # Get all models and pick the top 3 (ensure unique)
    my @models = @{$uniref50_models{$uniref50}};
    my @unique_models = do { my %seen; grep { !$seen{$_}++ } @models }; # Ensure unique
    my @top_models = @unique_models[0..($#unique_models < 2 ? $#unique_models : 2)]; # Get top 3 models

    # Output the UniRef50 accession and the top 3 models
    print join(",", $uniref50, @top_models), "\n";
}