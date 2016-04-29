
package Weather::Controller::Rest;

use Moose;

use Data::Dumper;
use List::Util qw | max min |;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );


use Weather::Data;
use Weather::Options;

sub weather_data : Path('/rest/weather') Args(0) {
    my $self = shift;
    my $c = shift;

    my $location = $c->req->param('location');
    my $start_date = $c->req->param('start_date');
    my $end_date = $c->req->param('end_date');
    my $interval = $c->req->param('interval');
    #my $restrict = $c->req->param('restrict');
    my @types = $c->req->param('types[]');

    my $wd = Weather::Data->new(
	{
	    schema => $c->model("Schema")->schema(),
	    location => $location,
	    types => \@types,
	    start_date => $start_date,
	    end_date => $end_date,
	    interval => $interval,
      #restrict => $restrict
	});

    $c->stash->{rest} = $wd->get_data();
    return;
}

sub weather_locations : Path('/rest/locations') Args(0) {
    my $self = shift;
    my $c = shift;

    my $wo = Weather::Options->new({
	    schema => $c->model("Schema")->schema()
	  });

    $c->stash->{rest} = $wo->get_locations();
    return;
}

sub weather_types : Path('/rest/types') Args(0) {
    my $self = shift;
    my $c = shift;
    my $location = $c->req->param('location');

    my $wo = Weather::Options->new({
	    schema => $c->model("Schema")->schema(),
	    location => $location
    });

    $c->stash->{rest} = $wo->get_types();
    return;
}

sub weather_daterange : Path('/rest/dates') Args(0) {
    my $self = shift;
    my $c = shift;
    my $location = $c->req->param('location');
    my @types = $c->req->param('types[]');
    print STDERR "rest types =" . @types . "\n";

    my $wo = Weather::Options->new({
	    schema => $c->model("Schema")->schema(),
	    location => $location,
      types => \@types
    });

    $c->stash->{rest} = $wo->get_dates();
    return;
}

1;
