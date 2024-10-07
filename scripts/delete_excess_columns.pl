use strict;
use warnings;
use 5.010;

# Check if input and output filenames are provided
if (scalar(@ARGV) != 2) {
    die "Usage: perl script.pl <input.csv> <output.csv>";
}

# Get input and output filenames from command line arguments
my $input_filename = $ARGV[0];
my $output_filename = $ARGV[1];

# Open the input file for reading and the output file for writing
open my $input_fh, '<', $input_filename or die "Cannot open file '$input_filename': $!";
open my $output_fh, '>', $output_filename or die "Cannot open file '$output_filename': $!";

while (my $line = <$input_fh>) {
    chomp $line;

    # Split the line into columns
    my @columns = split /,/, $line;

    # Keep the first 10 columns (indices 0 through 9)
    my @first_10_columns = @columns[0..9];

    # Join the first 10 columns and write to the output file
    print $output_fh join(",", @first_10_columns), "\n";
}

# Close the file handles
close $input_fh;
close $output_fh;

print "Data from the first 10 columns has been written to '$output_filename'.\n";