use sdk_ontology_jmc::sdk_ontology_jmcImpl;

use sdk_ontology_jmc::sdk_ontology_jmcServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = sdk_ontology_jmc::sdk_ontology_jmcImpl->new;
    push(@dispatch, 'sdk_ontology_jmc' => $obj);
}


my $server = sdk_ontology_jmc::sdk_ontology_jmcServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
