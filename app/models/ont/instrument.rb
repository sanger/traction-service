# frozen_string_literal: true

module Ont
  # Ont::Instrument
  class Instrument < ApplicationRecord
    validates :name, presence: true, uniqueness: true
  end
end
