# frozen_string_literal: true

module Ont
  # Ont::Instrument
  class Instrument < ApplicationRecord
    enum instrument_type: { MinIon: 0, GridIon: 1, PromethIon: 2 }
    validates :name, presence: true, uniqueness: true
  end
end
