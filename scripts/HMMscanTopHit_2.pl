#!usr/bin/perl
use 5.010;

$current = 'test';
$previous = 'test';

$test = 0;
while(<>) {
	chomp;
	@line = split(',',$_);
	$current = @line[0];
	if($test == 1) {
		if($current eq $previous) {
			@evalue1 = split(',',$_);
			@evalue2 = split(',',$temp);
			if(@evalue1[1] > @evalue2[1]) {
				say("$temp\t$_");
			}
			else {
				say("$_\t$temp");
			}
		}
		else {
			say("$temp\t$temp");
		}
	}
	unless($current eq $previous) {
		$temp = $_;
		$test = 0;
	}
	$previous = $current;
	$test++;
}

