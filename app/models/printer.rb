# frozen_string_literal: true

class Printer < ApplicationRecord

  enum labware_type: { tube: 0, plate96: 1, plate384: 2 }
end
