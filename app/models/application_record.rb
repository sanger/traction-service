# frozen_string_literal: true

# ApplicationRecord
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: Rails.configuration.db_connection, reading: Rails.configuration.db_connection }

end
