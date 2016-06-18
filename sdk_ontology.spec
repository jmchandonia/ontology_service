/*
A KBase module: sdk_ontology
This module convert given KBase annotations of a genome to GO terms.
*/

module sdk_ontology {

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
