
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

sub weather_data : Path('/rest/weather') Args(0) { 
    my $self = shift;
    my $c = shift;
    
    my $location = $c->req->param('location');
    my $start_date = $c->req->param('start_date');
    my $end_date = $c->req->param('end_date');
    my $interval = $c->req->param('interval');
    my $type = $c->req->param('type');

    my $wd = Weather::Data->new( 
	{ 
	    schema => $c->model("Schema")->schema(),
	    location => $location,
	    type => $type,
	    start_date => $start_date,
	    end_date => $end_date,
	    interval => $interval,
	});

    $c->stash->{rest} = $wd->get_data();
       
}

1;
