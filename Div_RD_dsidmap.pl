#!usr/bin/perl
#created by: Nick Yang Cai
#date: Nov 2012
## this scrpit parse the FactSet Alpha Testing raw data output and calculate
## aggregation and stat results for later load into Diversified research database
use Time::HiRes qw(time);
use POSIX qw(strftime);
use Cwd;
use File::Find;
use Data::Dumper;

my $start= time();

#get dir
my $dir = getcwd;

#first open log
my $log = $dir . "/Log/Div_RD_dsidmapping.log";
open (my $LOG, ">>$log") or exit(-1);

#start the log
beginLog($LOG);

#check if there is data in working folder
my $sourcedata = $dir . '/Working_Folder/temp_output.csv';
unless(-e $sourcedata) {

	failLog($LOG, "$sourcedata does not exists!\n");
	exit(-1);
}

#check if results folder exists
my $rsltdir = $dir . '/Results';
unless(-d $rsltdir) {

	failLog($LOG, "$rsltdir does not exists!\n");
	exit(-1);
}

my $rsltfile = $rsltdir . '/Data_for_import.csv';

#get the datatextid->dsid mapping
my ($flag, %Parsermapping) = Get_dsidmapping($dir, $LOG);

unless($flag ==0) 
{ 
	failLog($LOG, "failed when getting DSID mapping\n");		 
	exit(-1)
} 

#define a reference for hash
$refmapping = \%Parsermapping;

#open output handler
	unless ( open ($FH, ">$rsltfile") ) 
{
	failLog($LOG, "Could not open output file: $output\n");
	exit(-1);
}
#status
print $LOG "\nProcessing $sourcedata......\n";

my $flag = Convert_DSID($refmapping, $sourcedata, $FH, $LOG);

if($flag != 0)
{
	failLog($LOG, "failed when mapping $sourcedata\n");
	exit(-1);
}
print $LOG "$sourcedata completed......\n";


#finishing up
my $end = time(); 
printf $LOG "\nThe Total Time Used: %6.2fs\n", $end - $start;

close $FH;
finishLog($LOG);
exit(0);

#--------------------------------------------------------------------------
# Sub functions
#--------------------------------------------------------------------------

sub Get_dsidmapping($$)
{
	# Get_parsermapping function which takes one input
	# 1. directory
	# 2. output handler
	# output: a
	# 1. flag, 0 for success, -1 for failure
	# 2. a filled hash to store datamapping key: groupid, value @(FcnID,Num_of_Fractile)
	my ($directory, $L) = @_;

	#hash to store datamapping key: groupid, value @(FcnID,Num_of_Fractile)
	my %Parsermapping = ();
    
    #mapping file path
	$mappingdir = $dir . "/Mappingtable";

	# unless(-d $sourcedir) 
	# {
	# 	print "$mappingdir does not exists!\n";
	# 	return (-1, %Parsermapping);
	# }

	# check if  the mapping file exists
	unless ( open(Datam, $mappingdir.'/DSIDmapping.csv') ) 
	{
		print $L "Could not find DSIDmapping.csv in $mappingdir\n";
		return (-1, %Parsermapping);
	}

	#reading the data
	while (defined ($line = <Datam>)) 
	{
		chomp $line;
		#get data for each factor
		@data=split(',',$line);
		$Parsermapping{$data[0]} = $data[1];
	}

	close Datam;

	return (0, %Parsermapping);
}

#--------------------------------------------------------------------------

sub Convert_DSID($$$$)
{
	# the fractile return parser function which takes two inputs
	# 1. mapping hash reference
	# 2. input file path
	# 3. output file handler
	# 4. $LOG file handler
	#output a flag
	# 0 for success
	# -1 for failure
	my ($mapping, $input, $fh, $L) = @_;

	#check if file is empty
	if ( -z "$input" ) 
	{
   		print $L "File: $input has zero size!!\n";
   		return -1;
	}
	# Open and read the $input file
	unless ( open (Data, "<$input") ) 
	{
		print $L "Could not open input file: $input\n";
		return -1;
	}

	#reading the data
	while (defined (my $line = <Data>)) 
	{
		chomp $line;
		#get data for each factor
		my @data=split(',',$line);
		#check if id key exists in mapping
		unless( exists($$mapping{$data[0]}) )
			{
				print $L "invalid input id: $data[0] in:\n$line\nfor file $input\n";
				return -1;
			}

		$line =~ s/$data[0]/$$mapping{$data[0]}/;
		
		print $fh $line."\n";

	}

	#finish up
	close Data;
	return 0;
}

sub beginLog($)
{	#start to lag
	#read log handler
	my ($L) = @_;
	#print starting info
	print $L "\n***********Begin DSID Mapping at: ";
	print $L strftime "%Y/%m/%d-%H:%M", localtime;
	print $L "***********\n";
}

sub finishLog($)
{	#after sucessful run
	#read log handler
	my ($L) = @_;
	#print finish up statement
	print $L "Mapping successfully Finished\n\n==================================\n";
	#close log file
	close $L;
}

sub failLog($$)
{	#when run failed, log and close
	#read log handler
	my ($L, $msg) = @_;
	#print failure msg
	print $L $msg;
	#print finish up statement
	print $L "Mapping failed\n\n==================================\n";
	#close log file
	close $L;
}





