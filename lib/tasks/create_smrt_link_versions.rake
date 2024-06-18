# frozen_string_literal: true

# This task is used for creating pacbio_smrt_link_versions and
# pacbio_smrt_link_options as database seed. It is also invoked before data
# migrations to set the version according to the deprecated string version.

namespace :smrt_link_versions do
  desc 'Create Pacbio SMRT Link versions and options'
  task create: :environment do
    # Load Pacbio SMRT Link versions and options configuration.
    config_name = 'pacbio_smrt_link_versions.yml'
    config_path = Rails.root.join('config', config_name)
    config = YAML.load_file(config_path, aliases: true)[Rails.env]

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
        next if smrt_link_version.smrt_link_options.include? smrt_link_option

        smrt_link_version.smrt_link_options << smrt_link_option
        Pacbio::Run.where(smrt_link_version:).find_each do |run|
          run.update_smrt_link_options(smrt_link_option.key => smrt_link_option.default_value)
        end
      end
    end

    # Save updated SMRT Link versions.
    smrt_link_versions.values.each(&:save!)
    puts '-> Pacbio SMRT Link versions and options successfully created'
  end
end
