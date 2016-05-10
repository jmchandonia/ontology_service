use sdk_ontology::sdk_ontologyImpl;

use sdk_ontology::sdk_ontologyServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = sdk_ontology::sdk_ontologyImpl->new;
    push(@dispatch, 'sdk_ontology' => $obj);
}


my $server = sdk_ontology::sdk_ontologyServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
