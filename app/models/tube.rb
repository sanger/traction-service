class Tube < ApplicationRecord
  has_one :library

  after_create :generate_barcode

  private

  def generate_barcode
    update_column(:barcode, "TRAC-#{id}")
  end
end
