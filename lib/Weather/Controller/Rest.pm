
package Weather::Controller::Rest;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );



sub weather_data : Path('/weather') Args(0) { 
    my $self = shift;
    my $c = shift;
    
    my $location = $c->req->param('location');
    my $station  = $c->req->param('station');
    my $start_date = $c->req->param('start_date');
    my $end_date = $c->req->param('end_date');

    $c->stash->{rest} = { message => 'hello world' };

}

1;
