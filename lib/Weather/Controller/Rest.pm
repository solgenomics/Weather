
package Weather::Controller::Rest;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON', 'text/html' => 'JSON' },
   );



sub weather_data : Path('/rest/weather') Args(0) { 
    my $self = shift;
    my $c = shift;
    
    my $location = $c->req->param('location');
    my $start_date = $c->req->param('start_date');
    my $end_date = $c->req->param('end_date');

    my $location_row = $c->model("Schema::Location")->find({ name => $location });
    if (!$location_row) { 
	$c->stash->{rest} = { error => "Unknown location ($location)" };
	return;
    }
	
    my $data = $c->model("Schema::Measurement")->search({ -and => [ 'time' => { '>' => $start_date }, 'time' => { '<' => $end_date} ], location_id => $location_row->location_id() }, { order_by => "time" });

    my @measurements;
    while (my $row = $data->next()) { 
	push @measurements, [ { name => $row->time(), value => $row->value() } ]; # add units
    }
    $c->stash->{rest} = { data => \@measurements };

}

1;
