use utf8;
package HouseNewsWire::DB::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

HouseNewsWire::DB::Result::Person

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'person_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'citext'
  is_nullable: 0

=head2 is_enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "person_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "citext", is_nullable => 0 },
  "is_enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<person_email_key>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("person_email_key", ["email"]);

=head1 RELATIONS

=head2 auth_password

Type: might_have

Related object: L<HouseNewsWire::DB::Result::AuthPassword>

=cut

__PACKAGE__->might_have(
  "auth_password",
  "HouseNewsWire::DB::Result::AuthPassword",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-04-20 17:25:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Rv8uvBGUNy+pz3+SJ+3GJg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
