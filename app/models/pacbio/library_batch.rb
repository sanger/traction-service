# frozen_string_literal: true

module Pacbio
  # Pacbio::LibraryBatch is a audit record created to keep track of libraries created in batches
  class LibraryBatch < ApplicationRecord
    validates :libraries, presence: true

    has_many :libraries, class_name: 'Pacbio::Library', dependent: :nullify,
                         foreign_key: :pacbio_library_batch_id, inverse_of: :library_batch

    # This allows the creation of libraries when creating a library batch
    accepts_nested_attributes_for :libraries
  end
end
