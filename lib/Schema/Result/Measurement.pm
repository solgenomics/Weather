use utf8;
package Schema::Result::Measurement;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Measurement

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

=head2 location

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
  "location",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</measurement_id>

=back

=cut

__PACKAGE__->set_primary_key("measurement_id");

=head1 RELATIONS

=head2 location

Type: belongs_to

Related object: L<Schema::Result::Location>

=cut

__PACKAGE__->belongs_to(
  "location",
  "Schema::Result::Location",
  { location_id => "location" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 type

Type: belongs_to

Related object: L<Schema::Result::Cvterm>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Schema::Result::Cvterm",
  { cvterm_id => "type_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-12-07 10:57:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rKQgtsV556+eTusLMMTWJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
