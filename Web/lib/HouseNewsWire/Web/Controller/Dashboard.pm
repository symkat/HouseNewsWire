package HouseNewsWire::Web::Controller::Dashboard;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/base') PathPart('dashboard') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    
    # Is there a valid user logged in?  - If not, send them to the login page.
    if ( ! $c->stash->{user} ) {
        $c->res->redirect( $c->uri_for_action('/get_login') );
        $c->detach;
    }
}

sub get_dashboard :Chained('base') PathPart('') Args(0) Method('GET') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'dashboard.tx';

    push @{$c->stash->{messages}}, 
        $c->model('DB')->resultset('Message')->unread_messages($c->stash->{user}->id);
}

sub post_dashboard_message :Chained('base') PathPart('') Args(1) Method('POST') {
    my ( $self, $c, $message_id ) = @_;

    $c->stash->{user}->create_related('messages_read', {
        message_id => $message_id,
    });

    $c->res->redirect( $c->uri_for_action( '/dashboard/get_dashboard' ) );
}

sub post_dashboard :Chained('base') PathPart('') Args(0) Method('POST') {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'dashboard.tx';

    # Get the message contents.
    my $message = $c->req->body_data->{message};

    # Store the message in the database.
    $c->stash->{user}->create_related( 'messages', {
        content => $message,
    });

    $c->res->redirect( $c->uri_for_action( '/dashboard/get_dashboard' ) );
}

__PACKAGE__->meta->make_immutable;
