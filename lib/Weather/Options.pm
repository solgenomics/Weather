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
	my $station_id_string = $self->get_station_ids();

  print STDERR "Available Types:\n";

  my $q = "SELECT cvterm.name FROM measurement LEFT JOIN cvterm ON (measurement.type_id =cvterm.cvterm_id) WHERE measurement.station_id IN (?) GROUP BY 1 ORDER BY 1";
  my $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute($station_id_string);

  while (my $type = $h->fetchrow_array()) {
    print STDERR "Type: " . $type . "\n";
    push @types, $type;
  }
  return {
    types => \@types,
  };
}

sub get_dates {
	my $self = shift;
	my $station_id_string = $self->get_station_ids();
	my $type_id_string = $self->get_type_ids();

	print STDERR "Earliest and Latest dates:\n";

  my$q = "SELECT min(time)::date, max(time)::date FROM measurement WHERE measurement.station_id IN (?) AND measurement.type_id IN (?)";
  my $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute($station_id_string,$type_id_string);

  my ($earliest_date, $latest_date) = $h->fetchrow_array();
  print STDERR "Earliest: " . $earliest_date . "\n";
  print STDERR "Latest: " . $latest_date . "\n";

  return {
    earliest_date => $earliest_date,
    latest_date => $latest_date
  };

}

sub get_station_ids {
	my $self = shift;
	my $location = $self->location();

	my $station_id_rs = $self->schema()->resultset("Station")->search( { 'location.name' => $location }, { join => 'location' });
  my @station_ids = map { $_->station_id() } $station_id_rs->all();
  print STDERR Dumper(\@station_ids);
  my $station_id_string = join ", ", @station_ids;
  print STDERR "Station id string: $station_id_string";
	return $station_id_string;
}

sub get_type_ids {
	my $self = shift;
	my @types = $self->types();
	print STDERR "types = " . Dumper(@types);
	my @type_ids;

	foreach my $type (@types) {
		my $type_id_rs = $self->schema()->resultset("Cvterm")->find( { name => $type });
		if (! $type_id_rs) {
			return { error => "The type intensity was not recognized\n" };
		}
		my $type_id = $type_id_rs->cvterm_id();
		print STDERR "$type type id = $type_id\n";
		push @type_ids, $type_id;
	}

	my $type_id_string = join (',', @type_ids);
  print STDERR "Type id string: $type_id_string";
	return $type_id_string;
}

1;
