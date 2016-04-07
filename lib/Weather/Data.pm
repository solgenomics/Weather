
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

has 'types' => (#isa => 'Array',
	       is => 'rw',
	       default => '["temperature", "intensity", "dew_point", "relative_humidity", "precipitation"]',
				 required => 1,
		);

has 'interval' => (isa => 'Str',
		   is => 'rw',
		   default => 'day',
    );



sub get_data {
    my $self = shift;

    print STDERR "Processing weather data: ". join ", ", ($self->start_date(), $self->end_date(), $self->location(), $self->types())."\n";

    my $location_row = $self->schema()->resultset("Location")->find({ name => $self->location() });
    if (!$location_row) {
			return { error => "Unknown location (".$self->location().")" };
    }

    my $station_id_rs = $self->schema()->resultset("Station")->search( { 'location.name' => $location_row->name() }, { join => 'location' });
    my @station_ids = map { $_->station_id() } $station_id_rs->all();

    print STDERR Dumper(\@station_ids);

    my $station_ids_str = join ", ", @station_ids;
		print STDERR "Station id string: $station_ids_str";

		my $interval = $self->interval();
		print STDERR "Interval = $interval \n";
		my $type_ref = $self->types();
		my @types = @$type_ref;
		print STDERR "Types = @types \n";
		my $values = {};
		my @stats;

		my $time_selects = {
			minutes => "time,",
			hours => "date_trunc('hour', time) AS time,",
			days => "date_trunc('day', time) AS time,"
		};

		my $value_selects = {
			temperature => " avg(value) as value",
			intensity => " avg(value) as value",
			dew_point => " avg(value) as value",
			relative_humidity => " avg(value) as value",
			precipitation => " sum(value) as value"
		};

		for my $type (@types) {
			my $type_row = $self->schema()->resultset("Cvterm")->find( { name => $type });
			if (! $type_row) {
				return { error => "The type $type is not recognized\n" };
			}
			my $type_id = $type_row->cvterm_id();
			print STDERR "TYPE_ID = $type_id\n";

			my $q = "SELECT " . $time_selects->{$interval} . $value_selects->{$type} . " FROM measurement WHERE time > ? AND time <= ? AND type_id=? AND station_id IN (?) GROUP BY 1 ORDER BY 1";
			print STDERR "Query for $type: $q\n";

			my $h = $self->schema()->storage()->dbh()->prepare($q);
    	$h->execute($self->start_date, $self->end_date, $type_id, $station_ids_str);

			my @measurements;
			while (my ($time, $value) = $h->fetchrow_array()) {
				push @measurements, { date => $time, value => $value };
    	}
			print STDERR "Measurements for $type: ".Dumper(\@measurements);

			my $summary_q = "SELECT min(value), max(value), avg(value), stddev(value), sum(value) FROM (" . $q . ") base_query";

			print STDERR "Summary query= $summary_q";

			$h = $self->schema()->storage()->dbh()->prepare($summary_q);
    	$h->execute($self->start_date, $self->end_date, $type_id, $station_ids_str);
			my ($min, $max, $average, $std_dev, $total) = $h->fetchrow_array();
			print STDERR "average for $type = $average \n";

			push @stats, [ $type, $min, $max, $average, $std_dev, $total];
			$values -> {$type} = \@measurements;
		}

		return {
			stats => \@stats,
			values => $values
    };

}

sub calculate_sun_rise_sun_set {
    my $class = shift;
    my $location_id = shift;

    my $schema = shift;

    my $type_row = $schema->resultset("Cvterm")->find( { name => "Intensity" });
    my $sunrise_row = $schema->resultset("Cvterm")->find( { name => "Sunrise" });
    my $sunset_row = $schema->resultset("Cvterm")->find( { name => "Sunset" });

    my $q = "SELECT time, value from measurement where location = ? and type_id = ?";


    my $h = $schema->storage()->dbh()->prepare($q);

    $h->execute($location_id, $type_row->cvterm_id());

    my $intensities = $h->fetchall_arrayref();

    my $event = "";
    my $previous_phase = "";
    foreach my $i (@$intensities) {
	my $current_phase = "";
	if ($i->[1] == 0) { $current_phase = "night"; }
	else {
	    $current_phase = "day";
	}
	if ( ($current_phase ne $previous_phase) && $current_phase eq "night") {
	    $event = "Sunset";
	}
	if ( ($current_phase ne $previous_phase) && $current_phase eq "day") {
	    $event = "Sunrise";
	}



    }

    my $uq = "UPDATE measurement set daylight=true WHERE time >= ? - extract(minute from '0:15'::Date) and time <= ?";
    my $qh  = $schema->storage()->dbh()->prepare($uq);

    print STDERR "\n";

}

sub day_length {
    my $self = shift;
    $self->set_type("intensity");
    my $data = $self->_get_data();




}

1;
