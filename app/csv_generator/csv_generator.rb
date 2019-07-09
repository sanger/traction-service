# frozen_string_literal: true

class CSVGenerator
  include ActiveModel::Model

  attr_accessor :run, :configuration

  def generate_sample_sheet

    headers = []
    data = []

    configuration.columns.map do |x|
      header = x[0].split('_').join(' ').capitalize
      headers << header

      d = instance_value(x[1])
      data << d
    end

    file = nil
    CSV.open('file.csv', 'wb') do |csv|
      csv << headers
      csv << data
      file = csv
    end
    file

    # options: 'wb' is write and binary mode
    # file = nil
    # CSV.open('file.csv', 'wb') do |csv|
    #   headers = configuration.columns
    #   csv << headers
    #
    #   run.wells.each do |well|
    #     data = [
    #       run.system_name,
    #       run.name,
    #       well.position,
    #       well.library.sample.name,
    #       well.movie_time,
    #       well.insert_size,
    #       run.template_prep_kit_box_barcode,
    #       run.binding_kit_box_barcode,
    #       run.sequencing_kit_box_barcode,
    #       well.sequencing_mode,
    #       well.on_plate_loading_concentration,
    #       run.dna_control_complex_box_barcode,
    #       well.generate_ccs_data
    #     ]
    #
    #     csv << data
    #   end
    #
    #   file = csv
    # end
    # file

  end

  private

  def instance_value(field)
    case field[:type]
    when :string
      field[:value]
    when :model
      evaluate_method_chain(run, field[:value].split('.'))
    when :constant
      evaluate_method_chain(field[:value].split('.').first.constantize,
                            field[:value].split('.')[1..-1])
    end
  end

  def evaluate_method_chain(object, chain)
    chain.inject(object, :send)
  end


end
