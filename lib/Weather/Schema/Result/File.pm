use utf8;
package Weather::Schema::Result::File;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::File

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<file>

=cut

__PACKAGE__->table("file");

=head1 ACCESSORS

=head2 file_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'file_file_id_seq'

=head2 filepath

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 filename

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 account_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "file_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "file_file_id_seq",
  },
  "filepath",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "account_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</file_id>

=back

=cut

__PACKAGE__->set_primary_key("file_id");

=head1 RELATIONS

=head2 account

Type: belongs_to

Related object: L<Weather::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "account",
  "Weather::Schema::Result::Account",
  { account_id => "account_id" },
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
  { "foreign.file_id" => "self.file_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-20 20:35:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HhQmaXseNd+w0GhVCF9H1g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
