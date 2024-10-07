#!usr/bin/perl
use 5.010;

while(<>) {
  chomp;
  @line = split("\t", $_);
  say($line[0]);
  say($line[1]);
}
