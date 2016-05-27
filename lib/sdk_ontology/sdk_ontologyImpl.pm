package sdk_ontology::sdk_ontologyImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

sdk_ontology

=head1 DESCRIPTION

A KBase module: sdk_ontology
This module convert given KBase annotations of a genome to GO terms.

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Data::Dumper;



sub searchname
{
    my $sn = $_[0];
    $sn =~ s/^\s+//;
    $sn =~ s/_//g;
    $sn =~ tr/A-Z/a-z/;
    $sn =~ s/[\s]//g;
    $sn =~ s/(?<=\(ec)[^)]+[^(]+(?=\))//g;
    $sn =~ s/(?<=\(tc)[^)]+[^(]+(?=\))//g;

    return $sn;

}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('sdk_ontology','workspace-url');
    die "no workspace-url defined" unless $wsInstance;

    $self->{'workspace-url'} = $wsInstance;

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 annotationtogo

  $output = $obj->annotationtogo($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology.ElectronicAnnotationParams
$output is a sdk_ontology.ElectronicAnnotationResults
ElectronicAnnotationParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	input_genome has a value which is a string
	ontology_translation has a value which is a string
	custom_translation has a value which is a string
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

$params is a sdk_ontology.ElectronicAnnotationParams
$output is a sdk_ontology.ElectronicAnnotationResults
ElectronicAnnotationParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	input_genome has a value which is a string
	ontology_translation has a value which is a string
	custom_translation has a value which is a string
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

    my $ctx = $sdk_ontology::sdk_ontologyServer::CallContext;
    my($output);
    #BEGIN annotationtogo

    print("Starting sdk_ontology method...\n\n");

    if (!exists $params->{'workspace'}) {
        die "Parameter workspace is not set in input arguments";
    }
    my $workspace_name=$params->{'workspace'};


    if (!exists $params->{'input_genome'}) {
        die "Parameter input_genome is not set in input arguments";
    }
    my $input_gen=$params->{'input_genome'};


    if (!exists $params->{'ontology_translation'}) {
        die "Parameter ontology_translation is not set in input arguments";
    }
    my $ont_tr=$params->{'ontology_translation'};

    my $cus_tr;
    if (!exists $params->{'custom_translation'} && $ont_tr eq "custom") {
        die "Provide the custom translation table as an input\n\n";
    }
    elsif (exists $params->{'custom_translation'} && $ont_tr ne "custom"){
        print "Using the selected translational table from the dropdown..\n\n"
    }
    else{
        $cus_tr=$params->{'custom_translation'};
    }


    if (!exists $params->{'output_genome'}) {
        die "Parameter output_genome is not set in input arguments";
    }
    my $outGenome=$params->{'output_genome'};

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);
    my $genome=undef;
    my $ontTr=undef;
    my $cusTr=undef;
    my $ontWs = "KBaseOntology";

    if (defined $cus_tr && $ont_tr eq "custom"){
        $ontWs=$workspace_name;
        $ont_tr=$cus_tr;
    }

    eval {
        $genome=$wsClient->get_objects([{workspace=>$workspace_name,name=>$input_gen}])->[0]{data};
        $ontTr=$wsClient->get_objects([{workspace=>$ontWs,name=>$ont_tr}])->[0]{data}{translation};
    };
    if ($@) {
        die "Error loading ontology translation object from workspace:\n".$@;
    }
    my $func_list = $genome->{features};
    my %roles;
    my @rolesArr;
    my $role_match_count=1;
    my %selectedRoles;

    foreach my $k (keys $ontTr){
        my $r = $ontTr->{$k}->{name};
        my $eq = $ontTr->{$k}->{equiv_terms};

        my $mRole = searchname ($r);
            my @tempMR;
            for (my $i=0; $i<@$eq; $i++){
                my $e_name = $eq->[$i]->{equiv_name};
                my $e_term = $eq->[$i]->{equiv_term};
                push (@tempMR, $e_name);
            }
            $selectedRoles{$mRole} = \@tempMR;
    }

    print "Following annotations were translated in the genome\n";
    my $changeRoles =0;
    for (my $j =0; $j< @$func_list; $j++){
        my $func = $func_list->[$j]->{function};
        my $sn = searchname($func);
        if (exists $selectedRoles{$sn}){
            my $nrL = $selectedRoles{$sn};
                my @tempA;
                for (my $i=0; $i< @$nrL; $i++){
                    push(@tempA, $nrL->[$i]);
                }
            my $joinStr = join (" | ", @tempA);
            print "$func\t-\t$joinStr\n";
            $func_list->[$j]->{function} = $joinStr;
            $changeRoles++;
        }
    }

    print "\nTotal of $changeRoles feature annotations were translated \n";
    my $obj_info_list = undef;
    eval {
        $obj_info_list = $wsClient->save_objects({
            'workspace'=>$workspace_name,
            'objects'=>[{
                'type'=>'KBaseGenomes.Genome',
                'data'=>$genome,
                'name'=>$outGenome,
                'provenance'=>$provenance
            }]
        });
    };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }
    my $info = $obj_info_list->[0];

    print "\nMethod sucuessfully completed\n";
    print("saved:".Dumper($info)."\n");
    $output = { 'SEEDtoGO' => $obj_info_list};

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




=head2 version 

  $return = $obj->version()

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

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



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
custom_translation has a value which is a string
output_genome has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a string
input_genome has a value which is a string
ontology_translation has a value which is a string
custom_translation has a value which is a string
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
