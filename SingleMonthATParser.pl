# Created by Nick Cai
# May 2012
#
# this script parse the alpha testing raw file downloaded from factset, aggregate it to a quartile return

use Time::HiRes qw(time);

$start= time(); 

# $data store the filename for the trade data which we need to read from
#my $inputfile=$ARGV[0];
my $inputfile="I:\\SMALLCAP\\ATParser\\quality_value_update_test.txt";
#my $outputfile=$ARGV[1];
$outputfile="I:\\SMALLCAP\\ATParser\\test.txt";

#######################################################

sub ATParser($$)
{
# the AT parser function which takes two inputs
# 1. input file name
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
#initialize dataset with key to be factor name
for ( $i=0;$i<$NOF;$i++)
{
$header[8+$i*2]=substr($header[8+$i*2],1,-1);
$dataset{$header[8+$i*2]}={%factor};

}
#keep reading the data
 while (defined ($line = <Data>)) {
     chomp $line;
	 
	 #get data for each factor
	@data=split(';',$line);
	for($i=0;$i<$NOF;$i++)
	{
	if(!exists($dataset{$header[8+$i*2]}{$data[3]}))
	{
	#add date key to the subhash of each factor
	$dataset{$header[8+$i*2]}{$data[3]}={%quartile};
	#initialize subhash
	for($k=1;$k<5;$k++)
	{ #quartiles
	$dataset{$header[8+$i*2]}{$data[3]}{$k}=[@tmp];
	}
	$dataset{$header[8+$i*2]}{$data[3]}{'NA'}=[@tmp];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}=[@tmp];
	}
	#
	if($data[5] ne 'NA' && $data[6] ne 'NA')
	{ #exclude 'NA' item from calculation
	#aggregating weighted return and total group weight
	$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[0]+=($data[5]*$data[6]);
	$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[1]+=$data[6];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[0]+=($data[5]*$data[6]);
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[1]+=$data[6];
	}
	}
	
 }
close Data;
#open $output to write results
open (FH, ">$output") or return -1; # <<<< outside the loop
#first by factor
foreach my $factorkey (keys %dataset) {
#get the date list
my @keys = sort { $a <=> $b } keys %{$dataset{$factorkey}}; 

# only write teh second latest date and assign the latest date time stamp on it
    foreach $quartilekey(sort { $a <=> $b } keys %{$dataset{$factorkey}{$keys[$#keys-1]}})
{  #return NULL if no data fell into this quartile
   if($dataset{$factorkey}{$keys[$#keys-1]}{$quartilekey}[1]==0)
   {
   $ret='';
   }
   else
   { # write the weighted average return within the quartile
   $ret=$dataset{$factorkey}{$keys[$#keys-1]}{$quartilekey}[0]/
	$dataset{$factorkey}{$keys[$#keys-1]}{$quartilekey}[1]; 
   }
   print FH "$factorkey,$keys[$#keys],$quartilekey, $ret\n";
}
}
close FH;
return 0;
}

#try the function
$flag=ATParser($inputfile,$outputfile);
print $flag;
$end = time(); 
printf("\nThe Total Time Used: %6.2f\n", $end - $start); 






