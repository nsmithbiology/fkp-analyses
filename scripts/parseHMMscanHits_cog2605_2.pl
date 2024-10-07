#!usr/bin/perl
use 5.010;

while(<>) {
	@lineFull = split("\t", $_);
	@line = split(',', @lineFull[0]);
	@line2 = split(',', @lineFull[1]);
	@species = split('__', @line[0]);
	if(@line[9] eq 'COG2605') {
		say("@line[0]\t@species[0]\t@line[1]");
	}
	elsif(@line[9] eq 'PRK13412') {
    say("@line[0]\t@species[0]\t@line[1]");
	}
	elsif(@line[9] eq 'Fucokinase' && @line2[9] eq 'PRK13412') {
		say("@line[0]\t@species[0]\t@line[1]");
	}
	elsif(@line[9] eq 'Fucokinase' && @line2[9] eq 'COG2605') {
    say("@line[0]\t@species[0]\t@line[1]");
	}
}
