package sdk_ontology_jmc::sdk_ontology_jmcImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = '0.0.1';
our $GIT_URL = 'git@github.com:jmchandonia/ontology_service.git';
our $GIT_COMMIT_HASH = '50c8a7091d7747265b72e2af22b7b79a50b96995';

=head1 NAME

sdk_ontology_jmc

=head1 DESCRIPTION

A KBase module: sdk_ontology_dk

=cut

#BEGIN_HEADER
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_ontology_terms');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($output);
    #BEGIN list_ontology_terms
    #END list_ontology_terms
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_ontology_terms');
    }
    return($output);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to ontology_overview:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'ontology_overview');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($output);
    #BEGIN ontology_overview
    #END ontology_overview
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to ontology_overview:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'ontology_overview');
    }
    return($output);
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
    my $self = shift;

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($return);
    #BEGIN list_public_ontologies
    #END list_public_ontologies
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_public_ontologies:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_public_ontologies');
    }
    return($return);
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
    my $self = shift;

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($return);
    #BEGIN list_public_translations
    #END list_public_translations
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_public_translations:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_public_translations');
    }
    return($return);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_ontology_terms');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($output);
    #BEGIN get_ontology_terms
    #END get_ontology_terms
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_ontology_terms:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_ontology_terms');
    }
    return($output);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_equivalent_terms:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_equivalent_terms');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($output);
    #BEGIN get_equivalent_terms
    #END get_equivalent_terms
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_equivalent_terms:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_equivalent_terms');
    }
    return($output);
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
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to annotationtogo:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotationtogo');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($output);
    #BEGIN annotationtogo
    #END annotationtogo
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to annotationtogo:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'annotationtogo');
    }
    return($output);
}




=head2 status 

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
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

1;
