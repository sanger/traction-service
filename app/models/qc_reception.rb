# frozen_string_literal: true

# A QcReception makes an entry in qc_receptions for the requests from
# TOL consumer to store the qc data in qc_results table
class QcReception < ApplicationRecord
  extend NestedValidation

  # validates_nested :qc_receptions_factory, flatten_keys: true

  delegate :qc_results_list, :qc_results_list=, :create_qc_results!,
           :messages, to: :qc_receptions_factory

  private

  def qc_receptions_factory
    @qc_receptions_factory ||= QcReceptionsFactory.new(qc_reception: self)
  end
end
