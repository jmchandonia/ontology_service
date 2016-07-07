use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use sdk_ontology::sdk_ontologyImpl;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('sdk_ontology');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new Bio::KBase::workspace::Client($ws_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1);
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$sdk_ontology::sdk_ontologyServer::CallContext = $ctx;
my $impl = new sdk_ontology::sdk_ontologyImpl();

#my $exp = "e.coli";
#my $exp = "Shew_proper_data";
#my $geno = "Shew_GenBank_RAST_tk_reannotation";

my $params = {
input_genome => "ecoli",
workspace => "janakakbase:1455821214132",
ontology_translation => "ec2go",
translation_behavior => "featureOnly",
custom_translation => "",
output_genome => "ecoliModified"
};

my $shew = {
input_genome => "Shew_uniprot",
workspace => "janakakbase:1455821214132",
ontology_translation => "uniprotkb_kw2go",
translation_behavior => "annoandOnt",
custom_translation => "",
clear_existing => 0,
output_genome => "shew_uniprot_ec2go"
};

my $list_ontology_terms_test = {
    workspace => "KBaseOntology",
    ontology_dictionary_ref => "6308/9/2"
};

my $ontology_overview_test ={
    ontology_dictionary_ref => ["6308/9/2","6308/8/1"]
};

my $get_ontology_terms_test = {
    term_ids => ["SSO:000008325","SSO:000005093","SSO:000007691","SSO:000005610"],
    ontology_dictionary_ref => "6308/8/1"
};
my $get_eq_terms_test = {
    term_ids => ["SSO:000005862","SSO:000000019","SSO:000002940","SSO:000002499"],
    ontology_trans_ref => "6308/14/1"
};

eval {
	#my $ret =$impl->seedtogo($ws,$geno,$trt,$out);
  	#my $ret =$impl->annotationtogo($shew);
    #my $ret =$impl->list_ontology_terms($list_ontology_terms_test);
    my $ret =$impl->ontology_overview($ontology_overview_test);
    #my $ret =$impl->lsit_public_ontologies();
    #my $ret =$impl->list_public_translations();
    #my $ret =$impl->get_ontology_terms($get_ontology_terms_test);
    #my $ret =$impl->get_equivalent_terms($get_eq_terms_test);
};



my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
if (defined($err)) {
    if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
        die("Error while running tests: " . $err->trace->as_string);
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'sdk_ontology', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
}
