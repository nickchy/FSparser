# Created by Nick Yang Cai

# this script parse the alpha testing raw file downloaded from factset, convert it to a quartile(or


# Process the tradedata file, saved in a hash with key equals the stock symobol and the value is PDL matrix
#
# first define some varialbes which will be used later for data parsing and calculation
#
use Time::HiRes qw(time);
use Data::Dumper;
$start= time(); 

# $data store the filename for the trade data which we need to read from
#my $file=$ARGV[0];
my $file="/home/nick/FSparser/Source_Data/Div_RD_1_Summit_PBK.txt";

# Open and read the trade data file and parsing it only drag out the data item listed in @symtrade
open (Data, $file) or die ("Could not open $file: $!");

#read line by line and choose the data that match the selected stock symbol
my $line = <Data>;
@header=split(';',$line);
$NOF=0.5*($#header+1-8);
#print $NOF;
%dataset=();
for ( $i=0;$i<$NOF;$i++)
{
$header[8+$i*2]=substr($header[8+$i*2],1,-1);
$dataset{$header[8+$i*2]}={%factor};

}

#print substr($header[1],1,-1);
# print "$line \n";
# print "number of factors is $NOF \n "; 

 while (defined ($line = <Data>)) {
     chomp $line;

	@data=split(';',$line);
	# for($j=3;$j<=$#data;$j++)
	# {
	# 	print "$data[$j],";
	# }
	print "\n";
     
	for($i=0;$i<$NOF;$i++)
	{
	if(!exists($dataset{$header[8+$i*2]}{$data[3]}))
	{
	$dataset{$header[8+$i*2]}{$data[3]}={%quartile};
	for($k=1;$k<5;$k++)
	{
	$dataset{$header[8+$i*2]}{$data[3]}{$k}=[@tmp];
	}
	$dataset{$header[8+$i*2]}{$data[3]}{'NA'}=[@tmp];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}=[@tmp];
	}
	#print "$data[8+$i*2+1]\n";
	if($data[5] ne 'NA' && $data[6] ne 'NA')
	{
		print $data[8+$i*2+1].'hahaha'."\n";
	$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[0]+=($data[5]*$data[6]);
	#print "$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[1]\n";
	$dataset{$header[8+$i*2]}{$data[3]}{$data[8+$i*2+1]}[1]+=$data[6];
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[0]+=($data[5]*$data[6]);
	$dataset{$header[8+$i*2]}{$data[3]}{'Universe'}[1]+=$data[6];
	}
	}
	
 }
close Data;
#print Dumper %dataset;
$output="/home/nick/FSparser/output.txt";
open (FH, ">$output") or die "can't open $output$!"; # <<<< outside the loop

foreach my $factorkey (keys %dataset) {
#print "$factorkey \n";
   foreach my $datekey (sort { $a <=> $b } keys %{$dataset{$factorkey}}) {
   	#print "$factorkey,$datekey\n";
     foreach my $quartilekey (sort { $a <=> $b } keys %{$dataset{$factorkey}{$datekey}}) {
   # print "$quartilekey\n";
   if($dataset{$factorkey}{$datekey}{$quartilekey}[1]==0)
   {
   $ret='';
   }
   else
   {
   $ret=$dataset{$factorkey}{$datekey}{$quartilekey}[0]/
	$dataset{$factorkey}{$datekey}{$quartilekey}[1]; 
   }
   # print FH "$factorkey,$datekey,$quartilekey, $ret\n";
}
}	
}
close FH;

 $end = time(); 
 printf("\nThe Total Time Used: %6.2f\n", $end - $start); 








