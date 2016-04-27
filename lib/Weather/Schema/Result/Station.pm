use utf8;
package Weather::Schema::Result::Station;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::Station

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<station>

=cut

__PACKAGE__->table("station");

=head1 ACCESSORS

=head2 station_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'station_station_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 coordinates

  data_type: 'point'
  is_nullable: 1

=head2 location_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "station_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "station_station_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "coordinates",
  { data_type => "point", is_nullable => 1 },
  "location_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</station_id>

=back

=cut

__PACKAGE__->set_primary_key("station_id");

=head1 RELATIONS

=head2 location

Type: belongs_to

Related object: L<Weather::Schema::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "Weather::Schema::Result::Location",
  { location_id => "location_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 measurements

Type: has_many

Related object: L<Weather::Schema::Result::Measurement>

=cut

__PACKAGE__->has_many(
  "measurements",
  "Weather::Schema::Result::Measurement",
  { "foreign.station_id" => "self.station_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-26 14:56:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t9Gtq/whjbDCQHfCkN876A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
