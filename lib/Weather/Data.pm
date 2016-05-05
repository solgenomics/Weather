
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

		my $interval = $self->interval();
		#my $restrict = $self->restrict();
		print STDERR "Interval = $interval \n";
		#print STDERR "Restrict = $restrict \n";
		my $type_ref = $self->types();
		my @types = @$type_ref;
		my $start_date = $self->start_date();
		my $end_date = $self->end_date();
		print STDERR "Types = @types \n";
		my @sensor_ids = get_sensor_ids($self);

		my (@day_stats, @stats, $values, $metadata, $day_filter, %raw_hash);

=for comment
		if ($restrict eq 'day' || $restrict eq 'night') {
			my $day_stats_query =
				"SELECT date_trunc('day', time) AS day, min(time) AS sunrise, max(time) AS sunset, (max(time) - min(time)) AS daylength
				FROM measurement
				WHERE time > ? AND time <= ? AND type_id=? AND sensor_id IN (@{[join',', ('?') x @sensor_ids]}) AND value > 0
				GROUP BY 1 ORDER BY 1";

			my $intensity_row = $self->schema()->resultset("Cvterm")->find( { name => 'intensity' });
			if (! $intensity_row) {
				return { error => "The type intensity was not recognized\n" };
			}
			my $intensity_id = $intensity_row->cvterm_id();
			print STDERR "INTENSITY_ID = $intensity_id\n";

			my $h = $self->schema()->storage()->dbh()->prepare($day_stats_query);
			$h->execute($start_date, $end_date, $intensity_id, @sensor_ids);

			my (@day_ranges, $start);
			my $counter = 0;
			while (my ($day, $sunrise, $sunset, $daylength) = $h->fetchrow_array()) {
			#	push @day_stats, [$day, $sunrise, $sunset, $daylength];
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
		else { #if restrict is undefined and user wants all measurements
=cut
			 $day_filter = " time > '".$start_date."' AND time <= '".$end_date."' ";
		#}


		my $interval_selects = {
			individual => "time,",
			hourly => "date_trunc('hour', time) AS time,",
			daily => "date_trunc('day', time) AS time,"
		};

		my $value_selects = {
			temp => " avg(value) as value",
			i_temp => " avg(value) as value",
			r_temp => " avg(value) as value",
			intensity => " avg(value) as value",
			dp => " avg(value) as value",
			rh => " avg(value) as value",
			rain => " sum(value) as value",
			day_length => " avg(value) as value"
		};

		my $sigfig_selects = {
			temp => "'FM999999999.000'",
			i_temp => "'FM999999999.000'",
			r_temp => "'FM999999999.000'",
			intensity => "'FM999999999'",
			dp => "'FM999999999.000'",
			rh => "'FM999999999.000'",
			rain => "'FM999999999.0'",
			day_length => "'FM999999999'"
		};

		for my $type (@types) {
			my $type_row = $self->schema()->resultset("Cvterm")->find( { name => $type });
			if (! $type_row) {
				return { error => "The type $type is not recognized\n" };
			}
			my $type_id = $type_row->cvterm_id();
			my $unit = $type_row->unit();
			my $description = $type_row->description();
			my @cv_fields;
			push @cv_fields, { unit => $unit, description => $description, interval => $interval, location => $self->location(), start_date => $start_date, end_date => $end_date };
			$metadata -> {$type} = { unit => $unit, description => $description, interval => $interval, location => $self->location(), start_date => $start_date, end_date => $end_date };

			my $q = "SELECT " . $interval_selects->{$interval} . $value_selects->{$type} . " FROM measurement WHERE $day_filter AND type_id=? AND sensor_id IN (@{[join',', ('?') x @sensor_ids]}) GROUP BY 1 ORDER BY 1";
			print STDERR "Query for $type: $q\n";

			my $h = $self->schema()->storage()->dbh()->prepare($q);
			$h->execute($type_id, @sensor_ids);

			my @measurements;
			while (my ($time, $value) = $h->fetchrow_array()) {
				push @measurements, { date => $time, value => $value };
				%raw_hash -> {$type} -> {$time} = $value;
    	}

			my $summary_q = "SELECT to_char(min(value), $sigfig_selects->{$type}), to_char(max(value), $sigfig_selects->{$type}), to_char(avg(value), $sigfig_selects->{$type}), to_char(stddev(value), $sigfig_selects->{$type}), to_char(sum(value), $sigfig_selects->{$type}) FROM (" . $q . ") base_query";

			print STDERR "Summary query= $summary_q";

			$h = $self->schema()->storage()->dbh()->prepare($summary_q);
			$h->execute($type_id, @sensor_ids);
			my ($min, $max, $average, $std_dev, $total) = $h->fetchrow_array();
			print STDERR "average for $type = $average \n";

			push @stats, [ $description, $unit, $min, $max, $average, $std_dev, $total, $self->location(), $start_date, $end_date, $interval ];
			$values -> {$type} = \@measurements;
			%raw_hash -> {$type} -> {$type} = $description;
		}

		my @raw_data;
		my $first_hash_ref = $raw_hash{$types[0]};
		my %first_hash = %$first_hash_ref;
		my @times = sort keys %first_hash;

		foreach my $time (@times) {
			my @array;
			unless ($time =~ m/(\d+)/) { next;}
			my @value_strings = map { $raw_hash{$_}-> {$_} => $raw_hash{$_}->{$time} } @types;
			my %values_hash = %{{@value_strings}};
			push @array, $time;
			foreach my $key (sort (keys (%values_hash))) {
				push @array, $values_hash{$key};
			}
			print STDERR "array = @array \n";
			my $array_string = [join (',', @array)];
			push @raw_data, [ @array ];
		}

		print STDERR "STATS = ".Dumper(@stats)."\n";
		print STDERR "RAW DATA = ".Dumper(@raw_data)."\n";
		print STDERR "VALUES = ".Dumper($values)."\n";
		print STDERR "METADATA= ".Dumper($metadata)."\n";

		return {
			stats => \@stats,
			raw_data => \@raw_data,
			values => $values,
			metadata => $metadata
    };

}

sub get_sensor_ids {
	my $self = shift;
	my $location = $self->location();

	my $location_row = $self->schema()->resultset("Location")->find({ name => $self->location() });
	if (!$location_row) {
		return { error => "Unknown location (".$self->location().")" };
	}

	my $station_id_rs = $self->schema()->resultset("Station")->search( { 'location.name' => $location_row->name() }, { join => 'location' });
	my @station_ids = map { $_->station_id() } $station_id_rs->all();

	my @sensor_ids;
	foreach my $station_id (@station_ids) {
		my $sensor_id_rs = $self->schema()->resultset("Sensor")->search( { 'station.station_id' => $station_id }, { join => 'station' });
		@sensor_ids = map { $_->sensor_id() } $sensor_id_rs->all();
	}

	print STDERR "Sensor ids = ".Dumper(\@sensor_ids);
	return @sensor_ids;
}

1;
