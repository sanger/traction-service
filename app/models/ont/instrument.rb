# frozen_string_literal: true

module Ont
  # Ont::Instrument
  class Instrument < ApplicationRecord
    include Uuidable

    enum instrument_type: { MinION: 0, GridION: 1, PromethION: 2 }
    validates :name, presence: true, uniqueness: true
  end
end
