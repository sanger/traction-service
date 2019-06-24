module Pacbio
  class Library < ApplicationRecord

    validates_presence_of :volume, :concentration, :library_kit_barcode, :fragment_size

    has_one :tag, :class_name => 'Pacbio::Tag', foreign_key: 'pacbio_library_id', required: true
  end
end