# frozen_string_literal: true

# A QcReception makes an entry in qc_receptions for all the requests
# received TOL consumer on the qc_reception endpoint.
# Stores the qc data in qc_results table with the associated qc_reception_id
class QcReception < ApplicationRecord
  extend NestedValidation

  has_many :qc_results, dependent: :restrict_with_error

  validates :source, presence: true
  validates_nested :qc_receptions_factory, flatten_keys: true

  delegate :qc_results_list, :qc_results_list=, :create_qc_results!,
           :messages, to: :qc_receptions_factory

  private

  def qc_receptions_factory
    @qc_receptions_factory ||= QcReceptionsFactory.new(qc_reception: self)
  end
end
