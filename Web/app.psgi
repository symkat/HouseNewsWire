#!/usr/bin/env perl
use strict;
use warnings;
use HouseNewsWire::Web;

my $app = HouseNewsWire::Web
    ->apply_default_middlewares(HouseNewsWire::Web->psgi_app);
$app;
