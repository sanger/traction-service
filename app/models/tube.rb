class Tube < ApplicationRecord
  belongs_to :material, polymorphic: true

  after_create :generate_barcode

  private

  def generate_barcode
    update_column(:barcode, "TRAC-#{id}")
  end
end
