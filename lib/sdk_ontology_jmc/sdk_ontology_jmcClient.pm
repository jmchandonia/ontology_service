package sdk_ontology_jmc::sdk_ontology_jmcClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

sdk_ontology_jmc::sdk_ontology_jmcClient

=head1 DESCRIPTION


A KBase module: sdk_ontology_dk


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => sdk_ontology_jmc::sdk_ontology_jmcClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my %arg_hash2 = @args;
	if (exists $arg_hash2{"token"}) {
	    $self->{token} = $arg_hash2{"token"};
	} elsif (exists $arg_hash2{"user_id"}) {
	    my $token = Bio::KBase::AuthToken->new(@args);
	    if (!$token->error_message) {
	        $self->{token} = $token->token;
	    }
	}
	
	if (exists $self->{token})
	{
	    $self->{client}->{token} = $self->{token};
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 list_ontology_terms

  $output = $obj->list_ontology_terms($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.ListOntologyTermsParams
$output is a sdk_ontology_jmc.OntologyTermsOut
ListOntologyTermsParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a string
OntologyTermsOut is a reference to a hash where the following keys are defined:
	ontology has a value which is a string
	namespace has a value which is a string
	term_id has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.ListOntologyTermsParams
$output is a sdk_ontology_jmc.OntologyTermsOut
ListOntologyTermsParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a string
OntologyTermsOut is a reference to a hash where the following keys are defined:
	ontology has a value which is a string
	namespace has a value which is a string
	term_id has a value which is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub list_ontology_terms
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_ontology_terms (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_ontology_terms');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.list_ontology_terms",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_ontology_terms',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_ontology_terms",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_ontology_terms',
				       );
    }
}
 


=head2 ontology_overview

  $output = $obj->ontology_overview($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.OntologyOverviewParams
$output is a sdk_ontology_jmc.OntologyOverviewOut
OntologyOverviewParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a reference to a list where each element is a string
OntologyOverviewOut is a reference to a hash where the following keys are defined:
	dictionaries_meta has a value which is a reference to a list where each element is a sdk_ontology_jmc.overViewInfo
overViewInfo is a reference to a hash where the following keys are defined:
	ontology has a value which is a string
	namespace has a value which is a string
	data_version has a value which is a string
	format_version has a value which is a string
	number_of_terms has a value which is an int
	dictionary_ref has a value which is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.OntologyOverviewParams
$output is a sdk_ontology_jmc.OntologyOverviewOut
OntologyOverviewParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a reference to a list where each element is a string
OntologyOverviewOut is a reference to a hash where the following keys are defined:
	dictionaries_meta has a value which is a reference to a list where each element is a sdk_ontology_jmc.overViewInfo
overViewInfo is a reference to a hash where the following keys are defined:
	ontology has a value which is a string
	namespace has a value which is a string
	data_version has a value which is a string
	format_version has a value which is a string
	number_of_terms has a value which is an int
	dictionary_ref has a value which is a string


=end text

=item Description



=back

=cut

 sub ontology_overview
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ontology_overview (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to ontology_overview:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'ontology_overview');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.ontology_overview",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ontology_overview',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ontology_overview",
					    status_line => $self->{client}->status_line,
					    method_name => 'ontology_overview',
				       );
    }
}
 


=head2 list_public_ontologies

  $return = $obj->list_public_ontologies()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a sdk_ontology_jmc.public_ontologies
public_ontologies is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a sdk_ontology_jmc.public_ontologies
public_ontologies is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub list_public_ontologies
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_public_ontologies (received $n, expecting 0)");
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.list_public_ontologies",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_public_ontologies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_public_ontologies",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_public_ontologies',
				       );
    }
}
 


=head2 list_public_translations

  $return = $obj->list_public_translations()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a sdk_ontology_jmc.public_translations
public_translations is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a sdk_ontology_jmc.public_translations
public_translations is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub list_public_translations
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_public_translations (received $n, expecting 0)");
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.list_public_translations",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_public_translations',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_public_translations",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_public_translations',
				       );
    }
}
 


=head2 get_ontology_terms

  $output = $obj->get_ontology_terms($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.GetOntologyTermsParams
$output is a sdk_ontology_jmc.GetOntologyTermsOut
GetOntologyTermsParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a string
	term_ids has a value which is a reference to a list where each element is a string
GetOntologyTermsOut is a reference to a hash where the following keys are defined:
	term_info has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.GetOntologyTermsParams
$output is a sdk_ontology_jmc.GetOntologyTermsOut
GetOntologyTermsParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a string
	term_ids has a value which is a reference to a list where each element is a string
GetOntologyTermsOut is a reference to a hash where the following keys are defined:
	term_info has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub get_ontology_terms
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_ontology_terms (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_ontology_terms');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.get_ontology_terms",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_ontology_terms',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_ontology_terms",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_ontology_terms',
				       );
    }
}
 


=head2 get_equivalent_terms

  $output = $obj->get_equivalent_terms($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.GetEqTermsParams
$output is a sdk_ontology_jmc.GetEqTermsOut
GetEqTermsParams is a reference to a hash where the following keys are defined:
	ontology_trans_ref has a value which is a string
	term_ids has a value which is a reference to a list where each element is a string
GetEqTermsOut is a reference to a hash where the following keys are defined:
	term_info_list has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.GetEqTermsParams
$output is a sdk_ontology_jmc.GetEqTermsOut
GetEqTermsParams is a reference to a hash where the following keys are defined:
	ontology_trans_ref has a value which is a string
	term_ids has a value which is a reference to a list where each element is a string
GetEqTermsOut is a reference to a hash where the following keys are defined:
	term_info_list has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub get_equivalent_terms
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_equivalent_terms (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_equivalent_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_equivalent_terms');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.get_equivalent_terms",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_equivalent_terms',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_equivalent_terms",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_equivalent_terms',
				       );
    }
}
 


=head2 annotationtogo

  $output = $obj->annotationtogo($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.ElectronicAnnotationParams
$output is a sdk_ontology_jmc.ElectronicAnnotationResults
ElectronicAnnotationParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	input_genome has a value which is a string
	ontology_translation has a value which is a string
	translation_behavior has a value which is a string
	custom_translation has a value which is a string
	clear_existing has a value which is a string
	output_genome has a value which is a string
ElectronicAnnotationResults is a reference to a hash where the following keys are defined:
	report_name has a value which is a string
	report_ref has a value which is a string
	output_genome_ref has a value which is a string
	n_total_features has a value which is an int
	n_features_mapped has a value which is an int

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.ElectronicAnnotationParams
$output is a sdk_ontology_jmc.ElectronicAnnotationResults
ElectronicAnnotationParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	input_genome has a value which is a string
	ontology_translation has a value which is a string
	translation_behavior has a value which is a string
	custom_translation has a value which is a string
	clear_existing has a value which is a string
	output_genome has a value which is a string
ElectronicAnnotationResults is a reference to a hash where the following keys are defined:
	report_name has a value which is a string
	report_ref has a value which is a string
	output_genome_ref has a value which is a string
	n_total_features has a value which is an int
	n_features_mapped has a value which is an int


=end text

=item Description



=back

=cut

 sub annotationtogo
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function annotationtogo (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotationtogo:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'annotationtogo');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "sdk_ontology_jmc.annotationtogo",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'annotationtogo',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method annotationtogo",
					    status_line => $self->{client}->status_line,
					    method_name => 'annotationtogo',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "sdk_ontology_jmc.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "sdk_ontology_jmc.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'annotationtogo',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method annotationtogo",
            status_line => $self->{client}->status_line,
            method_name => 'annotationtogo',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for sdk_ontology_jmc::sdk_ontology_jmcClient\n";
    }
    if ($sMajor == 0) {
        warn "sdk_ontology_jmc::sdk_ontology_jmcClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 ListOntologyTermsParams

=over 4



=item Description

workspace - the name of the workspace for input/output
ontology_dictionary - reference to ontology dictionary


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a string


=end text

=back



=head2 OntologyTermsOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology has a value which is a string
namespace has a value which is a string
term_id has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology has a value which is a string
namespace has a value which is a string
term_id has a value which is a reference to a list where each element is a string


=end text

=back



=head2 OntologyOverviewParams

=over 4



=item Description

Ontology overview


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a reference to a list where each element is a string


=end text

=back



=head2 overViewInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology has a value which is a string
namespace has a value which is a string
data_version has a value which is a string
format_version has a value which is a string
number_of_terms has a value which is an int
dictionary_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology has a value which is a string
namespace has a value which is a string
data_version has a value which is a string
format_version has a value which is a string
number_of_terms has a value which is an int
dictionary_ref has a value which is a string


=end text

=back



=head2 OntologyOverviewOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
dictionaries_meta has a value which is a reference to a list where each element is a sdk_ontology_jmc.overViewInfo

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
dictionaries_meta has a value which is a reference to a list where each element is a sdk_ontology_jmc.overViewInfo


=end text

=back



=head2 public_ontologies

=over 4



=item Description

List public ontologies


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 public_translations

=over 4



=item Description

List public translations


=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 GetOntologyTermsParams

=over 4



=item Description

get ontology terms


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a string
term_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology_dictionary_ref has a value which is a string
term_ids has a value which is a reference to a list where each element is a string


=end text

=back



=head2 term_info

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
id has a value which is a string


=end text

=back



=head2 GetOntologyTermsOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
term_info has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
term_info has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


=end text

=back



=head2 GetEqTermsParams

=over 4



=item Description

get equivalent terms


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ontology_trans_ref has a value which is a string
term_ids has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ontology_trans_ref has a value which is a string
term_ids has a value which is a reference to a list where each element is a string


=end text

=back



=head2 term_info_list

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
terms has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
terms has a value which is a reference to a list where each element is a string


=end text

=back



=head2 GetEqTermsOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
term_info_list has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
term_info_list has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


=end text

=back



=head2 ElectronicAnnotationParams

=over 4



=item Description

workspace - the name of the workspace for input/output
input_genome - reference to the input genome object
ontology_translation - optional reference to user specified ontology translation map
output_genome - the name of the mapped genome annotation object

@optional ontology_translation


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a string
input_genome has a value which is a string
ontology_translation has a value which is a string
translation_behavior has a value which is a string
custom_translation has a value which is a string
clear_existing has a value which is a string
output_genome has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a string
input_genome has a value which is a string
ontology_translation has a value which is a string
translation_behavior has a value which is a string
custom_translation has a value which is a string
clear_existing has a value which is a string
output_genome has a value which is a string


=end text

=back



=head2 ElectronicAnnotationResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
output_genome_ref has a value which is a string
n_total_features has a value which is an int
n_features_mapped has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
output_genome_ref has a value which is a string
n_total_features has a value which is an int
n_features_mapped has a value which is an int


=end text

=back



=cut

package sdk_ontology_jmc::sdk_ontology_jmcClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
