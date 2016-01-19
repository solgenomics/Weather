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

=head2 detector_id

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
  "detector_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</station_id>

=back

=cut

__PACKAGE__->set_primary_key("station_id");

=head1 RELATIONS

=head2 detector

Type: belongs_to

Related object: L<Weather::Schema::Result::Detector>

=cut

__PACKAGE__->belongs_to(
  "detector",
  "Weather::Schema::Result::Detector",
  { detector_id => "detector_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-18 22:22:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vp+ok1L5/ZYJtLZmmWwUrw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
