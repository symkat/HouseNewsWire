package HouseNewsWire::Web::Controller::Root;
use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub base :Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Check if we have a session.
    if ( exists $c->session->{uid} ) {
        # Find the user account for the session.
        my $person = $c->model('DB')->resultset('Person')->find( $c->session->{uid} );

        # If the user account exists and is enabled, then store the user in the stash.
        if ( $person && $person->is_enabled ) {
            $c->stash->{user} = $person;
        }
    }
}

sub index :Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
}

sub get_dashboard :Chained('base') PathPart('dashboard') Args(0) Method('GET') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'dashboard.tx';

    # Is there a valid user logged in?  - If not, send them to the login page.
    if ( ! $c->stash->{user} ) {
        $c->res->redirect( $c->uri_for_action('/get_login') );
        $c->detach;
    }

    # Push the 100 latest posts into the stash.
    push @{$c->stash->{messages}}, $c->model('DB')->resultset('Message')->search( 
        {},
        { order_by => { -desc => 'me.created_at' }, rows => 100 }
    )->all;

}

sub post_dashboard :Chained('base') PathPart('dashboard') Args(0) Method('POST') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'dashboard.tx';
    
    # Is there a valid user logged in?  - If not, send them to the login page.
    if ( ! $c->stash->{user} ) {
        $c->res->redirect( $c->uri_for_action('/get_login') );
        $c->detach;
    }

    # Get the message contents.
    my $message = $c->req->body_data->{message};

    # Store the message in the database.
    $c->stash->{user}->create_related( 'messages', {
        content => $message,
    });

    $c->res->redirect( $c->uri_for_action( '/get_dashboard' ) );
}


sub get_login :Chained('base') PathPart('login') Args(0) Method('GET') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'login.tx';

}

sub post_login :Chained('base') PathPart('login') Args(0) Method('POST') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'login.tx';

    # Get the email and password values.
    my $email    = $c->req->body_data->{email};
    my $password = $c->req->body_data->{password};

    # Try to load the user account, otherwise add an error.
    my $person = $c->model('DB')->resultset('Person')->find( { email => $email } )
        or push @{$c->stash->{errors}}, "Invalid email address or password.";

    # Do not continue if there are errors.
    $c->detach if $c->stash->{errors};

    # Check the password supplied matches, otherwise add an error.
    $person->auth_password->check_password( $password )
        or push @{$c->stash->{errors}}, "Invalid email address or password.";
    
    # Do not continue if there are errors.
    $c->detach if $c->stash->{errors};

    # Store the user id in the session.
    $c->session->{uid} = $person->id;
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

    # Send the user to the dashboard once they have made an account.
    $c->res->redirect( $c->uri_for_action( '/get_dashboard' ) );
}

sub end :ActionClass('RenderView') { }

__PACKAGE__->meta->make_immutable;
