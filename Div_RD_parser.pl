#!usr/bin/perl
# Created by Nick Cai
# May 2012
#
# this script parse the alpha testing raw file downloaded from factset, aggregate it to a quartile return

use Time::HiRes qw(time);
use Cwd;
use File::Find;
#use Text::CSV;

$start= time(); 

$dir = getcwd;

chdir $dir;
#assume there is a Source_Data folder
$sourcedir = $dir . "/Source_Data";
#check if source_Data folder exists
unless(-d $sourcedir) {
    print "$sourcedir does not exists!\n";
    return -1;
}
#get the file list need to be parsed
find( sub { my $f = $_; push(@datafile, $1) 
			if $f =~ m/^Div_RD\_(.*)\.txt$/; }, $sourcedir);
unless($#datafile >=0) {
	print "No files need to be parsed";
	return 0;
}
#######################################################

sub Quartile_Return_Parser($$)
{
# the AT parser function which takes two inputs
# 1. directory
# 2. input file name,match part of /^Div\_RD\_(.*)\.txt/
#output a flag
# 0 for success
# -1 for failure
my ($directory,$input) = @_;
# Open and read the $input file
open (Data, $directory.'/Source_Data/Div_RD_'.$input.'.txt') or return -1;

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
#reading the data
 while (defined ($line = <Data>)) {
     chomp $line;
	 
	 #get data for each factor
	@data=split(';',$line);
	#take out the endline symobl if there is any
	$data[$#data] =~ s/([1-4]|(\w+)).*/$1/;
	#if($data[$#data] =~ /([1-4]).*/) {$data[$#data] = $1;}
	#parsing start
	for($i=0; $i<$NOF; $i++)
	{
	if(!exists($dataset{$header[8+$i*2]}{$data[3]}))
	{
	#add date key to the subhash of each factor
	$dataset{$header[8+$i*2]}{$data[3]}={%quartile};
	#initialize subhash
	for($k=1;$k<5;$k++)
	{ #quartiles
	$dataset{$header[8+$i*2]}{$data[3]}{'Q'.$k}=[@tmp];
	}
	$dataset{$header[8+$i*2]}{$data[3]}{'NA'}=[@tmp];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}=[@tmp];
	}
	#
	if($data[5] ne 'NA' && $data[6] ne 'NA')
	{ #exclude 'NA' item from calculation
	#aggregating weighted return and total group weight
	$dataset{$header[8+$i*2]}{$data[3]}{'Q'.$data[8+$i*2+1]}[0]+=($data[5]*$data[6]);
	$dataset{$header[8+$i*2]}{$data[3]}{'Q'.$data[8+$i*2+1]}[1]+=$data[6];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[0]+=($data[5]*$data[6]);
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[1]+=$data[6];
	}
	}
	
 }
close Data;
#open $output to write results
$output = $directory.'/'.'Working_Folder/temp_output.csv';
#open csv writer
#my $csv = Text::CSV->new ( { always_quote => 1 } );
open (FH, ">>$output") or return -1; 
#$csv->print( $fh, \@arr );

#first by factor
foreach my $factorkey (keys %dataset) {
	print "======".$factorkey."======\n";	
#get the date list
my @dates = sort { $a <=> $b } keys %{$dataset{$factorkey}}; 

for my $i ( 1 ... ($#dates) )
{
	   #change date format
   if($dates[$i] =~ /^(\d{4})(\d{2})(\d{2})$/) { 
   	$d= $2.'/'.$3.'/'.$1;
   }
   else
   {
   	print "incorrect date format for $keys[$i]";
   	return -1;
   }
# write the second latest date and assign the latest date time stamp on it
    foreach $quartilekey(sort { $a <=> $b } keys %{$dataset{$factorkey}{$dates[$i-1]}})
    {
    	   # print $input.'_'.$factorkey.'_'.$quartilekey."\n";
    #return NULL if no data fell into this quartile
   if($dataset{$factorkey}{$dates[$i-1]}{$quartilekey}[1]==0)
   {
   $ret='NA';
   }
   else
   { # write the weighted average return within the quartile
   $ret=$dataset{$factorkey}{$dates[$i-1]}{$quartilekey}[0]/
	$dataset{$factorkey}{$dates[$i-1]}{$quartilekey}[1]; 
   }

   $id = $input.'_'.$factorkey.'_'.$quartilekey;

   #$csv->
   #print FH 
   print FH "$id,$d,$ret\n";
	}
}
close FH;
}
return 0;
}
##Timing tool parser
sub Quartile_stat_Parser($$)
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
#initialize dataset with key be factor name
for ( $i=0;$i<$NOF;$i++)
{
$header[8+$i*2]=substr($header[8+$i*2],1,-1);
$dataset{$header[8+$i*2]}={%quartile};
$Data{$header[8+$i*2]}={%quartile};
for($k=1;$k<5;$k++)
	{ #quartiles
	$dataset{$header[8+$i*2]}{'Q'.$k}={%series};
	$Data{$header[8+$i*2]}{'Q'.$k}={%series};
	$Data{$header[8+$i*2]}{'Q'.$k}{'date'}=[@tmp];
	$Data{$header[8+$i*2]}{'Q'.$k}{'min'}=[@tmp];
	$Data{$header[8+$i*2]}{'Q'.$k}{'max'}=[@tmp];
	$Data{$header[8+$i*2]}{'Q'.$k}{'median'}=[@tmp];
	}
}
#keep reading the data
 while (defined ($line = <Data>)) {
     chomp $line;
     
	 #get data for each factor
	@data=split(';',$line);
	#take out the endline symobl if there is any
	$data[$#data] =~ s/([1-4]|(\w+)).*/$1/;
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
	#create_id
	$id = $input.'_'.$factorkey.'_'.$quartilekey;
# only write till second latest date and assign the latest date time stamp on it
    foreach $datekey(sort { $a <=> $b } keys %{$dataset{$factorkey}{$quartilekey}})
{  #return NULL if no data fell into this quartile
	if($dates[$i] =~ /^(\d{4})(\d{2})(\d{2})$/) { 
   		$d= $2.'/'.$3.'/'.$1;
   	}
   	else
   {
   	print "incorrect date format for $keys[$i]";
   	return -1;
   }
$mx = max(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
$mn = min(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
$mdn = median(@{$dataset{$factorkey}{$quartilekey}{$datekey}});
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'min'}},$mn);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'max'}},$mx);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'median'}},$mdn);
push(@{$Data{$header[8+$i*2]}{$quartilekey}{'date'}},$datekey);
   #output to file
   print FH "$id_Min,$d,$mn\n$id_Median,$d,$mdn\n$id_Max,$d,$mx\n";
}
}
}
close FH;
return %Data;
}

foreach my $file (@datafile) {
	print $file."\n";
	#try the function
	$flag=ATParser($dir,$file);
}

#print $flag;
$end = time(); 
printf("\nThe Total Time Used: %6.2f\n", $end - $start); 






