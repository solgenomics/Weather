use utf8;
package Weather::Schema::Result::Detector;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::Detector

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<detector>

=cut

__PACKAGE__->table("detector");

=head1 ACCESSORS

=head2 detector_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'detector_detector_id_seq'

=head2 identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "detector_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "detector_detector_id_seq",
  },
  "identifier",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</detector_id>

=back

=cut

__PACKAGE__->set_primary_key("detector_id");

=head1 RELATIONS

=head2 stations

Type: has_many

Related object: L<Weather::Schema::Result::Station>

=cut

__PACKAGE__->has_many(
  "stations",
  "Weather::Schema::Result::Station",
  { "foreign.detector_id" => "self.detector_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-18 22:22:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V5IuUiMWPbtTe1YtF3FKOg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
