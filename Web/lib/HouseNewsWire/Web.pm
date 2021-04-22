package HouseNewsWire::Web;
use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;
use Catalyst qw| -Debug Static::Simple |;
extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name                   => 'HouseNewsWire::Web',
    enable_catalyst_header => 1,       # Send X-Catalyst header
    encoding               => 'UTF-8', # Setup request decoding and response encoding
);

__PACKAGE__->config(
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,

);

__PACKAGE__->config(
    'View::Xslate' => {
        path   => [qw( root )],
        suffix => 'tx',
        syntax => 'Metakolon',
    },
);

__PACKAGE__->setup(); # Start the webapp.