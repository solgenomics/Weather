use utf8;
package Weather::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Weather::Schema::Result::Account

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<account>

=cut

__PACKAGE__->table("account");

=head1 ACCESSORS

=head2 account_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'account_account_id_seq'

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 last_access

  data_type: 'timestamp'
  is_nullable: 1

=head2 cookie_string

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "account_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "account_account_id_seq",
  },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "last_access",
  { data_type => "timestamp", is_nullable => 1 },
  "cookie_string",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</account_id>

=back

=cut

__PACKAGE__->set_primary_key("account_id");

=head1 RELATIONS

=head2 files

Type: has_many

Related object: L<Weather::Schema::Result::File>

=cut

__PACKAGE__->has_many(
  "files",
  "Weather::Schema::Result::File",
  { "foreign.account_id" => "self.account_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2016-01-20 20:35:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9h9ID+vGsQDRUlEcKhkm5w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
