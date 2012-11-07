#!/usr/bin/perl -w
#use strict;
use warnings;
use File::Find;
use Time::HiRes qw(time);
use threads;
use threads stack_size => 4096;
use threads::shared;
use Thread::Semaphore;

#
#my $mydir="C:/Financial_Data/";
#my @days=();
#
#find(sub {my $file = $_; push(@days,$file) if $file=~/\_\d{8}$/; }, $mydir);
#
#print $days[1];
 
my $direc    = "C:/Financial_Data/";
my $odirec   = "c:/cygwin/home/ncai/backtest_data/";
my @Timearray    =();
my $Timetemp    = "C:/Financial_Data/time_template.txt";

my %Timeindex    =();

my $index = 0;
my $K = 0;
#my @tmp = ();

our $s = Thread::Semaphore->new(4);
open( Data, $Timetemp ) or die("Could not open $Timetemp: $!");

#print "succesfully opend file\n";

while ( my $line = <Data> ) {
	chomp $line;	
	$Timeindex{$line}   = $K;
	$K = $K + 1;
	push (@Timearray, $line);
}
close Data;

#find the list of files
my @YEAR=(2002..2005);
foreach my $year (@YEAR)
{
my @threads=();
my @days = ();

find( sub { my $file = $_; push( @days, $file ) if $file =~ /\_\Q$year\E\d{4}$/; },
	$direc );
		    	
sub fillforward{
	$s->down;
    my %timeindex = %{$_[0]};
    my @timearray = @{$_[1]};
    my $directory = $_[2];
    my $odirectory= $_[3];
    my $day = $_[4];
    #my $S = $_[5];
    #my $id = threads->tid;

    #print "Thread [$id] starting\n";
    my %open         =();
	my %high         =();
	my %low          =();
	my %close        =();
	my %volume       =();
	my %splits       =();
	my %earnings     =();
	my %dividends    =();
	my %datamissing  =();
	my $folder = "${directory}${day}";
    my @ticker=();
	#print "$folder";
	my $fdate = substr( $day, -8 );
	my $ofolder = "${odirectory}${fdate}";
	#print "$ofolder";
	unless ( -d "$ofolder/" ) {
		mkdir( "$ofolder/", 0777 ) or die;
	}
	my @files = ();

	find(
		sub {
			my $file = $_;
			push( @files, $file )
			  if $file =~ /^table\_.*\.csv$/;
		},
		$folder
	);
	
	my $NumStock = $#files + 1;
	#@tmp=(0 x $NumStock);
			foreach my $d  (@timearray) {
			$open{$d}      = [];
			$high{$d}      = [];
			$low{$d}       = [];
			$close{$d}     = [];
			$volume{$d}    = [];
			$splits{$d}    = [];
			$earnings{$d}  = [];
			$dividends{$d} = [];
			$datamissing{$d} = [];
			}
	open( OPEN, "+>${ofolder}/open.csv" ) or die("${ofolder}/open.csv");

	#print OPEN "$times\n";
	open( HIGH, "+>${ofolder}/high.csv" ) or die("${ofolder}/high.csv");

	#print HIGH "$times\n";
	open( LOW, "+>${ofolder}/low.csv" ) or die("${ofolder}/low.csv");

	#print LOW "$times\n";
	open( CLOSE, "+>${ofolder}/close.csv" ) or die("${ofolder}/close.csv");

	#print CLOSE "$times\n";
	open( VOLUME, "+>${ofolder}/volume.csv" ) or die("${ofolder}/volume.csv");

	#print VOLUME "$times\n";
	open( SPLITS, "+>${ofolder}/splits.csv" ) or die("${ofolder}/splits.csv");

	#print SPLITS "$times\n";
	open( EARNINGS, "+>${ofolder}/earnings.csv" )
	  or die("${ofolder}/earnings.csv");

	#print EARNINGS "$times\n";
	open( DIVIDENDS, "+>${ofolder}/dividends.csv" )
	  or die("${ofolder}/dividends.csv");

	#print DIVIDENDS "$times\n";
	open( TICKER, "+>${ofolder}/ticker.csv" ) or die("${ofolder}/ticker.csv");

	#print missing data
	open( MISSING, "+>${ofolder}/Datamissing.csv" )
	  or die("${ofolder}/Datamissing.csv");
  
for my $i ( 0 .. ($NumStock-1) ) { 
    push( @ticker, substr( $files[$i], 6, -4 ) );
		#print "working on file ${folder}/$files[$i]\n";
		open( Data, "${folder}/$files[$i]" )
		  or die("Could not open ${folder}/$files[$i]: $!");
		my $k = 0;
		while ( defined( my $line = <Data> ) ) {
			chomp $line;
			my @tmp = split( ',', $line );
            #print "timearray: $timearray[0]";
			if (   $tmp[1] >= $timearray[0]
				&& $tmp[1] <= $timearray[scalar(@timearray)-1] )
			{
				#print "Here\n";
				if ( $timeindex{ $tmp[1] } > $k ) {
					#print "Herehrere\n";
					if ( $k == 0 ) {
						#print "k=0\n";
						for (my $j = $k ; $j < $timeindex{ $tmp[1] } ; $j++ ) {
							#print"timearray[$j] is $timearray[$j], timeindex{ $tmp[1] } is $timeindex{ $tmp[1] },i is $i\n";
							#print "tmp[2] is $tmp[2]\n";
							$open->{ $timearray[$j] }->[$i]        = $tmp[2];
							$high->{ $timearray[$j] }->[$i]        = $tmp[3];
							$low->{ $timearray[$j] }->[$i]         = $tmp[4];
							$close->{ $timearray[$j] }->[$i]       = $tmp[5];
							$volume->{ $timearray[$j] }->[$i]      = $tmp[6];
							$splits->{ $timearray[$j] }->[$i]      = $tmp[7];
							$earnings->{ $timearray[$j] }->[$i]    = $tmp[8];
							$dividends->{ $timearray[$j] }->[$i]   = $tmp[9];
							$datamissing->{ $timearray[$j]}->[$i] = 1;
							#print "K is now: $k";
						}
					}
					else {
						#print "k!=0\n";
						for ( my $j = $k ; $j < $timeindex{ $tmp[1] } ; $j++ ) {
							$open->{ $timearray[$j] }->[$i] =
							  $open->{ $timearray[ $k - 1 ] }->[$i];
							$high->{ $timearray[$j] }->[$i] =
							  $high->{ $timearray[ $k - 1 ] }->[$i];
							$low->{ $timearray[$j] }->[$i] =
							  $low->{ $timearray[ $k - 1 ] }->[$i];
							$close->{ $timearray[$j] }->[$i] =
							  $close->{ $timearray[ $k - 1 ] }->[$i];
							$volume->{ $timearray[$j] }->[$i] =
							  $volume->{ $timearray[ $k - 1 ] }->[$i];
							$splits->{ $timearray[$j] }->[$i] =
							  $splits->{ $timearray[ $k - 1 ] }->[$i];
							$earnings->{ $timearray[$j] }->[$i] =
							  $earnings->{ $timearray[ $k - 1 ] }->[$i];
							$dividends->{ $timearray[$j] }->[$i] =
							  $dividends->{ $timearray[ $k - 1 ] }->[$i];
							$datamissing->{ $timearray[$j] }->[$i] = 1;
							#print "K is now: $k";
						}
					}
					#print "kkk";
					#print "K is now: $k";
				}
					$open->{ $tmp[1] }->[$i]        = $tmp[2];
					$high->{ $tmp[1] }->[$i]        = $tmp[3];
					$low->{ $tmp[1] }->[$i]         = $tmp[4];
					$close->{ $tmp[1] }->[$i]       = $tmp[5];
					$volume->{ $tmp[1] }->[$i]      = $tmp[6];
					$splits->{ $tmp[1] }->[$i]      = $tmp[7];
					$earnings->{ $tmp[1] }->[$i]    = $tmp[8];
					$dividends->{ $tmp[1] }->[$i]   = $tmp[9];
					$datamissing->{ $tmp[1] }->[$i] = 0;
					$k                          = $timeindex{ $tmp[1] } + 1;
			}
		}
		close Data;
		#print "K is now: $k";
		if ( $k <= (scalar(@timearray) - 1) ) {
			for my $j ($k .. scalar(@timearray)-1) {
				$open->{ $timearray[$j] }->[$i] = $open->{ $timearray[ $k - 1 ] }->[$i];
				$high->{ $timearray[$j] }->[$i] = $high->{ $timearray[ $k - 1 ] }->[$i];
				$low->{ $timearray[$j] }->[$i]  = $low->{ $timearray[ $k - 1 ] }->[$i];
				$close->{ $timearray[$j] }->[$i] =
				  $close->{ $timearray[ $k - 1 ] }->[$i];
				$volume->{ $timearray[$j] }->[$i] =
				  $volume->{ $timearray[ $k - 1 ] }->[$i];
				$splits->{ $timearray[$j] }->[$i] =
				  $splits->{ $timearray[ $k - 1 ] }->[$i];
				$earnings->{ $timearray[$j] }->[$i] =
				  $earnings->{ $timearray[ $k - 1 ] }->[$i];
				$dividends->{ $timearray[$j] }->[$i] =
				  $dividends->{ $timearray[ $k - 1 ] }->[$i];
				$datamissing->{ $timearray[$j] }->[$i] = 1;
			}
		}

    #print "Thread $id done!\n";
}
for my $d (0 .. $#timearray) {
			my $data1 = join( ',', @{ $open->{ $timearray[$d] } } );
			print OPEN "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $high->{ $timearray[$d] } } );
			print HIGH "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $low->{ $timearray[$d] } } );
			print LOW "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $close->{ $timearray[$d] } } );
			print CLOSE "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $volume->{ $timearray[$d] } } );
			print VOLUME "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $splits->{ $timearray[$d] } } );
			print SPLITS "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $earnings->{ $timearray[$d] } } );
			print EARNINGS "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $dividends->{ $timearray[$d] } } );
			print DIVIDENDS "$data1 \n";
			$data1 = ();
			$data1 = join( ',', @{ $datamissing->{ $timearray[$d] } } );
			print MISSING "$data1 \n";
			$data1 = ();
}

	    my $data1 = join( ',', @ticker );
		print TICKER "$data1";

		close TICKER;
		close OPEN;
		close HIGH;
		close LOW;
		close CLOSE;
		close VOLUME;
		close SPLITS;
		close EARNINGS;
		close DIVIDENDS;
		close MISSING;
     $s->up;
    return;
}

my $start= time();
{
foreach my $Day (@days) {
		push @threads,threads->create(
        \&fillforward,
        \%Timeindex,
        \@Timearray,
        $direc,
        $odirec,
        $Day
    );
    	#$count=threads->list;
	    #print "number of threads: $count\n";
}

	$_->join for @threads;
	my @threads=(); 
}
 my $end = time(); 
 printf("finished Year ${year}\nTotal Time Used: %6.2f\n", $end - $start); 
}