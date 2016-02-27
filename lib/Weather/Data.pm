
package Weather::Data;

use Moose;

use Data::Dumper;

has 'schema' => (isa => 'Weather::Schema',
		 is => 'rw',
		 required => 1,
    );

has 'start_date' => ( isa => 'Str',
		      is => 'rw',
		      required => 1,
    );

has 'location' => ( isa => 'Str',
		    is => 'rw',
		    required => 1,
    );

has 'end_date' => (isa => 'Str',
		   is => 'rw',
		   required => 1,
    );

has 'type' => (isa => 'Str',
	       is => 'rw',
	       default => 'Temperature',
    );

has 'interval' => (isa => 'Str',
		   is => 'rw',
		   default => 'day',
    );



sub get_data { 
    my $self = shift;
    
    print STDERR "Processing weather data: ". join ", ", ($self->start_date(), $self->end_date(), $self->location(), $self->type())."\n";
    
    my $location_row = $self->schema()->resultset("Location")->find({ name => $self->location() });
    if (!$location_row) { 
	return { error => "Unknown location (".$self->location().")" };
    }

    my $type_row = $self->schema()->resultset("Cvterm")->find( { name => $self->type() });
    if (! $type_row) { 
	return { error => "The type \'".$self->type()."\' is not recognized\n" };
    }
    my $type_id = $type_row->cvterm_id();

    print STDERR "TYPE_ID = $type_id\n";
    my $station_id_rs = $self->schema()->resultset("Station")->search( { 'location.name' => $location_row->name() }, { join => 'location' });

    my @station_ids = map { $_->station_id() } $station_id_rs->all();
	
    print STDERR Dumper(\@station_ids);

    my $station_ids_str = join ", ", @station_ids;

#    my $data = $c->model("Schema::Measurement")->search({ -and => [ 'time' => { '>' => $start_date }, 'time' => { '<' => $end_date} ], station_id => { -in => \@station_ids }}, { order_by => "extract(day from time)", columns => 'time', group_by => 'extract(day from time)' });

    my $aggregate_function = "";
    if ($self->type() eq "Temperature" || $self->type() eq "Relative Humidity" || $self->type() eq "Dew Point" || $self->type() eq "Intensity") { 
	$aggregate_function = "avg";
    }
    elsif ($self->type() eq "Precipitation") { 
	$aggregate_function = "sum";
    }
    else { 
	return{ error => "Type ".$self->type()." is unknown" };
    }
    
    my $q = "";

    if (!$self->interval() || $self->interval() eq "day") { 
	$q = "select extract(year from time), extract(month from time), extract (day from time), '0:00', min(value), max(value), $aggregate_function(value)  from measurement where time > ? and time <= ? and type_id=? and station_id in (?) group by extract(year from time), extract(month from time), extract(day from time) order by extract(year from time), extract(month from time), extract(day from time)";
    }
    elsif ($self->interval() eq "hour") { 
	$q = "select extract(year from time), extract(month from time), extract (day from time), extract(hour from time) || ':00', min(value), max(value), $aggregate_function(value)  from measurement where time > ? and time <= ? and type_id=? and station_id in (?) group by extract(year from time), extract(month from time), extract(day from time), extract(hour from time) order by extract(year from time), extract(month from time), extract(day from time), extract(hour from time)";
    }

    print STDERR "Query: $q\n";

    my $h = $self->schema()->storage()->dbh()->prepare($q);
    $h->execute($self->start_date, $self->end_date, $type_id, $station_ids_str);
    my @measurements;
    my $avg_max = 0;
    my @dates;
    my $index =0;
    while (my ($year, $month, $day, $time, $min, $max, $avg) = $h->fetchrow_array()) {
	if ($avg > $avg_max) { $avg_max = $avg; }
	push @measurements, { index => $index, name => "$year-$month-$day $time", value => $avg };
	push @dates, "$year-$month-$day $time";
	$index++;
    }	
    
    print STDERR "Measurements: ".Dumper(\@measurements);
    return { 
	data => \@measurements,
	domain_y => [ 0, $avg_max ],
	domain_x => [ @dates ],
    };

}

1;
