# frozen_string_literal: true

FactoryBot.define do
  csv_data = ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,#REF!,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,,SEQUENCING DATA,
  Batch,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul),DNA vol (ul),DNA total ng,Femto dilution,ND 260/280,ND 260/230,ND Quant (ng/ul),Femto Frag Size,GQN >30000,Femto pdf [post-extraction],LR EXTRACTION DECISION,Sample Well Position in Plate,TOL DECISION [Post-Extraction],Operator,Pre-shear SPRI Vol input (uL),SPRI Volume (x0.6),Final Elution (uL),DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul),Final Elution Volume (ul),Total DNA ng,Femto Dil (ul),ND 260/280,ND 260/230,ND Quant (ng/uL),% DNA Recovery,Femto Fragment size (post-shear),GQN 10kb threshold,Femto pdf [post-shear],LMW Peak PS,Comments,Date Complete,TOL DECISION [Post-Shearing],ToL ID,ToL ID,PB comments/yields,Traction ID
  Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,Pass,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,,low fragment size,,,idCheUrba1,idCheUrba1,,
  Production 1,FD20706871,DTOL12932868,,0.48,,,04/05/2022,Powermash,21,Non-plant,2h@25C,,,,Yes,FD38542653,SA00930879,B1,3.1,385,1193.5,11.4,1.79,0.33,7.4,44697,3.9,Extraction.Femto.9764-9765,Pass,,Proceed to ULI,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.8,45.4,717.32,62.2,1.85,1.25,26,60.1,14833,8.9,Sheared.Femto.9764-6843,,,,,ilNemSwae1,ilNemSwae1,,
  Production 1,FS05287128,DTOL12932865,,0.38,,,04/05/2022,Powermash,8.7,Non-plant,2h@25C,,,,Yes,FD38542654,SA00930879,C1,7.58,385,2918.3,29.32,1.47,0.4,10,26330,2.9,Extraction.Femto.9764-9765,Pass,,Proceed to ULI,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,38.6,45.4,1752.44,153.4,1.91,1.88,47.5,60.1,14620,7.6,Sheared.Femto.9764-6843,,,,,iyPanBank1,iyPanBank1,SE293339R,
  Production 1,FS05287158,DTOL12932866,,0.4,,,04/05/2022,Powermash,13.7,Non-plant,2h@25C,,,,Yes,FD38542655,SA00930879,D1,3.5,385,1347.5,13,1.64,0.3,7.7,20800,1.7,Extraction.Femto.9764-9765,Pass,,Proceed to ULI,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,15.7,45.4,712.78,61.8,1.82,1.12,27.6,52.9,12178,6.3,Sheared.Femto.9764-6843,,,,,icLagHirt1,icLagHirt1,SE293340K,
  Production 1,FD20709486,DTOL12932858,,0.68,,,04/05/2022,Powermash,11.6,Non-plant,2h@25C,,,,Yes,FD38542656,SA00930879,E1,2.62,385,1008.7,9.48,1.29,0.3,7.2,29810,2.7,Extraction.Femto.9764-9765,Pass,,,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,13.7,45.4,621.98,53.8,1.82,1.07,26.5,61.7,14620,7.3,Sheared.Femto.9764-6843,,,,,ihLegLimb1,ihLegLimb1,SE293341L,
  Production 1,FD20709416,DTOL12932857,,0.45,,,04/05/2022,Powermash,8.2,Non-plant,2h@25C,,,,Yes,FD38542657,SA00930879,F1,8.52,385,3280.2,33.08,1.74,0.54,16.8,35639,3.3,Extraction.Femto.9764-9765,Fail,,Pass,lk11,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,40,45.4,1816,159,1.8,1.37,60.1,55.4,14567,7.5,Sheared.Femto.9764-6843,,,,,ilNycReva1,ilNycReva1,SE293342M,
  Production 1,FD20706843,DTOL12932856,,0.93,,,04/05/2022,Powermash,12.5,Non-plant,2h@25C,,,,Yes,FD38542658,SA00930879,G1,7.62,385,2933.7,29.48,1.83,0.46,18.6,27600,2.9,Extraction.Femto.9764-9765,Pass,,,fs17,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,34.4,45.4,1561.76,136.6,1.83,1.41,49.2,53.2,11169,6.6,Sheared.Femto.9764-6843,,,,,ihElaGris1,ihElaGris1,SE293343N,
  Production 1,FD20706829,DTOL12932855,,0.89,,,04/05/2022,Powermash,9.4,Non-plant,2h@25C,,,,Yes,FD38542659,SA00930879,G2,11.6,385,4466,45.4,1.65,0.53,12.8,30265,2.8,Extraction.Femto.9764-9765,Fail,,Pass,fs17,,,,,Alan Shearer/Britney Shears,30,,FALSE,,,63.4,45.4,2878.36,252.6,1.84,2,69.2,64.5,13876,6.6,Sheared.Femto.6829-8574,,,,,idPolDomi1,idPolDomi1,SE293344O"

  factory :qc_results_upload, class: 'QcResultsUpload' do
    csv_data { csv_data }
    used_by { 'extraction' }
  end

  factory :qc_results_upload_factory do
    qc_results_upload
  end
end
