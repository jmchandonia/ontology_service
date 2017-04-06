/*
A KBase module: sdk_ontology
This module convert given KBase annotations of a genome to GO terms.
*/

module sdk_ontology {

    /*
        workspace - the name of the workspace for input/output
        ontology_dictionary - reference to ontology dictionary


    */
    typedef structure {

        string ontology_dictionary_ref;

    } ListOntologyTermsParams;

    typedef structure {
        string ontology;
        string namespace;
        list <string> term_id;
    }OntologyTermsOut;


    funcdef list_ontology_terms (ListOntologyTermsParams params) returns (OntologyTermsOut output) authentication required;


    /*
        Ontology overview


    */

    typedef structure {
        list <string> ontology_dictionary_ref;

    } OntologyOverviewParams;

    typedef structure {
        string ontology;
        string namespace;
        string data_version;
        string format_version;
        int number_of_terms;
        string dictionary_ref;
    }overViewInfo;

    typedef structure{

        list <overViewInfo> dictionaries_meta;
    }OntologyOverviewOut;


    funcdef ontology_overview (OntologyOverviewParams params) returns (OntologyOverviewOut output) authentication required;

    /*
        List public ontologies
    */

    typedef list <string> public_ontologies;

    funcdef list_public_ontologies () returns (public_ontologies) authentication required;

    /*
        List public translations
    */

    typedef list <string> public_translations;

    funcdef list_public_translations () returns (public_translations) authentication required;

    /*
        get ontology terms
    */

    typedef structure{
        string ontology_dictionary_ref;
        list <string> term_ids;

    }GetOntologyTermsParams;


    typedef structure{
        string name;
        string id;
    }term_info;


    typedef structure {

        mapping <string, list<string>> term_info;

    }GetOntologyTermsOut;

    funcdef get_ontology_terms (GetOntologyTermsParams params) returns (GetOntologyTermsOut output) authentication required;



    /*
        get equivalent terms
    */

    typedef structure{
        string ontology_trans_ref;
        list <string> term_ids;

    }GetEqTermsParams;


    typedef structure{
        string name;
        list <string> terms;
    }term_info_list;


    typedef structure {

        mapping <string, list<string>> term_info_list;

    }GetEqTermsOut;

    funcdef get_equivalent_terms (GetEqTermsParams params) returns (GetEqTermsOut output) authentication required;


    /*
        workspace - the name of the workspace for input/output
        input_genome - reference to the input genome object
        ontology_translation - optional reference to user specified ontology translation map
        output_genome - the name of the mapped genome annotation object

        @optional ontology_translation
    */

    typedef structure {
        string workspace;
        string input_genome;
        string ontology_translation;
        string translation_behavior;
 	    string custom_translation;
        string clear_existing;
        string output_genome;
    } ElectronicAnnotationParams;

    typedef structure {
        string report_name;
        string report_ref;
        string output_genome_ref;
        int n_total_features;
        int n_features_mapped;
    } ElectronicAnnotationResults;


    funcdef annotationtogo(ElectronicAnnotationParams params) returns (ElectronicAnnotationResults output)
        authentication required;
};
