package HouseNewsWire::DB::ResultSet::Message;
use warnings;
use strict;
use base 'DBIx::Class::ResultSet';

sub unread_messages {
    my ( $self, $person_id ) = @_;

    # Select the first 100 messages that are not marked as read for the
    # given user.
    return $self->search(
        { 
            'messages_read.person_id' => [ undef, $person_id  ],
            'messages_read.is_read'   => [ undef, 0 ], 
        }, 
        { 
            order_by => { -desc => 'me.created_at' }, 
            rows => 100, 
            join => 'messages_read' 
        },
    )->all;
}

1;
