
=head1 NAME

load_weather.pl - load the weather data from small weather stations

=head1 DESCRIPTION

perl load_weather.pl -H <hostname> -D <database_name> -U <database_user> -i <input_file.xls> -l <location>

Options:

=over 5

=item -H

hostname

=item -D

database name

=item -U

database user

=item -i

input file name (xls format)

=item -l

location name

=item -s

station name (optional)

=back


=head1


=cut

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
else {
  $location_id = $location_row->location_id();
}

my $temp1_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'temp', unit => '°C', description =>'Temperature'}) ->cvterm_id();
my $temp2_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'temp_intensity_sensor', unit => '°C', description =>'Temperature from Intensity Sensor'}) ->cvterm_id();
my $temp3_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'temp_rain_sensor', unit => '°C', description =>'Temperature from Precipitation Sensor'}) ->cvterm_id();
my $rh_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'rh', unit => '%', description =>'Relative Humidity'})->cvterm_id();
my $dp_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'dp', unit => '°C', description =>'Dew Point' } )->cvterm_id();
my $intensity_cvterm_id = $schema->resultset("Cvterm")->find_or_create( { name => 'intensity', unit => 'LUX', description =>'Intensity' })->cvterm_id();
my $precipitation_cvterm_id = $schema->resultset("Cvterm")->find_or_create({ name=> 'rain', unit => 'mm', description =>'Precipitation' })->cvterm_id();
my $daylength_cvterm_id = $schema->resultset("Cvterm")->find_or_create({ name=> 'day_length' unit => 'hrs', description =>'Day Length' })->cvterm_id();


my $parser = Spreadsheet::ParseExcel->new();
my $book = $parser->parse($opt_i);

if (!$book) {
    print STDERR "File $opt_i does not exist.\n";
    exit();
}

#get worksheets

$worksheet1 = $book->worksheet('Temp,RH,DP');
if (!$worksheet1) {
    print STDERR "Temp,RH,DP sheet not found in workbook.\n";
}
$worksheet2 = $book->worksheet('Temp,Intensity');
if (!$worksheet2) {
    print STDERR "Temp,Intensity sheet not found in workbook.\n";
}
$worksheet3 = $book->worksheet('Temp,Rain');
if (!$worksheet3) {
    print STDERR "Temp,Rain sheet not found in workbook.\n";
}

#get sensor ids and find or create station
my @sensors;
if ($worksheet1) { push @sensors, $worksheet1->get_cell(1,2)->value(); }
if ($worksheet2) { push @sensors, $worksheet2->get_cell(1,2)->value(); }
if ($worksheet3) { push @sensors, $worksheet3->get_cell(1,2)->value(); }

my $station_exists;

SENSOR: foreach my $sensor (@sensors) {
  my $sensor_row = $self->schema()->resultset("Sensor")->find( { sensor_id => $sensor });
  my $station_id = $sensor_row->station_id();
  print STDERR "sensor_id = $sensor and station_id = $station_id) \n";
  if ($station_id) {
    $station_exists =1;
    last SENSOR;
  }
}

unless ($station_exists) {
  if ($opt_s) {
    my $station_row = $schema->resultset("Station")->find_or_create(
        {
          name => $opt_s,
    	    location_id => $location_id
        });
  }
  else {
    my $station_row = $schema->resultset("Station")->find_or_create(
        {
  	      location_id => $location_id,
        });
  }
  $station_id = $station_row->station_id();
}

# parse first worksheet (Temp,RH,DP)

my $plot_title = $worksheet1->get_cell(0,0)->value();
print "plot title = $plot_title\n";
my $rh_sensor_sn_cell = $worksheet1->get_cell(1,2)->value();
my $sensor_id = get_serial_number($rh_sensor_sn_cell);
print STDERR "Temp,RH,DP sensor serial number: $sensor_id\n";

my $row = 2;
my $col = 0;

my $sensor_row = $schema->resultset("Sensor")->find_or_create(
    {
	     sensor_id => $sensor_id,
       station_id => $station_id
    });

eval {

    print STDERR "Loading values from Temp,RH,DP worksheet\n";

    while (my $index_cell = $worksheet1->get_cell($row, $col)) {
	my $index = $index_cell->value();
	print STDERR "Cell value: $index\n";

	my $time_value;
	my $time_cell = $worksheet1->get_cell($row, $col + 1);
	if ($time_cell) {
	    $time_value = $time_cell->value();
	}
	else {
	    print STDERR "This row ($row) does not have a time value. Skipping...\n";
	    next();
	}
	my $temp_value;
	my $temp_cell = $worksheet1->get_cell($row, $col + 2);
	if ($temp_cell) {
	    $temp_value = $temp_cell->value();
	    insert_measurement($schema, $file_id, $temp1_cvterm_id, $sensor_id, $time_value, $temp_value);
	}

	my $rh_value;
	my $rh_cell = $worksheet1->get_cell($row, $col + 3);
	if ($rh_cell) {
	    $rh_value = $rh_cell->value();
	    insert_measurement($schema, $file_id, $rh_cvterm_id, $sensor_id, $time_value, $rh_value);
	}

	my $dp_value;
	my $dp_cell = $worksheet1->get_cell($row, $col + 4);
	if ($dp_cell) {
	    $dp_value = $dp_cell->value();
	    insert_measurement($schema, $file_id, $dp_cvterm_id, $sensor_id,  $time_value, $dp_value);
	}
	$row++;
    }

    print STDERR "Loading values from Temp,Intensity worksheet\n";
    $row = 2; $col = 0;

    my $intensity_sensor_sn_cell = $worksheet2->get_cell(1,2)->value();
    my $sensor_id = get_serial_number($intensity_sensor_sn_cell);
    print STDERR "Temp,Intensity sensor serial number: $sensor_id\n";

    my $row = 2;
    my $col = 0;

    my $sensor_row = $schema->resultset("Sensor")->find_or_create(
        {
    	     sensor_id => $sensor_id,
           station_id => $station_id
        });


  my ($start_time, $end_time);
  my $start_time_counter = 0;

    while (my $index_cell = $worksheet2->get_cell($row, $col)) {
	my $index = $index_cell->value();

	my $time_cell = $worksheet2->get_cell($row, $col+1);
	my $time_value;
	if ($time_cell) {
	    $time_value = $time_cell->value();
	}
	else {
	    print STDERR "No time value for row $index. Skipping...\n";
	    next();
	}

  my $temp_value;
  my $temp_cell = $worksheet2->get_cell($row, $col + 2);
  if ($temp_cell) {
      $temp_value = $temp_cell->value();
      insert_measurement($schema, $file_id, $temp2_cvterm_id, $sensor_id, $time_value, $temp_value);
  }

	my $intensity_cell = $worksheet2->get_cell($row, $col+3);
	my $intensity_value;
	if ($intensity_cell) {
	    $intensity_value = $intensity_cell->value();
      if ($intensity_value == 0 && $start_time_counter < 3) {
        $start_time = $time_value;
        $start_time_counter++;
      }
	    insert_measurement($schema, $file_id, $intensity_cvterm_id, $sensor_id, $time_value, $intensity_value);
	}
	$row++;
    }

    my($min_row, $max_row) = $worksheet2->row_range();
    while (my $index_cell = $worksheet2->get_cell($max_row, $col)) {
      my $index = $index_cell->value();

      my $time_cell = $worksheet2->get_cell($row, $col+1);
      my $time_value;
    	if ($time_cell) {
    	    $time_value = $time_cell->value();
    	}
    	else {
    	    print STDERR "No time value for row $index. Skipping...\n";
    	    next();
    	}
      my $intensity_cell = $worksheet2->get_cell($row, $col+3);
    	my $intensity_value;
    	if ($intensity_cell) {
    	  $intensity_value = $intensity_cell->value();
        if ($intensity_value == 0) {
          $end_time = $time_value;
          last();
        }
      }
      $max_row--;
    }

    insert_daylengths($start_time, $end_time, $intensity_cvterm_id, $sensor_id);

    print STDERR "Loading values from Temp,Rain worksheet\n";
    $row =2, $col = 0;

    my $rain_sensor_sn_cell = $worksheet2->get_cell(1,2)->value();
    my $sensor_id = get_serial_number($rain_sensor_sn_cell);
    print STDERR "Temp,Rain sensor serial number: $sensor_id\n";

    my $row = 2;
    my $col = 0;

    my $sensor_row = $schema->resultset("Sensor")->find_or_create(
        {
    	     sensor_id => $sensor_id,
           station_id => $station_id
        });

    while (my $index_cell = $worksheet3->get_cell($row, $col)) {
	my $index = $index_cell->value();
	print STDERR "Parse line $index...\n";
	my $time_cell = $worksheet3->get_cell($row, $col+1);
	my $time_value;
	if ($time_cell) {
	    $time_value = $time_cell->value();
	}

	else {
	    print STDERR "No time value for row $index. Skipping...\n";
	    next();
	}

  my $temp_value;
  my $temp_cell = $worksheet3->get_cell($row, $col + 2);
  if ($temp_cell) {
      $temp_value = $temp_cell->value();
      insert_measurement($schema, $file_id, $temp3_cvterm_id, $sensor_id, $time_value, $temp_value);
  }

	my $precipitation_value;
  my $old_precipitation_value =0;
	my $precipitation_cell = $worksheet3->get_cell($row, $col+3);
	if ($precipitation_cell) {
	    $precipitation_value = $precipitation_cell->value();

	    $precipitation_value = $precipitation_value - $old_precipitation_value;
      print STDERR " insterting precip value $precipitation_value . . .\n";
	    insert_measurement($schema, $file_id, $precipitation_cvterm_id, $sensor_id, $time_value, $precipitation_value);

	    $old_precipitation_value = $precipitation_value;

	}
	else {
	    print STDERR "No value for preciptation... adding 0.\n";
	    insert_measurement($schema, $file_id, $precipitation_cvterm_id, $sensor_id, $time_value, 0);
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
    my $sensor_id = shift;
    my $time = shift;
    my $value = shift;

    print STDERR "Inserting $value ($cvterm_id) at timepoint $time\n";
    my $temp_rs = $schema->resultset("Measurement")->create(
	{
      time => $time,
	    type_id => $cvterm_id,
	    value => $value,
	    file_id => $file_id,
	    sensor_id => $sensor_id,
	});
}

sub check_unique {
  my %check_unique_db;
  my $sql = "SELECT value, cvalue_id, uniquename FROM phenotype WHERE value is not NULL; ";
  my $sth = $c->dbc->dbh->prepare($sql);
  $sth->execute();
  while (my ($db_value, $db_cvalue_id, $db_uniquename) = $sth->fetchrow_array) {
	  my ($stock_string, $rest_of_name) = split( /,/, $db_uniquename);
	  $check_unique_db{$db_value, $db_cvalue_id, $stock_string}  = 1;
  }

  if (exists($check_unique_db{$trait_value, $trait_cvterm_id, "Stock: ".$stock_id})) {
	 $warning_message = $warning_message."<small>This combination exists in database: <br/>Plot Name: ".$plot_name."<br/>Trait Name: ".$trait_name."<br/>Value: ".$trait_value."</small><hr>";
  }
}

sub insert_daylengths {
  my $start_time = shift;
  print STDERR "Start time = $start_time\n";
  my $end_time = shift;
  print STDERR "End time = $end_time\n";
  my $intensity_cvterm_id = shift;
  print STDERR "Intensity cvterm_id = $intensity_cvterm_id\n";
  my $sensor_id = shift;
  print STDERR "Sensor_id = $sensor_id\n";

  my $day_stats_query =
    "SELECT date_trunc('day', time) AS day, (max(time) - min(time)) AS daylength
    FROM measurement
    WHERE time > ? AND time <= ? AND type_id=? AND sensor_id IN (?) AND value > 0
    GROUP BY 1 ORDER BY 1";

  my $h = $self->schema()->storage()->dbh()->prepare($day_stats_query);
  $h->execute($start_time, $end_time, $intensity_cvterm_id, $sensor_id);

  while (my ($day, $daylength) = $h->fetchrow_array()) {
    print STDERR " insterting calulated daylength $daylength . . .\n";
	  insert_measurement($schema, $file_id, $daylength_cvterm_id, $sensor_id, $day, $daylength);
  }
  print STDERR "daylength insert finished!\n";
}
