
use strict;

use Getopt::Std;
use Term::ReadKey;
use Spreadsheet::ParseExcel;
use Weather::Schema;

our($opt_H, $opt_D, $opt_U, $opt_i);
getopts('H:D:U:i:');

$opt_U ||= 'web_usr';

if (!$opt_i) { print "Need an input file (option -i).\n"; exit(); }

print "Password for $opt_U for database $opt_D on host $opt_H: ";
ReadMode 'noecho';
my $password = ReadLine(0);
chomp($password);
ReadMode 'normal';
print "\n";

my $schema = Weather::Schema->connect("dbi:Pg:dbname=$opt_D;host=$opt_H;user=web_usr;password=$password");

my $parser = Spreadsheet::ParseExcel->new();
my $book = $parser->parse($opt_i);

foreach my $sheet ($book->worksheets()) { 

}


my $measurement = $schema->resultset("Measurement")->create( {});


