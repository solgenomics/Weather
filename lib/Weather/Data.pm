
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

has 'types' => (
	       is => 'rw',
				 required => 1,
		);

has 'interval' => (isa => 'Str',
		   is => 'rw',
		   default => 'minutes',
    );

has 'restrict' => (isa => 'Str',
				is => 'rw',
				default => 'both',
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
		my $restrict = $self->restrict();
		print STDERR "Interval = $interval \n";
		print STDERR "Restrict = $restrict \n";
		my $type_ref = $self->types();
		my @types = @$type_ref;
		print STDERR "Types = @types \n";
		my (@day_stats, @stats, $values, $day_filter);

		if ($restrict eq 'day' || $restrict eq 'night') {
			my $day_stats_query =
				"SELECT date_trunc('day', time) AS day, min(time) AS sunrise, max(time) AS sunset, (max(time) - min(time)) AS daylength
				FROM measurement
				WHERE time > ? AND time <= ? AND type_id=? AND station_id IN (?) AND value > 0
				GROUP BY 1 ORDER BY 1";

			my $intensity_row = $self->schema()->resultset("Cvterm")->find( { name => 'intensity' });
			if (! $intensity_row) {
				return { error => "The type intensity was not recognized\n" };
			}
			my $intensity_id = $intensity_row->cvterm_id();
			print STDERR "INTENSITY_ID = $intensity_id\n";

			my $h = $self->schema()->storage()->dbh()->prepare($day_stats_query);
			$h->execute($self->start_date, $self->end_date, $intensity_id, $station_ids_str);

			my (@day_ranges, $start);
			my $counter = 0;
			while (my ($day, $sunrise, $sunset, $daylength) = $h->fetchrow_array()) {
				push @day_stats, [$day, $sunrise, $sunset, $daylength];
				if ($restrict eq 'day') {
					push @day_ranges, "(time >= '".$sunrise."' AND time <= '".$sunset."')";
				}
				elsif ($restrict eq 'night') {
					unless ($counter < 1) {
						push @day_ranges, " (time > '".$start."' AND time < '".$sunrise."') ";
					}
					$start = $sunset;
					$counter++;
				}
			}
			$day_filter = "(". join('OR', @day_ranges) . ")";
			print STDERR "day filter = $day_filter \n";
		}
		else {
			 $day_filter = " time > '".$self->start_date."' AND time <= '".$self->end_date."' ";
		}


		my $interval_selects = {
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

		my $sigfig_selects = {
			temperature => "'FM999999999.000'",
			intensity => "'FM999999999'",
			dew_point => "'FM999999999.000'",
			relative_humidity => "'FM999999999.000'",
			precipitation => "'FM999999999.0'"
		};

		for my $type (@types) {
			my $type_row = $self->schema()->resultset("Cvterm")->find( { name => $type });
			if (! $type_row) {
				return { error => "The type $type is not recognized\n" };
			}
			my $type_id = $type_row->cvterm_id();
			print STDERR "TYPE_ID = $type_id\n";

			#my $q = "SELECT " . $interval_selects->{$interval} . $value_selects->{$type} . " FROM measurement WHERE time > ? AND time <= ? AND type_id=? AND station_id IN (?) GROUP BY 1 ORDER BY 1";
			my $q = "SELECT " . $interval_selects->{$interval} . $value_selects->{$type} . " FROM measurement WHERE $day_filter AND type_id=? AND station_id IN (?) GROUP BY 1 ORDER BY 1";
			print STDERR "Query for $type: $q\n";

			my $h = $self->schema()->storage()->dbh()->prepare($q);
    	#$h->execute($self->start_date, $self->end_date, $type_id, $station_ids_str);
			$h->execute($type_id, $station_ids_str);

			my @measurements;
			while (my ($time, $value) = $h->fetchrow_array()) {
				push @measurements, { date => $time, value => $value };
    	}
			print STDERR "Measurements for $type: ".Dumper(\@measurements);

			my $summary_q = "SELECT to_char(min(value), $sigfig_selects->{$type}), to_char(max(value), $sigfig_selects->{$type}), to_char(avg(value), $sigfig_selects->{$type}), to_char(stddev(value), $sigfig_selects->{$type}), to_char(sum(value), $sigfig_selects->{$type}) FROM (" . $q . ") base_query";

			print STDERR "Summary query= $summary_q";

			$h = $self->schema()->storage()->dbh()->prepare($summary_q);
    	#$h->execute($self->start_date, $self->end_date, $type_id, $station_ids_str);
			$h->execute($type_id, $station_ids_str);
			my ($min, $max, $average, $std_dev, $total) = $h->fetchrow_array();
			print STDERR "average for $type = $average \n";

			push @stats, [ $type, $min, $max, $average, $std_dev, $total];
			$values -> {$type} = \@measurements;
		}

		return {
			day_stats => \@day_stats,
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
