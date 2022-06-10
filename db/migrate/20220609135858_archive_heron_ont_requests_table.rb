# frozen_string_literal: true

# We'll shortly be removing this table entirely. We already have a backup on the
# cold store and I (JG) have a local copy as well. However this should let us
# take a slightly more cautious approach
class ArchiveHeronOntRequestsTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :ont_requests, :heron_ont_requests
  end
end
