# frozen_string_literal: true

# This task is used for creating ont_min_know_versions and
# It is invoked before data migrations to set the version according to the deprecated string version.

namespace :min_know_versions do
  desc 'Create ONT Min Know versions'
  task create: :environment do
    # Can load this from config in the future if need be
    versions = {
      v22: {
        name: 'v22',
        active: true,
        default: true
      }
    }
    versions.each do |_title, version|
      Ont::MinKnowVersion.find_or_create_by!(version)
    end

    puts '-> ONT MinKnow versions successfully created'
  end
end
