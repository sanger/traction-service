# frozen_string_literal: true

FactoryBot.define do
  # when normal
  # when batch non-production
  # when batch empty
  # when tissue tube a control
  # when tissue tube empty
  # when LR decision empty
  # when empty rows
  csv_data =
    <<-CSV
  ,,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,,
  Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date Started,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),SPRI Type,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2] ,LR SHEARING DECISION [ESP2],Date Complete,TOL DECISION [ESP2],ToL ID ,Genome size (TOL),Sent to TOL?,PB Lib Status
  Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,,idCheUrba1,0.52725,TRUE,PASS
  Non-Production,NT1773971E,DTOL_RD13185179,Hedera helix,1.56,#N/A,#N/A,,cryoprep,30,Plant,1h@55C,,,,No,,,,,,0,,,,,,,,,,,,,,,,,,,,0,-1,,,,#DIV/0!,,,,,,#N/A,drHedHeli1,1.5648,FALSE,
  ,FD20706871,DTOL12932868,,0.48,,,04/05/2022,Powermash,21,Non-plant,2h@25C,,,,Yes,FD38542653,SA00930879,B1 ,3.1,385,1193.5,11.4,1.79,0.33,7.4,44697,3.9,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,,,,15.8,45.4,717.32,62.2,1.85,1.25,26,60.1,14833,8.9,Sheared.Femto.9764-6843,Pass,,,ilNemSwae1,0.478,TRUE,PASS
  Production 8,Control (5mil),,,#N/A,,,21/06/2022,Powermash,NA,Cell Line,2h@25C,FD32230201,Rack 1,,No,N/A,,,4.6,380,1748,17.4,2,3.44,6.771,53866,5.4,2022 06 21 18H 51M,NA (control),,,,,,,,,,,,,,,,,0.0,,,,,,,,#N/A,TRUE,
  Production 1,,DTOL12932865,,0.38,,,04/05/2022,Powermash,8.7,Non-plant,2h@25C,,,,Yes,FD38542654,SA00930879,C1,7.58,385,2918.3,29.32,1.47,0.4,10,26330,2.9,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,,,,38.6,45.4,1752.44,153.4,1.91,1.88,47.5,60.1,14620,7.6,Sheared.Femto.9764-6843,Pass,,,iyPanBank1,0.375,TRUE,PASS
  Production 56,FS53626272,DTOL13262041,Chelon labrosus,0.77,FK00020279,D1,,Powermash,23.4,Non-Plant,2h@25C,,,,Yes,FD42926736,SA01064541 - Rack 12,F2,,,0,-1,,,,,,,,,,,,,,,,,,,0,,,,,#DIV/0!,,,,,,#N/A,fCheLab1,0.77262,FALSE,
  ,,,,,,,,,,,,,,,Yes,,,,,,0,-1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,FALSE,
    CSV

  factory :qc_results_upload, class: 'QcResultsUpload' do
    csv_data { csv_data }
    used_by { 'extraction' }
  end

  factory :qc_results_upload_factory do
    qc_results_upload
  end
end
