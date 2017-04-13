package sdk_ontology_jmc::sdk_ontology_jmcImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = '0.0.1';
our $GIT_URL = 'git@github.com:jmchandonia/ontology_service.git';
our $GIT_COMMIT_HASH = '2886517f0458afe43a6d37abd77d93567d039bbf';

=head1 NAME

sdk_ontology_jmc

=head1 DESCRIPTION

A KBase module: sdk_ontology_jmc

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Workspace::WorkspaceClient;
use GenomeAnnotationAPI::GenomeAnnotationAPIClient;
use Config::IniFiles;
use Data::Dumper;
use JSON;
use JSON::XS ();
binmode STDOUT, ":utf8";
our $EC_PATTERN = qr/\(\s*E\.?C\.?(?:\s+|:)(\d\.(?:\d+|-)\.(?:\d+|-)\.(?:n?\d+|-)\s*)\)/;

sub version {
    return $VERSION;
}

sub searchname
{
    my $sn = $_[0];
    $sn =~ s/^\s+//;
    $sn =~ s/_//g;
    $sn =~ s/-//g;
    $sn =~ s/,//g;
    $sn =~ tr/A-Z/a-z/;
    $sn =~ s/[\s]//g;
    $sn =~ s/(?<=\(ec)[^)]+[^(]+(?=\))//g;
    $sn =~ s/(?<=\(tc)[^)]+[^(]+(?=\))//g;
    return $sn;
}

sub splitFunc
{
    my $fn = $_[0];
    my @splitFunc;
    if ($fn =~ /\// || $fn =~ /;/ || $fn =~ /@/){
        @splitFunc = split /[;@\/]+/, $fn;
        return \@splitFunc;
    }
    else{
        push (@splitFunc, $fn);
        return \@splitFunc;
    }
}

sub searchec
{
    my $sn = $_[0];
    $sn =~ s/://g;
    $sn =~ tr/A-Z/a-z/;
    $sn =~ s/[\s]//g;
    $sn =~ s/^\s+//;
    return $sn;
}

sub ontologyTranslate{
my ($genome, $ontTr, $ontRef, $ont_tr, $clear, $dictionary_ref) = @_;
    my $func_list = $genome->{features};
    my %selectedRoles;
    my %termName;
    my %termId;
    my %ontType = (
        sso2go => "SSO",
    );

    foreach my $k (keys $ontTr){
        my $r = $ontTr->{$k}->{name};
        my $eq = $ontTr->{$k}->{equiv_terms};
        my $mRole = searchname ($r);
        my @ecArr;
        if ($ont_tr eq "ec2go"){
            my $ecsn = searchec($k);
            $mRole=$ecsn;
        }
            my @tempMR;
            for (my $i=0; $i<@$eq; $i++){
                my $e_name = $eq->[$i]->{equiv_name};
                my $e_term = $eq->[$i]->{equiv_term};
                $termName{$e_name} = $e_term;
                $termId{$mRole} = [$r,$k];
                push (@tempMR, $e_name);
            }
            $selectedRoles{$mRole} = \@tempMR;
    }

    #print "Following ontology terms were translated in the genome\n";
    my $local_time = localtime ();
    my $vs = version ();
    my $changeRoles =0;
    for (my $j =0; $j< @$func_list; $j++){

        if ($clear == 1){
            $func_list->[$j]->{ontology_terms} = {};

        }
        my $func = $func_list->[$j]->{function};
        my $funcId = $func_list->[$j]->{id};

        my $sn;
        if (defined $func_list->[$j]->{ontology_terms}->{$ontType{$ont_tr}} && exists $ontType{$ont_tr}){
            my $oTerm = $func_list->[$j]->{ontology_terms}->{$ontType{$ont_tr}};
            my %oTermRecord;
            foreach my $k (keys $oTerm){
                my $tName =  $oTerm->{$k}->{term_name};
                $tName =~ s/GO://g;

                $oTermRecord{$tName} = [$k, $tName, $func, $oTerm->{$k}->{term_name}];
                print "$func\t$k\t$tName\t$oTerm->{$k}->{term_name}\n";
                $sn = searchname($tName);
                if ($ont_tr eq "ec2go"){
                    my $ecNum;
                    if ($tName =~ /(.+?)\s*$EC_PATTERN\s*(.*)/) {
                        $ecNum = $2;
                        $sn = searchec ("EC:$ecNum");
                    }
                }
                else{
                     $sn = searchname($tName);
                }
                ########## for unitprot and ec partial mappings being considered######
                if ($ont_tr eq "uniprotkb_kw2go" || $ont_tr eq "ec2go" ){
                    while (my($key, $value) = each %selectedRoles) {
                        if (-1 != index($sn, $key)) {
                            $sn =$key;

                            if ( exists $selectedRoles{$sn}  && !defined ($func_list->[$j]->{ontology_terms}->{GO}) ){
                                my $nrL = $selectedRoles{$sn};
                                my @tempA;
                                for (my $i=0; $i< @$nrL; $i++){
                                    my $ontEvi = {
                                        method => "Remap annotations based on Ontology translation table",
                                        method_version => $vs,
                                        timestamp => $local_time,
                                        translation_provenance => [],
                                        alignment_evidence => []
                                    };
                                    my $ontData ={
                                        id => "",
                                        ontology_ref =>"",
                                        term_lineage => [],
                                        term_name => "",
                                        evidence => []
                                    };
                                    push(@tempA, $nrL->[$i]);
                                    $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                    $ontData->{ontology_ref} = $dictionary_ref;
                                    $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                    $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                    push (@{$ontData->{evidence}},$ontEvi);
                                    $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                                }
                                my $joinStr = join (" | ", @tempA);
                                #print "$funcId\t$k\t$tName\t-\t$joinStr\n";
                                $changeRoles++;
                            }
                            elsif ( exists $selectedRoles{$sn} && defined ($func_list->[$j]->{ontology_terms}->{GO}) ) {
                                    my $new_term = $func_list->[$j]->{ontology_terms}->{GO};

                                    my $nrL = $selectedRoles{$sn};
                                    my @tempA;
                                    for (my $i=0; $i< @$nrL; $i++){
                                        my $ontEvi = {
                                            method => "Remap annotations based on Ontology translation table",
                                            method_version => $vs,
                                            timestamp => $local_time,
                                            translation_provenance => [],
                                            alignment_evidence => []
                                        };
                                        my $ontData ={
                                            id => "",
                                            ontology_ref =>"",
                                            term_lineage => [],
                                            term_name => "",
                                            evidence => []
                                        };
                                        push(@tempA, $nrL->[$i]);

                                        if (exists $new_term->{$termName{$nrL->[$i]}}){
                                            $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                            push (@{$new_term->{$termName{$nrL->[$i]}}->{evidence}}, $ontEvi);
                                        }
                                        else{
                                            $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                            $ontData->{ontology_ref} = $dictionary_ref;
                                            $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                            $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                            push (@{$ontData->{evidence}},$ontEvi);
                                            $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                                        }
                                    }
                                    my $joinStr = join (" | ", @tempA);
                                    #print "$funcId\t$fr\t-\t$joinStr\n";
                                    $changeRoles++;
                                    #print &Dumper ( $func_list->[$j]->{ontology_terms});
                                    #die;
                            }
                            else{
                                next;
                            }
    #################################end
                        }
                    }
                }
                else{

                    if ( exists $selectedRoles{$sn}  && !defined ($func_list->[$j]->{ontology_terms}->{GO}) ){
                        my $nrL = $selectedRoles{$sn};
                            my @tempA;
                            for (my $i=0; $i< @$nrL; $i++){
                                my $ontEvi = {
                                    method => "Remap annotations based on Ontology translation table",
                                    method_version => $vs,
                                    timestamp => $local_time,
                                    translation_provenance => [],
                                    alignment_evidence => []
                                };
                                my $ontData ={
                                    id => "",
                                    ontology_ref =>"",
                                    term_lineage => [],
                                    term_name => "",
                                    evidence => []
                                };
                                push(@tempA, $nrL->[$i]);
                                $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                $ontData->{ontology_ref} = $dictionary_ref;
                                $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                push (@{$ontData->{evidence}},$ontEvi);
                                $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                            }
                            my $joinStr = join (" | ", @tempA);
                            #print "$funcId\t$k\t$tName\t-\t$joinStr\n";
                            #print &Dumper ($func_list->[$j]->{ontology_terms});
                            $changeRoles++;
                    }
                    elsif ( exists $selectedRoles{$sn} && defined ($func_list->[$j]->{ontology_terms}->{GO}) ) {
                            my $new_term = $func_list->[$j]->{ontology_terms};
                            my $nrL = $selectedRoles{$sn};
                            my @tempA;
                            for (my $i=0; $i< @$nrL; $i++){
                                my $ontEvi = {
                                    method => "Remap annotations based on Ontology translation table",
                                    method_version => $vs,
                                    timestamp => $local_time,
                                    translation_provenance => [],
                                    alignment_evidence => []
                                };
                                my $ontData ={
                                    id => "",
                                    ontology_ref =>"",
                                    term_lineage => [],
                                    term_name => "",
                                    evidence => []
                                };
                                push(@tempA, $nrL->[$i]);

                                if (exists $new_term->{$termName{$nrL->[$i]}}){
                                    $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                    push (@{$new_term->{$termName{$nrL->[$i]}}->{evidence}}, $ontEvi);
                                }
                                else{
                                    $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                    $ontData->{ontology_ref} = $dictionary_ref;
                                    $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                    $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                    push (@{$ontData->{evidence}},$ontEvi);
                                    $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                                }
                            }
                            my $joinStr = join (" | ", @tempA);
                            #print "$funcId\t$k\t$tName\t-\t$joinStr\n";
                            $changeRoles++;

                    }
                    else{
                        next;
                    }
                }
            }#foreach
        } #outer if
    }#for
    print "\nTotal of $changeRoles ontology terms were translated \n";
}




sub featureTranslate{
    my ($genome, $ontTr, $ontRef, $ont_tr, $clear, $dictionary_ref) = @_;
    my $func_list = $genome->{features};
    my %selectedRoles;
    my %termName;
    my %termId;

    foreach my $k (keys $ontTr){
        my $r = $ontTr->{$k}->{name};
        my $eq = $ontTr->{$k}->{equiv_terms};
        my $mRole = searchname ($r);
        my @ecArr;
        if ($ont_tr eq "ec2go"){
            my $ecsn = searchec($k);
            $mRole=$ecsn;
        }
            my @tempMR;
            for (my $i=0; $i<@$eq; $i++){
                my $e_name = $eq->[$i]->{equiv_name};
                my $e_term = $eq->[$i]->{equiv_term};
                $termName{$e_name} = $e_term;
                $termId{$mRole} = [$r,$k];
                push (@tempMR, $e_name);
            }
            $selectedRoles{$mRole} = \@tempMR;
    }

    #print "Following feature annotations were translated in the genome\n";
    my $local_time = localtime ();
    my $vs = version ();
    my $changeRoles =0;
    for (my $j =0; $j< @$func_list; $j++){

        if ($clear == 1){
            $func_list->[$j]->{ontology_terms} = {};

        }

        my $func = $func_list->[$j]->{function};
        my $funcId = $func_list->[$j]->{id};
        my $splitArr = splitFunc($func);
        my $count_flag =0;
        foreach my $fr (@$splitArr){
            $count_flag++;
            my $sn;
            if ($ont_tr eq "ec2go"){
                my $ecNum;
                if ($fr =~ /(.+?)\s*$EC_PATTERN\s*(.*)/) {
                    $ecNum = $2;
                    $sn = searchec ("EC:$ecNum");
                }
            }
            else{
                 $sn = searchname($fr);
            }
            ########## for unitprot and ec partial mappings being considered######
            if ($ont_tr eq "uniprotkb_kw2go" || $ont_tr eq "ec2go" ){
                while (my($key, $value) = each %selectedRoles) {
                    if (-1 != index($sn, $key)) {
                        $sn =$key;

                        if ( exists $selectedRoles{$sn}  && !defined ($func_list->[$j]->{ontology_terms}->{GO}) ){
                            my $nrL = $selectedRoles{$sn};
                            my @tempA;
                            for (my $i=0; $i< @$nrL; $i++){
                                my $ontEvi = {
                                    method => "Remap annotations based on Ontology translation table",
                                    method_version => $vs,
                                    timestamp => $local_time,
                                    translation_provenance => [],
                                    alignment_evidence => []
                                };
                                my $ontData ={
                                    id => "",
                                    ontology_ref =>"",
                                    term_lineage => [],
                                    term_name => "",
                                    evidence => []
                                };
                                push(@tempA, $nrL->[$i]);
                                $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                $ontData->{ontology_ref} = $dictionary_ref;
                                $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                push (@{$ontData->{evidence}},$ontEvi);
                                $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                            }
                            my $joinStr = join (" | ", @tempA);
                            #print "$funcId\t$fr\t-\t$joinStr\n";
                            $changeRoles++;
                        }
                        elsif ( exists $selectedRoles{$sn} && defined ($func_list->[$j]->{ontology_terms}->{GO}) && $count_flag <= 1 ) {
                                my $new_term = $func_list->[$j]->{ontology_terms}->{GO};

                                my $nrL = $selectedRoles{$sn};
                                my @tempA;
                                for (my $i=0; $i< @$nrL; $i++){
                                    my $ontEvi = {
                                        method => "Remap annotations based on Ontology translation table",
                                        method_version => $vs,
                                        timestamp => $local_time,
                                        translation_provenance => [],
                                        alignment_evidence => []
                                    };
                                    my $ontData ={
                                        id => "",
                                        ontology_ref =>"",
                                        term_lineage => [],
                                        term_name => "",
                                        evidence => []
                                    };
                                    push(@tempA, $nrL->[$i]);

                                    if (exists $new_term->{$termName{$nrL->[$i]}}){
                                        $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                        push (@{$new_term->{$termName{$nrL->[$i]}}->{evidence}}, $ontEvi);
                                    }
                                    else{
                                        $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                        $ontData->{ontology_ref} = $dictionary_ref;
                                        $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                        $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                        push (@{$ontData->{evidence}},$ontEvi);
                                        $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                                    }
                                }
                                my $joinStr = join (" | ", @tempA);
                                #print "$funcId\t$fr\t-\t$joinStr\n";
                                $changeRoles++;

                        }
                        else{
                            next;
                        }
#################################end
                    }
                }
            }
            else{

                if ( exists $selectedRoles{$sn}  && !defined ($func_list->[$j]->{ontology_terms}->{GO}) ){
                    my $nrL = $selectedRoles{$sn};
                        my @tempA;
                        for (my $i=0; $i< @$nrL; $i++){
                            my $ontEvi = {
                                method => "Remap annotations based on Ontology translation table",
                                method_version => $vs,
                                timestamp => $local_time,
                                translation_provenance => [],
                                alignment_evidence => []
                            };
                            my $ontData ={
                                id => "",
                                ontology_ref =>"",
                                term_lineage => [],
                                term_name => "",
                                evidence => []
                            };
                            push(@tempA, $nrL->[$i]);
                            $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                            $ontData->{ontology_ref} = $dictionary_ref;
                            $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                            $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                            push (@{$ontData->{evidence}},$ontEvi);
                            $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                        }
                        my $joinStr = join (" | ", @tempA);
                        #print "$funcId\t$fr\t-\t$joinStr\n";
                        $changeRoles++;
                }
                elsif ( exists $selectedRoles{$sn} && defined ($func_list->[$j]->{ontology_terms}->{GO}) && $count_flag <= 1 ) {
                        my $new_term = $func_list->[$j]->{ontology_terms};
                        my $nrL = $selectedRoles{$sn};
                        my @tempA;
                        for (my $i=0; $i< @$nrL; $i++){
                            my $ontEvi = {
                                method => "Remap annotations based on Ontology translation table",
                                method_version => $vs,
                                timestamp => $local_time,
                                translation_provenance => [],
                                alignment_evidence => []
                            };
                            my $ontData ={
                                id => "",
                                ontology_ref =>"",
                                term_lineage => [],
                                term_name => "",
                                evidence => []
                            };
                            push(@tempA, $nrL->[$i]);

                            if (exists $new_term->{$termName{$nrL->[$i]}}){
                                $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                push (@{$new_term->{$termName{$nrL->[$i]}}->{evidence}}, $ontEvi);
                            }
                            else{
                                $ontData->{id} = $termName{$nrL->[$i]}; #$termName{$nrL->[$i]};
                                $ontData->{ontology_ref} = $dictionary_ref;
                                $ontData->{term_name} = $nrL->[$i];#$nrL->[$i];
                                $ontEvi->{translation_provenance} = [$ontRef, $termId{$sn}->[1], $termId{$sn}->[0]];
                                push (@{$ontData->{evidence}},$ontEvi);
                                $func_list->[$j]->{ontology_terms}->{GO}->{$termName{$nrL->[$i]}} = $ontData;
                            }
                        }
                        my $joinStr = join (" | ", @tempA);
                        #print "$funcId\t$fr\t-\t$joinStr\n";
                        $changeRoles++;

                }
                else{
                    next;
                }
            }
        } #foreach
    }#for
    print "\nTotal of $changeRoles feature annotations were translated \n";
}

sub util_configure_ws_id {
	my ($self,$ws,$id) = @_;
	my $input = {};
 	if ($ws =~ m/^\d+$/) {
 		$input->{wsid} = $ws;
	} else {
		$input->{workspace} = $ws;
	}
	if ($id =~ m/^\d+$/) {
		$input->{objid} = $id;
	} else {
		$input->{name} = $id;
	}
	return $input;
}

sub util_runexecutable {
	my ($self,$Command) = @_;
	my $OutputArray;
	push(@{$OutputArray},`$Command`);
	return $OutputArray;
}

sub util_from_json {
	my ($self,$data) = @_;
    if (!defined($data)) {
    	die "Data undefined!";
    }
    return decode_json $data;
}

sub util_get_genome {
	my ($self,$ref) = @_;
	my $output = $self->util_ga_client()->get_genome_v1({
		genomes => [{
			"ref" => $ref
		}],
		ignore_errors => 1,
		no_data => 0,
		no_metadata => 1
	});
	return $output->{genomes}->[0]->{data};
}

sub util_ga_client {
	my ($self,$input) = @_;
	if (!defined($self->{_gaclient})) {
		$self->{_gaclient} = new GenomeAnnotationAPI::GenomeAnnotationAPIClient($ENV{ SDK_CALLBACK_URL });
	}
	return $self->{_gaclient};
}

##################################

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
    $self->{'kbase-endpoint'} = $cfg->val('sdk_ontology_jmc','kbase-endpoint');
    $self->{'workspace-url'} = $cfg->val('sdk_ontology_jmc','workspace-url');
    $self->{'job-service-url'} = $cfg->val('sdk_ontology_jmc','job-service-url');
    $self->{'shock-url'} = $cfg->val('sdk_ontology_jmc','shock-url');
    $self->{'handle-service-url'} = $cfg->val('sdk_ontology_jmc','handle-service-url');
    $self->{'scratch'} = $cfg->val('sdk_ontology_jmc','scratch');
    $self->{'Data_API_script_directory'} = $cfg->val('sdk_ontology_jmc','Data_API_script_directory');
	if (!defined($self->{'workspace-url'})) {
		die "no workspace-url defined";
	}
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

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $ont_dic=undef;

    if (!exists $params->{'ontology_dictionary_ref'}) {
        die "Parameter ontology_dictionary_ref is not set in input arguments";
    }
    my $ont_dic_ref=$params->{'ontology_dictionary_ref'};


    eval {
        $ont_dic=$wsClient->get_objects([{ref=>$ont_dic_ref}])->[0]{data};
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

    my @term_ids = keys $ont_dic->{term_hash};
    $output->{ontology} = $ont_dic->{ontology};
    $output->{namespace} = $ont_dic->{default_namespace};
    $output->{term_id} = \@term_ids;

    # print &Dumper ($output);

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
	namespace_id_rule has a value which is a reference to a list where each element is a string

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
	namespace_id_rule has a value which is a reference to a list where each element is a string


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


    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $ont_dic=undef;
    my $dict_list = [];


    if (!exists $params->{'ontology_dictionary_ref'}) {
        die "Parameter ontology_dictionary_ref is not set in input arguments";
    }
    my $ont_dic_ref=$params->{'ontology_dictionary_ref'};

    foreach my $d (@$ont_dic_ref){

        eval {
        $ont_dic=$wsClient->get_objects([{ref=>$d}])->[0]{data};
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

        my $overViewInfo = undef;
         $overViewInfo->{namespace} = $ont_dic->{default_namespace};
         $overViewInfo->{ontology} = $ont_dic->{ontology};
         $overViewInfo->{data_version} = $ont_dic->{data_version};
         $overViewInfo->{format_version} = $ont_dic->{format_version};
         $overViewInfo->{number_of_terms} = keys $ont_dic->{term_hash};
         $overViewInfo->{dictionary_ref} = $d;
	 $overViewInfo->{namespace_id_rule} = $ont_dic->{namespace_id_rule};
         push ($dict_list, $overViewInfo);

    }
    $output->{dictionaries_meta} = $dict_list;
    #print &Dumper ($output);



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
    $return = $self->list_ontologies({workspace_names=>["KBaseOntology"]});
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




=head2 list_ontologies

  $return = $obj->list_ontologies($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a sdk_ontology_jmc.ListOntologiesParams
$return is a sdk_ontology_jmc.ontologies
ListOntologiesParams is a reference to a hash where the following keys are defined:
	workspace_names has a value which is a reference to a list where each element is a string
ontologies is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.ListOntologiesParams
$return is a sdk_ontology_jmc.ontologies
ListOntologiesParams is a reference to a hash where the following keys are defined:
	workspace_names has a value which is a reference to a list where each element is a string
ontologies is a reference to a list where each element is a string


=end text



=item Description



=back

=cut

sub list_ontologies
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_ontologies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_ontologies');
    }

    my $ctx = $sdk_ontology_jmc::sdk_ontology_jmcServer::CallContext;
    my($return);
    #BEGIN list_ontologies

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $ws_ont=undef;
    my $wsOntArr= [];

    if (!exists $params->{'workspace_names'}) {
        die "Parameter workspace_names is not set in input arguments";
    }

    eval{
    $ws_ont = $wsClient->list_objects({workspaces=>$params->{'workspace_names'},type=>"KBaseOntology.OntologyDictionary"});
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

    foreach my $p (@$ws_ont){

        my $wsOntRef = $p->[6]."/".$p->[0]."/".$p->[4];
        push ($wsOntArr, $wsOntRef);
    }

     $return = $wsOntArr;
     #print &Dumper ($return);

    #END list_ontologies
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_ontologies:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_ontologies');
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
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $public_tr=undef;
    my $pubTrArr= [];

    eval{
    $public_tr = $wsClient->list_objects({workspaces=>["KBaseOntology"],type=>"KBaseOntology.OntologyTranslation"});
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

    foreach my $p (@$public_tr){

        my $pubTrRef = $p->[6]."/".$p->[0]."/".$p->[4];
        push ($pubTrArr, $pubTrRef);
    }

     print &Dumper ($pubTrArr);
     $return = $pubTrArr;

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
	term_info has a value which is a reference to a hash where the key is a string and the value is a sdk_ontology_jmc.termInfo
termInfo is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	def has a value which is a reference to a list where each element is a string
	synonym has a value which is a reference to a list where each element is a string
	xref has a value which is a reference to a list where each element is a string
	property_value has a value which is a reference to a list where each element is a string
	is_a has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a sdk_ontology_jmc.GetOntologyTermsParams
$output is a sdk_ontology_jmc.GetOntologyTermsOut
GetOntologyTermsParams is a reference to a hash where the following keys are defined:
	ontology_dictionary_ref has a value which is a string
	term_ids has a value which is a reference to a list where each element is a string
GetOntologyTermsOut is a reference to a hash where the following keys are defined:
	term_info has a value which is a reference to a hash where the key is a string and the value is a sdk_ontology_jmc.termInfo
termInfo is a reference to a hash where the following keys are defined:
	id has a value which is a string
	name has a value which is a string
	def has a value which is a reference to a list where each element is a string
	synonym has a value which is a reference to a list where each element is a string
	xref has a value which is a reference to a list where each element is a string
	property_value has a value which is a reference to a list where each element is a string
	is_a has a value which is a reference to a list where each element is a string


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

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $ont_dic=undef;
    my $dict_list = [];

    if (!exists $params->{'ontology_dictionary_ref'}) {
        die "Parameter ontology_dictionary_ref is not set in input arguments";
    }
    my $ont_dic_ref=$params->{'ontology_dictionary_ref'};

    if (!exists $params->{'term_ids'}) {
        die "Parameter term_ids is not set in input arguments";
    }
    my $term_ids=$params->{'term_ids'};

    eval {
        $ont_dic=$wsClient->get_objects([{ref=>$ont_dic_ref}])->[0]{data}{term_hash};
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

    #print &Dumper ($ont_dic);
    #die;
    my $term_info;

    foreach my $t (@$term_ids){
        my $term_info_id = {
            name => "",
            id => "",
	    def => [],
	    synonym => [],
	    xref => [],
	    property_value => [],
	    is_a => []
        };
        if (exists $ont_dic->{$t}){
            $term_info_id->{name} = $ont_dic->{$t}->{name};
            $term_info_id->{id} = $ont_dic->{$t}->{id};
            $term_info_id->{def} = $ont_dic->{$t}->{def};
            $term_info_id->{synonym} = $ont_dic->{$t}->{synonym};
            $term_info_id->{xref} = $ont_dic->{$t}->{xref};
            $term_info_id->{property_value} = $ont_dic->{$t}->{property_value};
            $term_info_id->{is_a} = $ont_dic->{$t}->{is_a};
            $term_info->{$t} = $term_info_id;
            #push (@{$term_info->{$t}}, $term_info_id);
             #print &Dumper ($term_info_id);
        }
        #push (@{$term_info->{$t}}, $term_info_id);
    }
    #print &Dumper ($term_info);
    $output->{term_info} = $term_info;

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
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $ont_Tr=undef;
    my $dict_list = [];


    if (!exists $params->{'ontology_trans_ref'}) {
        die "Parameter ontology_dictionary_ref is not set in input arguments";
    }
    my $ont_tr_ref=$params->{'ontology_trans_ref'};


    if (!exists $params->{'term_ids'}) {
        die "Parameter term_ids is not set in input arguments";
    }
    my $term_ids=$params->{'term_ids'};
    #$ont_tr_ref = "8162/10/2";

    eval {
        $ont_Tr=$wsClient->get_objects([{ref=>$ont_tr_ref}])->[0]{data};#{translation};
    };
    if ($@) {
        die "Error loading ontology dictionary object from workspace:\n".$@;
    }

    my $term_info;
    foreach my $t (@$term_ids){
        my $term_info_id = {
            name => "",
            terms => ""
        };

        if (exists $ont_Tr->{$t}){

            $term_info_id->{name} = $ont_Tr->{$t}->{name};
            $term_info_id->{terms} = $ont_Tr->{$t}->{equiv_terms};
            $term_info->{$t} = $term_info_id;
        }
    }
        $output = $term_info;
        #print &Dumper ($term_info);
    #die;

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

    print("Starting sdk_ontology_jmc method...\n\n");

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

    if (!exists $params->{'translation_behavior'}) {
        die "Parameter translation_behavior is not set in input arguments";
    }
    my $trns_bh=$params->{'translation_behavior'};

    if (!exists $params->{'clear_existing'}) {
        die "Parameter clear_existing is not set in input arguments";
    }
    my $cl_ex=$params->{'clear_existing'};

    my $cus_tr;
    if (!exists $params->{'custom_translation'} && $ont_tr eq "custom") {
        die "Provide the custom translation table as an input\n\n";
    }
    elsif (exists $params->{'custom_translation'} && $ont_tr ne "custom"){
        print "Using the selected translational table from the dropdown..\n\n"
    }
    else{
        $cus_tr=$params->{'custom_translation'};
        print "Using the custom translational table..\n\n"
    }

    if (!exists $params->{'output_genome'}) {
        die "Parameter output_genome is not set in input arguments";
    }
    my $outGenome=$params->{'output_genome'};

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Workspace::WorkspaceClient->new($self->{'workspace-url'},token=>$token);
    my $genome=undef;
    my $ontTr=undef;
    my $cusTr=undef;
    my $ontWs = "KBaseOntology";

    if (defined $cus_tr && $ont_tr eq "custom"){
        $ontWs=$workspace_name;
        $ont_tr=$cus_tr;
    }
    eval {
        $genome = $self->util_get_genome($workspace_name."/".$input_gen);
		$ontTr=$wsClient->get_objects([{workspace=>$ontWs,name=>$ont_tr}])->[0];#{data}{translation};
    };
    if ($@) {
        die "Error loading ontology translation object from workspace:\n".$@;
    }
    my $ontRef = $ontTr->{info}->[6]."/".$ontTr->{info}->[0]."/".$ontTr->{info}->[4];
    my $ontTableRef = $ontTr->{data}->{ontology1};

    if ( ($ont_tr eq "sso2go" || $ont_tr eq "interpro2go" || $ont_tr eq "custom" || $ont_tr eq "uniprotkb_kw2go" || $ont_tr eq "ec2go" )  && ($trns_bh eq "featureOnly") ){
        print "\n\n...translating feature annotations\n";
        featureTranslate($genome, $ontTr->{data}->{translation}, $ontRef, $ont_tr, $cl_ex, $ontTableRef);
    }

    elsif ( ($ont_tr eq "sso2go" || $ont_tr eq "interpro2go" || $ont_tr eq "custom" || $ont_tr eq "uniprotkb_kw2go" || $ont_tr eq "ec2go" )  && ($trns_bh eq "ontologyOnly") ){
        print "\n\n...translating ontology terms\n";
        ontologyTranslate($genome, $ontTr->{data}->{translation}, $ontRef, $ont_tr, $cl_ex, $ontTableRef);
    }

    elsif ( ($ont_tr eq "sso2go" || $ont_tr eq "interpro2go" || $ont_tr eq "custom" || $ont_tr eq "uniprotkb_kw2go" || $ont_tr eq "ec2go" )  && ($trns_bh eq "annoandOnt") ){
        print "\n\n...translating both feature annotations and ontology terms\n";
        featureTranslate($genome, $ontTr->{data}->{translation}, $ontRef, $ont_tr, $cl_ex, $ontTableRef);
        ontologyTranslate($genome, $ontTr->{data}->{translation}, $ontRef, $ont_tr, $cl_ex, $ontTableRef);

    }
    else{

        die "incorrect input parameters\n";
    }

    my $gaout;
    eval {
        $gaout = $self->util_ga_client()->save_one_genome_v1({
			workspace => $workspace_name,
	        name => $outGenome,
	        data => $genome,
	        provenance => $provenance,
	        hidden => 0
		});
    };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }

    print "\nMethod sucuessfully completed\n";
    print("saved:".Dumper($gaout->{info})."\n");
    $output = { 'Ontology Translator' => [$gaout->{info}]};

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
namespace_id_rule has a value which is a reference to a list where each element is a string

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
namespace_id_rule has a value which is a reference to a list where each element is a string


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



=head2 ListOntologiesParams

=over 4



=item Description

List all ontologies in one or more workspaces


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_names has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_names has a value which is a reference to a list where each element is a string


=end text

=back



=head2 ontologies

=over 4



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



=head2 termInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
def has a value which is a reference to a list where each element is a string
synonym has a value which is a reference to a list where each element is a string
xref has a value which is a reference to a list where each element is a string
property_value has a value which is a reference to a list where each element is a string
is_a has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
def has a value which is a reference to a list where each element is a string
synonym has a value which is a reference to a list where each element is a string
xref has a value which is a reference to a list where each element is a string
property_value has a value which is a reference to a list where each element is a string
is_a has a value which is a reference to a list where each element is a string


=end text

=back



=head2 GetOntologyTermsOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
term_info has a value which is a reference to a hash where the key is a string and the value is a sdk_ontology_jmc.termInfo

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
term_info has a value which is a reference to a hash where the key is a string and the value is a sdk_ontology_jmc.termInfo


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
