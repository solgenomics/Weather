
use strict;

use Getopt::Std;
use Term::ReadKey;
use File::Basename;
use Spreadsheet::ParseExcel;
use lib 'lib/';
use Weather::Schema;

our($opt_H, $opt_D, $opt_U, $opt_i, $opt_l, $opt_s);
getopts('H:D:U:i:l:s:');

$opt_U ||= 'web_usr';

if (!$opt_i) { print "Need an input file (option -i).\n"; exit(); }
if (!$opt_l) { print "Location is required (option -l).\n"; exit(); }
print "Password for $opt_U for database $opt_D on host $opt_H: ";
ReadMode 'noecho';
my $password = ReadLine(0);
chomp($password);
ReadMode 'normal';
print "\n";

my $schema = Weather::Schema->connect("dbi:Pg:dbname=$opt_D;host=$opt_H;user=web_usr;password=$password");

my $basename = basename($opt_i);
my $filepath = dirname($opt_i);

$schema->txn_begin();

my $file_row = $schema->resultset("File")->find( { filename => $basename });

if ($file_row) { 
    print STDERR "The file $basename has already been loaded. Please load another file.\n";
    exit();
}

my $file_row = $schema->resultset("File")->create( 
    { 
	filename => $basename,
	filepath => $filepath,
    });

my $file_id = $file_row->file_id();

my $location_id;

my $location_row = $schema->resultset("Location")->find( { name => $opt_l });

if (!$location_row) { 
    print STDERR "Location $opt_l is not in the database. Insert? ";
    my $answer = (<STDIN>);
    chomp($answer);
    if ($answer =~ /^y/i) { 
	print STDERR "Inserting location $opt_l... ";
	$location_row = $schema->resultset("Location")->create(
	    { 
		name => $opt_l,
	    });
	print STDERR "Done.\n";
    }
    else { 
	print STDERR " Exiting.\n"; exit();
    }
    $location_id = $location_row->location_id();
}

my $temp_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'Temperature' }) ->cvterm_id();
my $rh_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'Relative Humidity'})->cvterm_id();
my $dp_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'Dew Point' } )->cvterm_id();
my $intensity_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'Intensity' })->cvterm_id();

my $precipitation_cvterm_id = $schema->resultset("Cvterm")->find_or_create({ name=> 'Precipitation' })->cvterm_id();

my $parser = Spreadsheet::ParseExcel->new();
my $book = $parser->parse($opt_i);

if (!$book) { 
    print STDERR "File $opt_i does not exist.\n";
    exit();
}

my @worksheets = $book->worksheets();
 
# parse first worksheet (Temp,RH,DP)
#
my $plot_title = $worksheets[0]->get_cell(0,0)->value();
print "plot title = $plot_title\n";
my $temp_sensor_sn_cell = $worksheets[0]->get_cell(1,2)->value();
my $temp_sensor_sn = get_serial_number($temp_sensor_sn_cell);
print STDERR "Temp sensor serial number: $temp_sensor_sn\n";

my $row = 2;
my $col = 0;



my $detector_row = $schema->resultset("Detector")->find_or_create( 
    { 
	identifier => $temp_sensor_sn,
    });

my $detector_id = $detector_row->detector_id();

my $station_name = $opt_s || $opt_l;

my $station_row = $schema->resultset("Station")->find_or_create(
    {
	name => $station_name,
	location_id => $location_id,
	detector_id => $detector_id,
    });

my $station_id = $station_row->station_id();

eval { 

    print STDERR "Inserting worksheet 1...\n";
    
    while (my $index_cell = $worksheets[0]->get_cell($row, $col)) {
	my $index = $index_cell->value();
	print STDERR "Cell value: $index\n";
	
	my $time_value;
	my $time_cell = $worksheets[0]->get_cell($row, $col + 1);
	if ($time_cell) { 
	    $time_value = $time_cell->value();	
	}
	else { 
	    print STDERR "This row ($row) does not have a time value. Skipping...\n";
	    next();
	}
	my $temp_value;
	my $temp_cell = $worksheets[0]->get_cell($row, $col + 2);
	if ($temp_cell) { 
	    $temp_value = $temp_cell->value();
	    insert_measurement($schema, $file_id, $temp_cvterm_id, $station_id, $time_value, $temp_value);
	}
	
	my $rh_value;
	my $rh_cell = $worksheets[0]->get_cell($row, $col + 3);
	if ($rh_cell) { 
	    $rh_value = $rh_cell->value();
	    insert_measurement($schema, $file_id, $rh_cvterm_id, $station_id, $time_value, $rh_value);
	}
	
	my $dp_value;
	my $dp_cell = $worksheets[0]->get_cell($row, $col + 4);
	if ($dp_cell) { 
	    $dp_value = $dp_cell->value();
	    insert_measurement($schema, $file_id, $dp_cvterm_id, $station_id,  $time_value, $dp_value);
	}
	$row++;
    }

    print STDERR "Inserting worksheet 2...\n";
    $row = 2; $col = 0;
    while (my $index_cell = $worksheets[1]->get_cell($row, $col)) { 
	my $index = $index_cell->value();
	
	my $time_cell = $worksheets[1]->get_cell($row, $col+1);
	my $time_value;
	if ($time_cell) { 
	    $time_value = $time_cell->value();
	}
	else { 
	    print STDERR "No time value for row $index. Skipping...\n";
	    next();
	}
	
	my $intensity_cell = $worksheets[1]->get_cell($row, $col+2);
	my $intensity_value;
	if ($intensity_cell) { 
	    $intensity_value = $intensity_cell->value();
	    insert_measurement($schema, $file_id, $intensity_cvterm_id, $station_id, $time_value, $intensity_value);
	}
	$row++;
    }
    
    print STDERR "Inserting Sheet 3...\n";
    $row =2, $col = 0;
    while (my $index_cell = $worksheets[2]->get_cell($row, $col)) { 
	my $index = $index_cell->value();
	print STDERR "Parse line $index...\n";
	my $time_cell = $worksheets[2]->get_cell($row, $col+1);
	my $time_value;
	if ($time_cell) { 
	    $time_value = $time_cell->value();
	}

	else { 
	    print STDERR "No time value for row $index. Skipping...\n";
	    next();
	}
	
	my $precipitation_value;
	my $precipitation_cell = $worksheets[2]->get_cell($row, $col+2);
	if ($precipitation_cell) { 
	    $precipitation_value = $precipitation_cell->value();
	    
	    insert_measurement($schema, $file_id, $precipitation_cvterm_id, $station_id, $time_value, $precipitation_value);
	    
	 
	}
	else { 
	    print STDERR "No value for precipitation on line $index. Skipping.\n";
	}
	$row++;
    }
    
};

if ($@) { 
    print STDERR "An error occurred during data loading.\n";
    $schema->txn_rollback();
}
else { 
    print STDERR "Committing... ";
    $schema->txn_commit();
    print STDERR "Done.\n";
} 


sub get_serial_number { 
    my $string = shift;
    $string =~  s/\SEN S\/N\: (.+)\)/$1/;
    my $sn = $1;
    return $1;
}


sub insert_measurement { 
    my $schema = shift;
    my $file_id = shift;
    my $cvterm_id = shift;
    my $station_id = shift;
    my $time = shift;
    my $value = shift;

    print STDERR "Inserting $value ($cvterm_id) at timepoint $time\n";
    my $temp_rs = $schema->resultset("Measurement")->create( 
	{ 
            time => $time,
	    type_id => $cvterm_id,
	    value => $value,
	    file_id => $file_id,
	    station_id => $station_id,
	});
    
    
}
