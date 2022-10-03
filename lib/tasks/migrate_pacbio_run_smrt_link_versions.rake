# frozen_string_literal: true

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
