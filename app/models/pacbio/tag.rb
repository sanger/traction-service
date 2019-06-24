module Pacbio

  class Tag < ApplicationRecord

    validates_presence_of :oligo

    belongs_to :library, :class_name => 'Pacbio::Library', foreign_key: :pacbio_library_id, optional: true
  end
end