
use Cwd
use File::Find
$dir = getcwd

$workingdir = "/home/nick/FSparser"

chdir $workingdir

 $sourcedir = $dir . "/Source_Data"

find( sub { my $f = $_; push( @datafile, $1 ) if $f =~ m/^Div_RD\_(.*)\.txt$/; }, $sourcedir);

foreach my $file (@datafile) {