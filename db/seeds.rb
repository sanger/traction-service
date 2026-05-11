# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).

Rake::Task['library_types:create'].invoke
Rake::Task['data_types:create'].invoke
Rake::Task['tags:create:traction_all'].invoke
Rake::Task['qc_assay_types:create'].invoke
Rake::Task['smrt_link_versions:create'].invoke
Rake::Task['ont_instruments:create'].invoke
Rake::Task['min_know_versions:create'].invoke
Rake::Task['tol_tubes_report_view:create'].invoke
# We don't want to expose these keys in non-development environments, so we only seed them for development
Rake::Task['local_api_key:create'].invoke if Rails.env.development?
