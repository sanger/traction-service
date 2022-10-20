# frozen_string_literal: true

# In this data migration, first we make sure that smrt_link_versions and
# smrt_link_options are created and then we set the smrt_link_version of
# runs by checking the version name in the old string
# smrt_link_version_deprecated column.

namespace :pacbio_runs do
  task migrate_pacbio_run_smrt_link_versions: [:environment, 'smrt_link_versions:create'] do
    # Invoke rake task to create version and option records.

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
