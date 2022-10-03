# frozen_string_literal: true

namespace :pacbio_runs do
  task migrate_pacbio_run_smrt_link_versions_yaml: :environment do
    # Load Pacbio SMRT Link versions and options configuration.
    config_name = 'pacbio_smrt_link_versions.yml'
    config_path = Rails.root.join('config', config_name)
    config = YAML.load_file(config_path)[Rails.env]

    # Create Pacbio SMRT Link versions.
    versions = config['versions']
    smrt_link_versions = {} # records by name created so far
    versions.each do |_title, version|
      smrt_link_version = Pacbio::SmrtLinkVersion.where(name: version['name']).first_or_create!(version)
      smrt_link_versions[smrt_link_version.name] = smrt_link_version
    end

    # Create Pacbio SMRT Link options.
    options = config['options']
    options.each do |_title, option|
      versions = option.delete('versions') # names of records to be used later
      smrt_link_option = Pacbio::SmrtLinkOption.where(key: option['key']).first_or_create!(option)

      # Add SMRT Link option to the specified SMRT Link versions.
      versions.each do |name|
        smrt_link_version = smrt_link_versions[name]
        unless smrt_link_version.smrt_link_options.include? smrt_link_option
          smrt_link_version.smrt_link_options << smrt_link_option
        end
      end
    end

    # Save updated SMRT Link versions.
    smrt_link_versions.values.each(&:save!)

    # Migrate Pacbio runs from string versions to records.
    runs = Pacbio::Run.all
    runs.each do |run|
      if run.smrt_link_version_deprecated.present?
        run.smrt_link_version = Pacbio::SmrtLinkVersion.where(name: run.smrt_link_version_deprecated, active: true).first
        run.save!
      end
    end
  end
end
