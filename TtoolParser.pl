#!/usr/bin/perl
#Created by Nick Cai
# May 2012
#
# this script parse the alpha testing raw file downloaded from factset, aggregate it to a quartile return
use Time::HiRes qw(time);
use Statistics::Basic qw(:all ipres=6);
use List::Util qw(min max);

$start= time(); 
$inputfile=$ARGV[0];
$outputfile=$ARGV[1];


#try the function
%Data=FractileParser($inputfile,$outputfile);
print %Data;
$end = time(); 
printf("\nThe Total Time Used: %6.2f\n", $end - $start); 

# $data store the filename for the trade data which we need to read from
#my $inputfile=$ARGV[0];
# my $inputfile="F:\\Works\\Timing _Tool\\TtoolParser\\DYNAMIC_TTOOL.txt";
# #my $outputfile=$ARGV[1];
# $outputfile="F:\\Works\\Timing _Tool\\TtoolParser\\test.csv";

#######################################################

sub FractileParser($$)
{
# the AT parser function which takes two inputs
# 1. input file name, match part of /^Div\_RD\_(.*)\.txt/
# 2. outpu file name
#output a flag
# 0 for success
# -1 for failure
my ($input,$output) = @_;
# Open and read the $input file
open (Data, $input) or return -1;

#read through the first line in the file, where stores the headers
my $line = <Data>;
#find the column where the header of factor starts
@header=split(';',$line);
#get the number of files
$NOF=0.5*($#header+1-8);
#create hash to store dataset
%dataset=();
%Data=();
#initialize dataset with key to be factor name
for ( $i=0;$i<$NOF;$i++)
{
$header[8+$i*2]=substr($header[8+$i*2],1,-1);
$dataset{$header[8+$i*2]}={%quartile};
$Data{$header[8+$i*2]}={%quartile};
for($k=1;$k<5;$k++)
	{ #quartiles
	$dataset{$header[8+$i*2]}{$k}={%series};
	$Data{$header[8+$i*2]}{$k}={%series};
	$Data{$header[8+$i*2]}{$k}{'date'}=[@tmp];
	$Data{$header[8+$i*2]}{$k}{'min'}=[@tmp];
	$Data{$header[8+$i*2]}{$k}{'max'}=[@tmp];
	$Data{$header[8+$i*2]}{$k}{'median'}=[@tmp];
	}
}
#keep reading the data
 while (defined ($line = <Data>)) {
     chomp $line;
     
	 #get data for each factor
	@data=split(';',$line);
	#print $data[9];
	for($i=0;$i<$NOF;$i++)
	{
	if($data[8+$i*2+1] ne 'NA')
	{
	if(!exists($dataset{$header[8+$i*2]}{$data[8+$i*2+1]}{$data[3]}))
	{
	#initialize subhash
	$dataset{$header[8+$i*2]}{$data[8+$i*2+1]}{$data[3]}=[@tmp];
	
	}
		push(@{$dataset{$header[8+$i*2]}{$data[8+$i*2+1]}{$data[3]}},$data[8+$i*2]);
	}
	}
 }
close Data;

#open $output to write results
open (FH, ">$output") or return -1; # <<<< outside the loop
#first by factor
foreach my $factorkey (keys %dataset) {
#get the date list
foreach my $quartilekey(sort { $a <=> $b } keys %{$dataset{$factorkey}}) 
{
# only write teh second latest date and assign the latest date time stamp on it
    foreach $datekey(sort { $a <=> $b } keys %{$dataset{$factorkey}{$quartilekey}})
{  #return NULL if no data fell into this quartile

$mx = max(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
$mn = min(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
$mdn = median(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'min'}},$mn);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'max'}},$mx);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'median'}},$mdn);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'date'}},$datekey);
   print FH "$factorkey,$quartilekey,$datekey,$mn,$mdn,$mx\n";
}
}
}
close FH;
return %Data;
}






