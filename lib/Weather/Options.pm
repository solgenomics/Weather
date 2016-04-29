package Weather::Options;

use Moose;

use Data::Dumper;

has 'schema' => (isa => 'Weather::Schema',
		 is => 'rw',
		 required => 1,
);

has 'location' => ( isa => 'Str',
     is => 'rw',
     default => 'Namulonge',
    	required => 0,
);

has 'types' => (
     is => 'rw',
      required => 0,
);

sub get_locations {
  my $self = shift;
  my @locations;
  my $location_rows = $self->schema()->resultset("Location")->search( { } );
  print STDERR "Available Locations:\n";

  while (my $row = $location_rows->next()) {
    print STDERR "Location: " . $row->name() . "\n";
    print STDERR $row;
    push @locations, $row->name();
  }
  return \@locations;
}

sub get_types {
  my $self = shift;
  my @types;
	my @sensor_ids = $self->get_sensor_ids();

  print STDERR "Available Types:\n";

	my $q;
	if (@sensor_ids) {
  	$q = "SELECT cvterm.name, cvterm.description FROM measurement LEFT JOIN cvterm ON (measurement.type_id =cvterm.cvterm_id) WHERE measurement.sensor_id IN (@{[join',', ('?') x @sensor_ids]}) GROUP BY 1,2 ORDER BY 1,2";
	}

	my $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute(@sensor_ids);

  while (my ($type_name, $description) = $h->fetchrow_array()) {
    print STDERR "Typename: $type_name and description $description\n";
    push @types, [$type_name, $description];
  }
  return {
    types => \@types,
  };
}

sub get_dates {
	my $self = shift;
	my @sensor_ids = $self->get_sensor_ids();
	my @type_ids = $self->get_type_ids();

	print STDERR "Earliest and Latest dates:\n";

	my $q;
	if (@sensor_ids && @type_ids) {
  	$q = "SELECT min(time)::date, max(time)::date FROM measurement WHERE measurement.sensor_id IN (@{[join',', ('?') x @sensor_ids]}) AND measurement.type_id IN (@{[join',', ('?') x @type_ids]})";
	}
  my $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute(@sensor_ids, @type_ids);

  my ($earliest_date, $latest_date) = $h->fetchrow_array();
  print STDERR "Earliest: " . $earliest_date . "\n";
  print STDERR "Latest: " . $latest_date . "\n";

  return {
    earliest_date => $earliest_date,
    latest_date => $latest_date
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

sub get_type_ids {
	my $self = shift;
	my $types = $self->types();
	print STDERR "types = " . Dumper($types);
	my @type_ids;

	foreach my $type (@$types) {
		print STDERR "Looking up id of type $type\n";
		my $type_id_row = $self->schema()->resultset("Cvterm")->find( { name => $type });
		if (! $type_id_row) {
			return { error => "The type $type was not recognized\n" };
		}
		my $type_id = $type_id_row->cvterm_id();
		print STDERR "$type type id = $type_id\n";
		push @type_ids, $type_id;
	}

	print STDERR "Type ids = ".Dumper(\@type_ids);
	return @type_ids;

	#my $type_id_string = join (',', @type_ids);
  #print STDERR "Type id string: $type_id_string";
	#return $type_id_string;
}

1;
