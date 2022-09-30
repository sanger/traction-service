# frozen_string_literal: true

namespace :pacbio_runs do
  task migrate_pacbio_run_smrt_link_versions: :environment do
    version10 = Pacbio::SmrtLinkVersion.find_or_create_by!(name: 'v10', default: true, active: true)
    version11 = Pacbio::SmrtLinkVersion.find_or_create_by!(name: 'v11', default: false, active: true)

    yes_no = %w[Yes No].freeze
    generate = ['In SMRT Link', 'On Instrument', 'Do Not Generate'].freeze
    times = %w[15.0 20.0 24.0 30.0].freeze

    # v10 options

    key = 'ccs_analysis_output'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Ccs Analysis Output:',
      default_value: 'Yes',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: yes_no }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'Yes,No'
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj

    key = 'generate_hifi'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Generate HiFi:',
      default_value: 'On Instrument',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: generate }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'In SMRT Link,Do Not Generate,On Instrument'
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj

    # v11 options

    key = 'ccs_analysis_output_include_low_quality_reads'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create(
      label: 'Include Low Quality Reads:',
      default_value: 'Yes',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: yes_no }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'Yes,No'
    )
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'ccs_analysis_output_include_kinetics_information'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Include Kinetics Information:',
      default_value: 'Yes',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: yes_no }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'Yes,No'
    )
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'fivemc_calls_in_cpg_motifs'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: '5mC Calls In CpG Motifs:',
      default_value: 'Yes',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: yes_no }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'Yes,No'
    )
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'demultiplex_barcodes'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create(
      label: 'Demultiplex Barcodes:',
      default_value: 'In SMRT Link',
      validations: {
        PresenceValidator: {},
        InclusionValidator: { in: generate }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:list],
      select_options: 'In SMRT Link,Do Not Generate,On Instrument'
    )
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    # common options

    key = 'on_plate_loading_concentration'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'On Plate Loading Concentration (mP):',
      default_value: nil,
      validations: { PresenceValidator: {} }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:number],
      select_options: nil
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'binding_kit_box_barcode'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Binding Kit Box Barcode:',
      default_value: nil,
      validations: { PresenceValidator: {} }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:number],
      select_options: nil
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'pre_extension_time'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Pre-extension time:',
      default_value: 2,
      validations: {
        NumericalityValidator: { allow_blank: true }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:number],
      select_options: nil
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'loading_target_p1_plus_p2'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Loading Target (P1 + P2):',
      default_value: 0.85,
      validations: {
        NumericalityValidator: {
          allow_blank: true,
          greater_than_or_equal_to: 0.0,
          less_than_or_equal_to: 1.0
        }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:number],
      select_options: nil
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    key = 'movie_time'
    obj = Pacbio::SmrtLinkOption.where(key:).first_or_create!(
      label: 'Movie Time (hrs):',
      default_value: nil,
      validations: {
        PresenceValidator: {},
        NumericalityValidator: {
          greater_than_or_equal_to: 0.1,
          less_than_or_equal_to: 30
        },
        InclusionValidator: { in: times }
      }.with_indifferent_access,
      data_type: Pacbio::SmrtLinkOption.data_types[:number],
      select_options: '15.0,20.0,24.0,30.0'
    )
    version10.smrt_link_options << obj unless version10.smrt_link_options.include? obj
    version11.smrt_link_options << obj unless version11.smrt_link_options.include? obj

    version10.save!
    version11.save!

    # Set SMRT Link Versions on Pacbio Runs.

    runs = Pacbio::Run.all
    runs.each do |run|
      if run.smrt_link_version_deprecated.present?
        run.smrt_link_version = Pacbio::SmrtLinkVersion.where(name: run.smrt_link_version_deprecated, active: true).first
        run.save!
      end
    end
  end
end
