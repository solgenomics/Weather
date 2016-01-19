use utf8;
package Weather::Schema::Result::Location;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::Location

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<location>

=cut

__PACKAGE__->table("location");

=head1 ACCESSORS

=head2 location_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'location_location_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 geolocation

  data_type: 'point'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "location_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "location_location_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "geolocation",
  { data_type => "point", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</location_id>

=back

=cut

__PACKAGE__->set_primary_key("location_id");

=head1 RELATIONS

=head2 measurements

Type: has_many

Related object: L<Weather::Schema::Result::Measurement>

=cut

__PACKAGE__->has_many(
  "measurements",
  "Weather::Schema::Result::Measurement",
  { "foreign.location" => "self.location_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-18 22:22:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JcTmuR5L7LwAtU1eVZfBdg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
