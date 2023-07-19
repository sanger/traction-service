# frozen_string_literal: true

class QcReceptionsFactory
  include ActiveModel::Model

  attr_accessor :qc_reception

  validates :qc_results_list, presence: true

  @@qc_fields_to_insert = [
    "sheared_femto_fragment_size",
    "post_spri_concentration",
    "post_spri_volume",
    "final_nano_drop_280",
    "final_nano_drop_230",
    "final_nano_drop",
    "shearing_qc_comments"
  ]

  def qc_results_list
    @qc_results_list ||= []
  end

  def qc_results_list=(attributes)
    @qc_results_list = attributes
    puts @qc_results_list
  end
  
  def create_data
    # 1. Iterate the array and iterate each object 
    # 2. For each qc if assay_type exists, then create qc_results
    @qc_results_list.each do |request_obj|
      request_obj.each do |qc,value|
        if @@qc_fields_to_insert.include? qc
          assay_type = QcAssayType.find_by(key: qc)
          assay_type ? create_row(qc,value,request_obj,assay_type) : next
        end
      end
    end
  end

  def create_row(qc_key, qc_value, request_obj, assay_type)
    labware_barcode = request_obj["labware_barcode"]
    sample_external_id = request_obj["sample_external_id"]
    qc_result = create_qc_result!(labware_barcode, sample_external_id, assay_type.id, qc_value)
    build_qc_result_message(qc_result)
  end

  def build_qc_result_message(qc_result)
    messages << qc_result
  end

  def create_qc_result!(labware_barcode, sample_external_id, qc_assay_type_id, value)
    QcResult.create!(labware_barcode:, sample_external_id:, qc_assay_type_id:, value:)
  end

  def create_qc_results!
    if qc_results_list.empty?
      errors.add('QcReceptionsFactory', 'the qc_results_list is empty')
      return
    end
    create_data
    true
  end

  def messages
    @messages ||= []
  end
end
