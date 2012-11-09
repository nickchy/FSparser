#!usr/bin/perl
#created by: Nick Yang Cai
#date: Nov 2012
## this scrpit parse the FactSet Alpha Testing raw data output and calculate
## aggregation and stat results for later load into Diversified research database
use Time::HiRes qw(time);
use POSIX qw(strftime);
use Cwd;
use File::Find;
use Statistics::Basic qw(:all ipres=6);
use List::Util qw(min max);

#use Text::CSV;

my $start= time(); 
#first open log
my $log = "Log/Div_RD_parser.log";
open (my $LOG, ">>$log") or exit(-1);
#start the log
beginLog($LOG);

my $dir = getcwd;

chdir $dir;
#assume there is a Source_Data folder
my $sourcedir = $dir . "/Source_Data";
#check if source_Data folder exists
unless(-d $sourcedir) {

	failLog($LOG, "$sourcedir does not exists!\n");
	exit(-1);
}

#datafile to store all the parsable file
my @datafile=();
#get the file list need to be parsed
find( sub { my $f = $_; push(@datafile, $1) 
	if $f =~ m/^Div_RD\_(.*)\.txt$/; }, $sourcedir);

unless($#datafile >=0) {

	failLog($LOG, "No files need to be parsed\n");
	exit(-1);
}

#get the groupid->parser mapping
my ($flag, %Parsermapping) = Get_parsermapping($direc, $LOG);

unless($flag ==0) 
{ 
	failLog($LOG, "failed when getting parser mapping\n");		 
	exit(-1)
} 

#create hash of parser function
my %actions = ( 1 => \&Fractile_Return_Parser,
                2 => \&Fractile_stat_Parser 
              );

#open $output to write results
my $output = $dir . '/Working_Folder/temp_output.csv';
#open output
unless ( open ($FH, ">$output") ) 
{
	failLog($LOG, "Could not open output file: $output\n");
	exit(-1);
}

foreach my $file (@datafile)
{	
	#status
	print $LOG "\nProcessing $file......\n";
	my $id;
	#find groupid
	if($file =~ m/^(\d+)\_.*/)
	{
		#rint "groupid : $1 \n";
		 $id= $1;
	}
	#check if the groupid exists in maping table
	unless(exists $Parsermapping{$id})
	{
		failLog($LOG, "Bad GroupID: $id for $file\n");
		exit (-1);
	}

	#find the correct parser based on parsermapping and apply the function
	$flag = $actions{$Parsermapping{$id}[0]}->
					($dir, $file, $Parsermapping{$id}[1], $FH, $LOG);

	if($flag != 0)
	{
		failLog($LOG, "failed when parsing $file\n");
		exit(-1);
	}
	print $LOG "$file completed......\n";
}

#finishing up
my $end = time(); 
printf $LOG "\nThe Total Time Used: %6.2fs\n", $end - $start;

close $FH;

finishLog($LOG);

exit(0);

#--------------------------------------------------------------------------
# Sub functions
#--------------------------------------------------------------------------

sub Get_parsermapping($$)
{
	# Get_parsermapping function which takes one input
	# 1. directory
	# 2. logfile handler
	# output: a
	# 1. flag, 0 for success, -1 for failure
	# 2. a filled hash to store datamapping key: groupid, value @(FcnID,Num_of_Fractile)
	my ($directory, $L) = @_;

	#hash to store datamapping key: groupid, value @(FcnID,Num_of_Fractile)
	%Parsermapping = ();
    
    #mapping file path
	$mappingdir = $dir . "/Mappingtable";

	# check if  the mapping file exists
	unless ( open(Datam, $mappingdir.'/Parsermapping.csv') ) 
	{
		print $L "Could not find Parsermapping.csv in $mappingdir\n";
		return (-1, %Parsermapping);
	}

	#reading the data
	while (defined ($line = <Datam>)) 
	{
		chomp $line;
		#get data for each factor
		@data=split(',',$line);
		$Parsermapping{$data[0]} = [$data[1],$data[2]];
	}

	close Datam;

	return (0, %Parsermapping);
}

#--------------------------------------------------------------------------

sub Fractile_Return_Parser($$$$$)
{
	# the fractile return parser function which takes two inputs
	# 1. directory
	# 2. input file name
	# 3. number of fractile
	# 4. output handler
	# 5. $L file handler
	#output a flag
	# 0 for success
	# -1 for failure
	my ($directory, $input,$NumF, $fh, $L) = @_;
	# Open and read the $input file
	# open (Data, $directory.'/Source_Data/Div_RD_'.$input.'.txt') or return -1;

	my $filename = $directory . '/Source_Data/Div_RD_'.$input .'.txt';
	#check if file is empty
	if ( -z "$filename" ) 
	{
   		print $L "File: $input has zero size\n";
   		return -1;
	}
	#open file
	unless ( open (Data, "<$filename") ) 
	{
		print $L "Could not open input file: $input\n";
		return -1;
	}
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
	while (defined ($line = <Data>)) 
	{
		chomp $line;

		 #get data for each factor
		 @data=split(';',$line);
		#take out the endline symobl if there is any
		$data[$#data] =~ s/([1-4]|(\w+)).*/$1/;
		#if($data[$#data] =~ /([1-4]).*/) {$data[$#data] = $1;}
		#parsing start
		for($i = 0; $i < $NOF; $i++)
		{
			if(!exists($dataset{$header[8+$i*2]}{$data[3]}))
			{
				#add date key to the subhash of each factor
				$dataset{$header[8+$i*2]}{$data[3]}={%quartile};
				#initialize subhash
				for($k = 1; $k <= $NumF; $k++)
				{ #quartiles
					$dataset{$header[8+$i*2]}{$data[3]}{$k}=[@tmp];
				}
				$dataset{$header[8+$i*2]}{$data[3]}{'NA'}=[@tmp];
				$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}=[@tmp];
			}
			
			#check if fractile is valid
			unless( exists($dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}) )
			{
				print $L "invalid fractile number: $data[8+$i*2+1] in:\n$line\nfor file $input\n";
				return -1;
			}

			#parsing data
			if($data[5] ne 'NA' && $data[6] ne 'NA')
			{ 	#exclude 'NA' item from calculation
				#aggregating weighted return and total group weight
				$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[0]+=($data[5]*$data[6]);
				$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[1]+=$data[6];
				$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[0]+=($data[5]*$data[6]);
				$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[1]+=$data[6];
			}
		}
	}
	close Data;

	#$csv->print( $fh, \@arr );

	#first by factor
	foreach my $factorkey (keys %dataset) 
	{
		print $L "======".$factorkey."======\n";	
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
			   	print $L "incorrect date format for $dates[$i]\n";
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
				{ 	
					# write the weighted average return within the quartile
				   	$ret=$dataset{$factorkey}{$dates[$i-1]}{$quartilekey}[0]/
				   	$dataset{$factorkey}{$dates[$i-1]}{$quartilekey}[1]; 
				}

			   $id = $input.'_'.$factorkey.'_'.$quartilekey;
			   $idret = $id.'_ret';
			   #$csv->
			   #print FH 
			   print $fh "$idret,$d,$ret\n";
			}
		}
	}

	return 0;
}

#--------------------------------------------------------------------------
sub Fractile_stat_Parser($$$$)
{
	# the fractile Stat parser function which takes two inputs
	# 1. directory
	# 2. input file name
	# 3. number of fractile
	# 4. output handler
	# 5. $L file handler
	#output a flag
	# 0 for success
	# -1 for failure
	my ($directory, $input,$NumF, $fh, $L) = @_;
	# Open and read the $input file
	# open (Data, $directory.'/Source_Data/Div_RD_'.$input.'.txt') or return -1;

	my $filename = $directory . '/Source_Data/Div_RD_'.$input .'.txt';

	#check if file is empty
	if ( -z "$filename" ) 
	{
   		print $L "File: $input has zero size\n";
   		return -1;
	}
	# Open and read the $input file
	unless ( open (Data, "<$filename") ) 
	{
		print $L "Could not open input file: $input\n";
		return -1;
	}
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
	for ( $i = 0; $i < $NOF; $i++)
	{
		$header[8+$i*2]=substr($header[8+$i*2],1,-1);
		$dataset{$header[8+$i*2]}={%quartile};
		$Data{$header[8+$i*2]}={%quartile};

		for($k = 1; $k <= $NumF; $k++)
		{ #quartiles
			$dataset{$header[8+$i*2]}{$k}={%series};
		}
	}
	#keep reading the data
	while (defined ($line = <Data>)) 
	{
		chomp $line;

		 #get data for each factor
		 @data=split(';',$line);
		#take out the endline symobl if there is any
		$data[$#data] =~ s/([1-4]|(\w+)).*/$1/;
		#print $data[9];
		for($i = 0; $i < $NOF; $i++)
		{
			if($data[8+$i*2+1] ne 'NA')
			{
				#check if fractile is valid
				unless( exists($dataset{$header[8+$i*2]}{$data[8+$i*2+1]}) )
				{
					print $L "invalid fractile number: $data[8+$i*2+1] in:\n$line\nfor file $input\n";
					return -1;
				}
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

	#first by factor, write data
	foreach my $factorkey (keys %dataset) 
	{
		#status
		print $L "======".$factorkey."======\n";	
		#get the date list
		foreach my $quartilekey(sort { $a <=> $b } keys %{$dataset{$factorkey}}) 
		{
			#create_id
			$id = $input.'_'.$factorkey.'_'.$quartilekey;
			# only write till second latest date and assign the latest date time stamp on it

			#get the date list
			my @dates = sort { $a <=> $b } keys %{$dataset{$factorkey}{$quartilekey}}; 

			for my $i ( 1 ... ($#dates) )
			{
			   #change date format
			   if($dates[$i] =~ /^(\d{4})(\d{2})(\d{2})$/) 
			   { 
			   		$d= $2.'/'.$3.'/'.$1;
			   }
			   else
			   {
				   	print $L "incorrect date format for $dates[$i]\n";
				   	return -1;
			   }
			   #calculate stat variable
			   $mx = max(@{$dataset{$factorkey}{$quartilekey}{$dates[$i-1]}});
			   $mn = min(@{$dataset{$factorkey}{$quartilekey}{$dates[$i-1]}});
			   $mdn = median(@{$dataset{$factorkey}{$quartilekey}{$dates[$i-1]}});
			   $avg = mean(@{$dataset{$factorkey}{$quartilekey}{$dates[$i-1]}});

			   #id for each item
			   $idmin = $id.'_min';
			   $idmdn = $id.'_median';
			   $idmax = $id.'_max';
			   $idmean = $id.'_mean';

			   #output to file
			   print $fh "$idmin,$d,$mn\n$idmdn,$d,$mdn\n$idmax,$d,$mx\n$idmean,$d,$avg\n";
			}
		}
	}
	return 0;
	# return %Data;
}

sub beginLog($)
{	#start to lag
	#read log handler
	my ($L) = @_;
	#print starting info
	print $L "\n***********Begin Parsing at: ";
	print $L strftime "%Y/%m/%d-%H:%M", localtime;
	print $L "***********\n";
}

sub finishLog($)
{	#after sucessful run
	#read log handler
	my ($L) = @_;
	#print finish up statement
	print $L "Parsing successfully Finished\n\n==================================\n";
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
	print $L "Parsing failed\n\n==================================\n";
	#close log file
	close $L;
}





