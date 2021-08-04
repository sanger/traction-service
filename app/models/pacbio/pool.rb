# frozen_string_literal: true

module Pacbio
  # Pool
  class Pool < ApplicationRecord
    belongs_to :tube
    has_many :libraries, class_name: 'Pacbio::Library', foreign_key: :pacbio_pool_id,
                         dependent: :destroy, inverse_of: :pool
    has_many :well_pools, class_name: 'Pacbio::WellPool', foreign_key: :pacbio_pool_id,
                          dependent: :nullify, inverse_of: :pool
    has_many :wells, class_name: 'Pacbio::Well', through: :well_pools
    has_many :requests, through: :libraries

    # This is dependent on the requests association, so needs to be included
    # after that is defined
    include PlateSourcedLibrary

    validates :libraries, presence: true
    validates_with TagValidator
  end
end
