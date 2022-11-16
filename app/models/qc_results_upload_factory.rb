# frozen_string_literal: true

class QcResultsUploadFactory
  include ActiveModel::Model

  attr_accessor :qc_results_upload

  # Input
  # " ,,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,Shear & SPRI QC,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,SE LIMS,,
  #   Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul),DNA vol (ul),DNA total ng,Femto dilution,ND 260/280,ND 260/230,ND Quant (ng/ul),Femto Frag Size,GQN >30000,Femto pdf,LR DECISION,LMW Peak PE,TOL DECISION [Post-Extraction],Date started,Pre-shear SPRI Vol input (uL),SPRI Volume (x0.6),Final Elution (uL),DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul),Final Elution Volume (ul),Total DNA ng,Femto Dil (ul),ND 260/280,ND 260/230,ND Quant (ng/uL),% DNA Recovery,Femto Fragment size (mode),GQN 10kb threshold,Femto pdf,LMW Peak PS,LR DECISION,Date Complete,TOL DECISION [Post-Shearing],ToL ID ,SE Number,Date in PB Lab (Auto),PB CCS Yield (Gb)
  #   Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,,Pass,,,idCheUrba1,SE293337P,24/06/2022,20.18
  #   Production 1,FD20706871,DTOL12932868,,0.48,,,04/05/2022,Powermash,21,Non-plant,2h@25C,,,,Yes,FD38542653,SA00930879,B1 ,3.1,385,1193.5,11.4,1.79,0.33,7.4,44697,3.9,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.8,45.4,717.32,62.2,1.85,1.25,26,60.1,14833,8.9,Sheared.Femto.9764-6843,,Pass,,,ilNemSwae1,SE293338Q,24/06/2022,27.56"

  # - Get assay types for used_by
  # - Filter headers by assay type
  # - Convert body to json

  def create_entities!
    true
  end

  def get_csv_data
    qc_results_upload.csv_data
  end

  def get_used_by
    qc_results_upload.used_by
  end

  # return a list of strings, where each string is a row
  # returns ['grouping', 'headers', 'row1', 'row2', 'row3']
  def csv_rows
    get_csv_data.split("\n")
  end

  # Check headers are unique/ return error
  # ? lowercase/ trim
  # return ["Batch", "Tissue Tube ID", "Sanger sample ID", "Species", "Genome Size"]
  def csv_headers
    csv_rows[1].split(',')
  end

  def csv_body
    csv_rows[2..]

    # body.each do |row|
    #   create_qc_result_records(row)
    # end
  end

  def create_qc_decision!(status, decision_made_by)
    QcDecision.create!(status:, decision_made_by:)
  end

  def create_qc_result!(labware_barcode, sample_external_id, qc_assay_type_id, value)
    QcResult.create!(labware_barcode:, sample_external_id:, qc_assay_type_id:, value:)
  end

  def create_qc_decision_result!(qc_result_id, qc_decision_id)
    QcDecisionResult.create!(qc_result_id:, qc_decision_id:)
  end

  # might be useful?
  # pivoting the data
  def body_to_json
    [
      # per row
      {
        barcode: '',
        sample: '',
        tol_decision: '',
        long_decision: '',
        'DNA vol (ul)': 385,
        'Femto dilution': 18.12
      },
      {
        'DNA vol (ul)': 380,
        'Femto dilution': 11.4
      }
    ]
  end

  # params: row_str e.g 'row1col1,row1col2,row1col3'
  # return: ['row1col1','row1col2','row1col3']
  def row_as_list(row_str)
    # row_str.split(",")
  end

  def create_qc_decision_records(row); end

  # params: row_str e.g ['row1col1','row1col2','row1col3']
  def create_qc_result_records(row)
    # barcode and sample will be the same for each qc_result record
    # labware_barcode =
    # sample_external_id =

    # get_qc_assay_type_headers_from_config
    # loop qc_assay_types_headers
    # for each header, in the row

    # check the header exists as qc assay type in DB
    # get_qc_assay_type_id_for_label
    # get the value for each of that headers

    # Create one record for each qc_assay_type

    # call create_qc_decision_records function
    # to create one record for each decision
    # - Long read
    # - TOL (if TOL Decision exists in CSV)
  end

  # create qc_result record with
  # labware_barcode
  # sample_external_id
  # qc_assay_type_id
  # value
  # date?
  def create_qc_result(labware_barcode, sample_external_id, qc_assay_type_id, value)
    # date?
    # QCResult.create!()
  end

  def create_qc_decision_records; end

  def create_qc_decision_result(*attr)
    QcDecisionResult.create(*attr)
  end

  # return: a list of header labels
  # e.g.
  def get_qc_assay_type_headers_for_used_by
    # QcAssayType.where(used_by: <>)

    # ["Batch", "Tissue Tube ID", "Sanger sample ID", "Species", "Genome Size", "Tissue FluidX rack ID", "Rack well location", "Date", "Crush Method", "Tissue Mass (mg)", "Tissue type", "Lysis"]
  end

  # param: label e.g. 'DNA tube ID'
  # returns int, of QCAssayType ID
  def get_qc_assay_type_id_for_label(label)
    QcAssayType.find_by(label:)
  end

  # loop through body rows
  # for each row
  # get the tissue tube id (labware_barcode)
  # get the sanger sample ID (sample_external_id)

  # get qc data
  # for each qc data
  # get the qc assay type id

  # fetch which qc assay types we know of in DB
  # return list
  # e.g.
  # ['DNA tube ID', 'Qubit DNA Quant (ng/ul)', 'DNA vol (ul)']
  def qc_assay_types_headers
    # get from database
    # list of headers to get
    #
  end
end
