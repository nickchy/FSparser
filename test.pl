
use Cwd
$dir = getcwd

$workingdir = "/home/nick/FSparser"
chdir $workingdir

 $sourcedir = $dir . "/Source_Data"

find( sub { my $f = $_; push( @datafile, $f ) if $f =~ /^Div_RD\_\d{1}(.*)\.txt$/; },$sourcedir);
