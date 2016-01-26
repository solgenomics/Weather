use utf8;
package Weather::Schema::Result::Measurement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::Measurement

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<measurement>

=cut

__PACKAGE__->table("measurement");

=head1 ACCESSORS

=head2 measurement_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'measurement_measurement_id_seq'

=head2 coordinates

  data_type: 'point'
  is_nullable: 1

=head2 time

  data_type: 'timestamp'
  is_nullable: 1

=head2 type_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 value

  data_type: 'real'
  is_nullable: 1

=head2 file_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 station_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "measurement_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "measurement_measurement_id_seq",
  },
  "coordinates",
  { data_type => "point", is_nullable => 1 },
  "time",
  { data_type => "timestamp", is_nullable => 1 },
  "type_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "value",
  { data_type => "real", is_nullable => 1 },
  "file_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "station_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</measurement_id>

=back

=cut

__PACKAGE__->set_primary_key("measurement_id");

=head1 RELATIONS

=head2 file

Type: belongs_to

Related object: L<Weather::Schema::Result::File>

=cut

__PACKAGE__->belongs_to(
  "file",
  "Weather::Schema::Result::File",
  { file_id => "file_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 station

Type: belongs_to

Related object: L<Weather::Schema::Result::Station>

=cut

__PACKAGE__->belongs_to(
  "station",
  "Weather::Schema::Result::Station",
  { station_id => "station_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 type

Type: belongs_to

Related object: L<Weather::Schema::Result::Cvterm>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Weather::Schema::Result::Cvterm",
  { cvterm_id => "type_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-26 14:56:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RXNMoinG32XBGtmmQ1yZpA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
