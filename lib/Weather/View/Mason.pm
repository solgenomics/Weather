
package Weather::View::Mason;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::HTML::Mason';

__PACKAGE__->config(
    template_extension => '.mas',
    interp_args => {
	comp_root => Weather->path_to('mason'),
    },
    );

1;
