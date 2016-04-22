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

sub get_types_and_dates {
  my $self = shift;
  my $location = $self->location();
  my @types;

  my $station_id_rs = $self->schema()->resultset("Station")->search( { 'location.name' => $location }, { join => 'location' });
  my @station_ids = map { $_->station_id() } $station_id_rs->all();
  print STDERR Dumper(\@station_ids);
  my $station_ids_str = join ", ", @station_ids;
  print STDERR "Station id string: $station_ids_str";

  print STDERR "Available Types at location $location:\n";

  my $q = "SELECT cvterm.name FROM measurement LEFT JOIN cvterm ON (measurement.type_id =cvterm.cvterm_id) WHERE measurement.station_id IN (?) GROUP BY 1 ORDER BY 1";
  my $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute($station_ids_str);

  while (my $type = $h->fetchrow_array()) {
    print STDERR "Type: " . $type . "\n";
    push @types, $type;
  }

  print STDERR "Earliest and Latest dates at location $location:\n";

  $q = "SELECT min(time)::date, max(time)::date FROM measurement WHERE measurement.station_id IN (?)";
  $h = $self->schema()->storage()->dbh()->prepare($q);
  $h->execute($station_ids_str);

  my ($earliest_date, $latest_date) = $h->fetchrow_array();
  print STDERR "Earliest: " . $earliest_date . "\n";
  print STDERR "Latest: " . $latest_date . "\n";

  return {
    types => \@types,
    earliest_date => $earliest_date,
    latest_date => $latest_date
  };
}

1;
