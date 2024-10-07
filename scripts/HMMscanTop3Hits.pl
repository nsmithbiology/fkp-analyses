#!/usr/bin/perl
use 5.010;

# Initialize variables to track the current protein, the previous protein, and the hit count
$current = '';
$previous = '';
$hit_count = 0;

# Loop through each line of the input
while (<>) {
    chomp; # Remove newline character from the end of the line
    @line = split(',', $_); # Split the line into elements separated by commas
    $current = $line[0]; # Set the current protein to the first element of the line
    
    # If the current protein is different from the previous, reset the hit count
    if ($current ne $previous) {
        $hit_count = 0; # Reset the hit count when a new protein is encountered
    }
    
    # Increment the hit count
    $hit_count++;
    
    # If the hit count is within the first three hits, output the line
    if ($hit_count <= 3) {
        say("$_"); # Print the line
    }
    
    # Update the previous protein to be the current one for the next iteration
    $previous = $current;
}