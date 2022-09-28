# frozen_string_literal: true
namespace :pacbio_runs do
    task migrate_pacbio_run_smrt_link_versions: :environment do
        
        version10 = Pacbio::SmrtLinkVersion.find_or_create_by!(name: 'v10', default: true, active: true)
        version11 = Pacbio::SmrtLinkVersion.find_or_create_by!(name: 'v11', default: false, active: true)

        # XXX: What about system name?

        # v10 options

        key = 'ccs_analysis_output'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Ccs Analysis Output:',
            default_value: "Yes", # XXX: From UI, New Run
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "Yes, No"   # XXX: What is the format of this?
        )
        unless version10.smrt_link_options.include? obj
            version10.smrt_link_options << obj
        end
        puts 'Y' * 80
        puts version10.smrt_link_options.include? obj

        key = 'generate_hifi'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Generate HiFi:',
            default_value: "On Instrument", # XXX: From UI, New Run
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "In SMRT Link, Do Not Generate, On Instrument"   # XXX: What is the format of this?
        )
        # TODO: Check version10.options and add

        # v11 options
        key = 'ccs_analysis_output_include_low_quality_reads'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Include Low Quality Reads:',
            default_value: "Yes", # XXX: Made-up
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "Yes, No"   # XXX: What is the format of this?
        )
        # TODO: Check version11.options and add


        key = 'fivemc_calls_in_cpg_motifs'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: '5mC Calls In CpG Motifs:',  # Made-up
            default_value: "Yes", # XXX: Made up
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "Yes, No"   # XXX: What is the format of this?
        )
        # TODO: Check version11.options and add

        key = 'ccs_analysis_output_include_kinetics_information'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Include Kinetics Information:', # Made-up
            default_value: "Yes", # XXX: Made-up
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "Yes, No"   # XXX: What is the format of this?
        )
        # TODO: Check version11.options and add


        key = 'demultiplex_barcodes'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: ':', # Made-up
            default_value: "In SMRT Link", # XXX: Made-up
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:list],
            select_options: "In SMRT Link, Do Not Generate, On Instrument"   # XXX: What is the format of this?
        )
        # TODO: Check version11.options and add


        # common options
        key = 'on_plate_loading_concentration'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'On Plate Loading Concentration (mP):',
            default_value: nil, # XXX: May vary by sample
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:number],
            select_options: nil
        )
        # TODO: Check both version10.options and version11.options and add

        key = 'binding_kit_box_barcode'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Binding Kit Box Barcode:',  # XXX: UI label is "Default Binding Kit Box Barcode:"
            default_value: nil, # XXX: From UI, New Run. Is it an empty string?
            # name, options mapping
            validations: {'ActiveRecord::Validations::PresenceValidator': {}}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:number],
            select_options: nil
        )
        # TODO: Check both version10.options and version11.options and add

        key = 'pre_extension_time'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Pre-extension time:',
            default_value: 2, # XXX: From UI, New Run
            # name, options mapping
            validations: {'ActiveRecord::Validations::NumericalityValidator': {
                allow_blank: true,
                }}.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:number],
            select_options: nil
        )
        # TODO: Check both version10.options and version11.options and add

        key = 'loading_target_p1_plus_p2'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Loading Target (P1 + P2):',
            default_value: 0.85, # XXX: From UI, New Run
            # name, options mapping
            validations: {
                'ActiveRecord::Validations::NumericalityValidator': {
                    allow_blank: true,
                    greater_than_or_equal_to: 0.0, 
                    less_than_or_equal_to: 1.0}
                }.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:number],
            select_options: nil
        )
        # TODO: Check both version10.options and version11.options and add
        
        key = 'movie_time'
        obj = Pacbio::SmrtLinkOption.where(key: key).first_or_create(
            label: 'Movie Time (hrs):',
            default_value: nil, # XXX: 
            # name, options mapping
            validations: {
                'ActiveRecord::Validations::PresenceValidator': {},
                'ActiveRecord::Validations::NumericalityValidator': {
                    greater_than_or_equal_to: 0.1, 
                    less_than_or_equal_to: 30}
            }.with_indifferent_access,
            data_type: Pacbio::SmrtLinkOption.data_types[:number],
            select_options: nil # XXX: Predefined times 15, 20, 24, 30 ?
        )
        # TODO: Check both version10.options and version11.options and add

        # TODO: Save version10 and version11
        version10.save!

        # TODO: Set run versions


        # NOTE: Validator classes
        # ActiveRecord::Validations::AbsenceValidator
        # ActiveRecord::Validations::AssociatedValidator
        # ActiveRecord::Validations::ClassMethods
        # ActiveRecord::Validations::LengthValidator
        # ActiveRecord::Validations::NumericalityValidator
        # ActiveRecord::Validations::PresenceValidator
        # ActiveRecord::Validations::UniquenessValidator

        # NOTE: Data Types for options
        # enum data_type: { string: 0, number: 1, list: 2 }




        # v10: {
        #     generate_hifi: GENERATE,
        #     ccs_analysis_output: YES_NO
        #   },
        #   v11: {
        #     ccs_analysis_output_include_kinetics_information: YES_NO,
        #     ccs_analysis_output_include_low_quality_reads: YES_NO,
        #     fivemc_calls_in_cpg_motifs: YES_NO,
        #     demultiplex_barcodes: GENERATE
    end
end