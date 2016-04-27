use utf8;
package Weather::Schema::Result::Sensor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::sensor

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sensor>

=cut

__PACKAGE__->table("sensor");

=head1 ACCESSORS

=head2 sensor_id

  data_type: 'integer'
  is_nullable: 0

=head2 station_id

  data_type: 'integer'
  is_foreign_key: 1,
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "sensor_id",
  {
    data_type         => "integer",
    is_nullable       => 0,
  },
  "station_id",
  {
    data_type         => "integer",
    is_nullable       => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</sensor_id>

=back

=cut

__PACKAGE__->set_primary_key("sensor_id");

=head1 RELATIONS

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

# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-18 22:22:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V5IuUiMWPbtTe1YtF3FKOg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
