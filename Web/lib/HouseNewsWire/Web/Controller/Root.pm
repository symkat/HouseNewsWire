package HouseNewsWire::Web::Controller::Root;
use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub base :Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub index :Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

sub get_register :Chained('base') PathPart('register') Args(0) Method('GET') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'register.tx';
}

sub post_register :Chained('base') PathPart('register') Args(0) Method('POST') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'register.tx';

    my $email    = $c->req->body_data->{email};
    my $name     = $c->req->body_data->{name};
    my $password = $c->req->body_data->{password};
    my $confirm  = $c->req->body_data->{confirm};

    $c->stash->{form_email} = $email;
    $c->stash->{form_name}  = $name;

    # Make sure all fields are filled out.
    if ( ! ( $email && $name && $password && $confirm ) ) {
        push @{$c->stash->{errors}}, "All fields are required.";
    }

    # Make sure the password/confirm matches.
    if ( $password ne $confirm ) {
        push @{$c->stash->{errors}}, "Password and confirmation do not match.";
    }

    # Bail out if there are any errors.
    $c->detach if exists $c->stash->{errors};

    # Create the DB entry for the user and set their password.
    my $person = try {
        $c->model('DB')->schema->txn_do(sub {
            my $person = $c->model('DB')->resultset('Person')->create({
                email => $email,
                name  => $name,
            });
            $person->new_related( 'auth_password', {} )->set_password( $password );
            return $person;
        });
    } catch {
        # If there was an error creating the user, report it and then bail out.
        push @{$c->stash->{errors}}, "Account could not be created: $_";
        $c->detach;
    };

    $c->stash->{created} = 1;
}

sub end :ActionClass('RenderView') { }

__PACKAGE__->meta->make_immutable;
