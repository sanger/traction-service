# frozen_string_literal: true

# Receives an array of qc_results for multiple samples
# Converts them into rows to save them in the qc_results table
# Constructs the RabbitMQ message for each qc_result
class QcReceptionsFactory
  include ActiveModel::Model

  attr_accessor :qc_reception
  attr_writer :qc_results_list

  USED_BY = 'tol'
  validates :qc_results_list, presence: true
  validates_with QcReceptionsFactoryValidator, used_by: USED_BY

  def qc_results_list
    @qc_results_list ||= []
  end

  def create_qc_results!
    if @qc_results_list.empty?
      errors.add('QcReceptionsFactory', 'the qc_results_list is empty')
      return
    end
    create_data
    true
  end

  def create_data
    # 1. Iterate the array and for each object
    # 2. iterate through qc fields
    # 3. for each qc, if assay_type exists
    # 4. then create qc_results
    assay_types_hash = assay_types
    @qc_results_list.each do |request_obj|
      request_obj.each do |qc, value|
        next unless assay_types_hash.keys.include? qc

        create_row(request_obj, assay_types_hash[qc], value)
      end
    end
  end

  def assay_types
    assay_types = QcAssayType.where(used_by: USED_BY).pluck(:id, :key)
    assay_types.to_h.invert
  end

  def create_row(request_obj, qc_assay_type_id, value)
    qc_result = create_qc_result!(request_obj, qc_assay_type_id, value)
    build_qc_result_message(qc_result)
  end

  def build_qc_result_message(qc_result)
    messages << qc_result
  end

  def create_qc_result!(request_obj, qc_assay_type_id, value)
    QcResult.create!(
      labware_barcode: request_obj['labware_barcode'],
      sample_external_id: request_obj['sample_external_id'],
      qc_assay_type_id:,
      value:,
      qc_reception_id: @qc_reception.id
    )
  end

  def messages
    @messages ||= []
  end
end
