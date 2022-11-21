# frozen_string_literal: true

class QcResultsUploadFactory
  include ActiveModel::Model

  attr_accessor :qc_results_upload

  delegate :csv_data, to: :qc_results_upload
  delegate :used_by, to: :qc_results_upload

  LR_DECISION_FIELD = 'LR EXTRACTION DECISION'
  TOL_DECISION_FIELD = 'TOL DECISION [Post-Extraction]'

  # Input
  # ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,Shear & SPRI QC,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,,SEQUENCING DATA,
  # Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul),DNA vol (ul),DNA total ng,Femto dilution,ND 260/280,ND 260/230,ND Quant (ng/ul),Femto Frag Size,GQN >30000,Femto pdf [post-extraction],Pass,LMW Peak PE,TOL DECISION [Post-Extraction],Date started,Pre-shear SPRI Vol input (uL),SPRI Volume (x0.6),Final Elution (uL),DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul),Final Elution Volume (ul),Total DNA ng,Femto Dil (ul),ND 260/280,ND 260/230,ND Quant (ng/uL),% DNA Recovery,Femto Fragment size (post-shear),GQN 10kb threshold,Femto pdf [post-shear],LMW Peak PS,LR SHEARING DECISION ,Date Complete,TOL DECISION [Post-Shearing],ToL ID ,Genome size,ToL ID,PB comments/yields,PB Run Status
  # Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,,Pass,,,idCheUrba1,0.52725,idCheUrba1,,PASS
  # Production 1,FD20706871,DTOL12932868,,0.48,,,04/05/2022,Powermash,21,Non-plant,2h@25C,,,,Yes,FD38542653,SA00930879,B1 ,3.1,385,1193.5,11.4,1.79,0.33,7.4,44697,3.9,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.8,45.4,717.32,62.2,1.85,1.25,26,60.1,14833,8.9,Sheared.Femto.9764-6843,,Pass,,,ilNemSwae1,0.478,ilNemSwae1,,PASS
  # Production 1,FS05287128,DTOL12932865,,0.38,,,04/05/2022,Powermash,8.7,Non-plant,2h@25C,,,,Yes,FD38542654,SA00930879,C1,7.58,385,2918.3,29.32,1.47,0.4,10,26330,2.9,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,38.6,45.4,1752.44,153.4,1.91,1.88,47.5,60.1,14620,7.6,Sheared.Femto.9764-6843,,Pass,,,iyPanBank1,0.375,iyPanBank1,SE293339R,PASS
  # Production 1,FS05287158,DTOL12932866,,0.40,,,04/05/2022,Powermash,13.7,Non-plant,2h@25C,,,,Yes,FD38542655,SA00930879,D1,3.5,385,1347.5,13,1.64,0.3,7.7,20800,1.7,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.7,45.4,712.78,61.8,1.82,1.12,27.6,52.9,12178,6.3,Sheared.Femto.9764-6843,,Pass,,,icLagHirt1,0.404073,icLagHirt1,SE293340K,PASS
  # Production 1,FD20709486,DTOL12932858,,0.68,,,04/05/2022,Powermash,11.6,Non-plant,2h@25C,,,,Yes,FD38542656,SA00930879,E1,2.62,385,1008.7,9.48,1.29,0.3,7.2,29810,2.7,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,13.7,45.4,621.98,53.8,1.82,1.07,26.5,61.7,14620,7.3,Sheared.Femto.9764-6843,,Pass,,,ihLegLimb1,0.676,ihLegLimb1,SE293341L,PASS
  # Production 1,FD20709416,DTOL12932857,,0.45,,,04/05/2022,Powermash,8.2,Non-plant,2h@25C,,,,Yes,FD38542657,SA00930879,F1,8.52,385,3280.2,33.08,1.74,0.54,16.8,35639,3.3,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,40,45.4,1816,159,1.8,1.37,60.1,55.4,14567,7.5,Sheared.Femto.9764-6843,,Pass,,,ilNycReva1,0.4485,ilNycReva1,SE293342M,FAIL
  # Production 1,FD20706843,DTOL12932856,,0.93,,,04/05/2022,Powermash,12.5,Non-plant,2h@25C,,,,Yes,FD38542658,SA00930879,G1,7.62,385,2933.7,29.48,1.83,0.46,18.6,27600,2.9,Extraction.Femto.9764-9765,Pass,,,05/05/2022,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,34.4,45.4,1561.76,136.6,1.83,1.41,49.2,53.2,11169,6.6,Sheared.Femto.9764-6843,,Pass,,,ihElaGris1,0.931,ihElaGris1,SE293343N,PASS"

  def create_entities!
    build
  end

  # remove the first row from the csv
  # return string of csv, not including groups
  def csv_string_without_groups
    csv_data.split("\n")[1..].join("\n")
  end

  # this returns a list of objects
  # where each object is a csv row
  # where the key is the header, and the value is the cell
  # returns: all data e.g.
  def csv_data_to_json
    header_converter = proc do |header|
      assay_type = QcAssayType.find_by(label: header.strip)
      assay_type ? assay_type.key : header
    end

    csv = CSV.new(csv_string_without_groups, headers: true, header_converters: header_converter,
                                             converters: :all)

    csv.to_a.map(&:to_hash)
  end

  def build
    csv_data_to_json.each do |row_object|
      # 1. Always create Long Read qc_decision
      lr_status = row_object[LR_DECISION_FIELD]
      lr_qc_decison_id = create_qc_decision!(lr_status, :long_read).id

      # 1. Create TOL qc_decision, if required
      if row_object[TOL_DECISION_FIELD]
        tol_status = row_object[TOL_DECISION_FIELD]
        tol_qc_decison_id = create_qc_decision!(tol_status, :tol).id
      end

      # 3. Get relevant QcAssayTypes for used_by
      qc_assay_types = QcAssayType.where(used_by:)

      # 4. Loop through QcAssayTypes, to create qc_results
      qc_result_ids = []
      qc_assay_types.each do |qc_assay_type|
        labware_barcode = row_object['Tissue Tube ID']
        sample_external_id = row_object['Sanger sample ID']
        qc_assay_type_id = qc_assay_type.id
        value = row_object[qc_assay_type.key]

        qc_result = create_qc_result!(labware_barcode, sample_external_id, qc_assay_type_id, value)
        qc_result_ids << qc_result.id
      end

      # 5. Create create_qc_decision_results

      # Always insert qc_decision_result for long read
      qc_result_ids.each do |qc_result_id|
        create_qc_decision_result!(qc_result_id, lr_qc_decison_id)
      end

      next unless tol_qc_decison_id

      qc_result_ids.each do |qc_result_id|
        create_qc_decision_result!(qc_result_id, tol_qc_decison_id)
      end
    end
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
end
