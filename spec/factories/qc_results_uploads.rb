# frozen_string_literal: true

FactoryBot.define do
  csv_data = ",,SAMPLE INFORMATION,,,,,,,,,,,,,VOUCHERING,,,,EXTRACTION/QC,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,COLUMN JUST FOR TOL,COLUMN JUST FOR TOL,SE LIMS,
    Batch ,Tissue Tube ID,Sanger sample ID,Species,Genome Size,Tissue FluidX rack ID,Rack well location,Date,Crush Method,Tissue Mass (mg),Tissue type,Lysis ,DNA tube ID,DNAext FluidX Rack ID,Rack position,Voucher?,Voucher Tube ID,Voucher Rack ID,Sample Location,Qubit DNA Quant (ng/ul) [ESP1],DNA vol (ul),DNA total ng [ESP1],Femto dilution [ESP1],ND 260/280 [ESP1],ND 260/230 [ESP1],ND Quant (ng/ul) [ESP1],Femto Frag Size [ESP1],GQN >30000 [ESP1],Femto pdf [ESP1],LR EXTRACTION DECISION [ESP1],Sample Well Position in Plate,TOL DECISION [ESP1],DNA Fluid+ MR kit for viscous DNA?,MR Machine ID,MR speed,Vol Input DNA MR3 (uL),Save 1uL post shear,Vol Input SPRI (uL),SPRI volume (x0.6),Qubit Quant (ng/ul) [ESP2],Final Elution Volume (ul),Total DNA ng [ESP2],Femto Dil (ul) [ESP2],ND 260/280 [ESP2],ND 260/230 [ESP2],ND Quant (ng/uL) [ESP2],% DNA Recovery,Femto Fragment size [ESP2],GQN 10kb threshold [ESP2],Femto pdf [ESP2],LR SHEARING DECISION [ESP2],TOL DECISION [ESP2],ToL ID ,Genome size (TOL),SE Number,Date in PB Lab (Auto)
    Production 1,FD20709764,DTOL12932860,,0.53,,,04/05/2022,Powermash,7.8,Non-plant,2h@25C,,,NA,Yes,FD38542652,SA00930879,A1,4.78,385,1840.3,18.12,2.38,0.57,14.9,22688,1.5,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,22.6,45.4,1026.04,89.4,1.92,1.79,33.7,55.8,9772,4.4,Sheared.Femto.9764-6843,Pass,,idCheUrba1,0.52725,SE293337P,24/06/2022
    Production 5,FR25746472,DTOL12900728,,0.29,,,23/05/2022,Powermash,0.01,Non-plant,2h@25C,FD32230132,fk00223822,B3,Yes,FD38542560,SA00930879,E6,1.11,385,427.35,4.44,2.7,-1.72,0.863,22234,1.6,2022 05 24 09H 50M,Failed Profile,,PASS,,Ed Sheeran,,350,FALSE,350,,3.66,40,146.4,13.64,1.71,0.89,4.065,34.3,7650,5.5,2022 10 06 16H 24M,Fail,,qcSchNemo1,0.2934,,
    Production 1,FS05287128,DTOL12932865,,0.38,,,04/05/2022,Powermash,8.7,Non-plant,2h@25C,,,,Yes,FD38542654,SA00930879,C1,7.58,385,2918.3,29.32,1.47,0.4,10,26330,2.9,Extraction.Femto.9764-9765,Pass,,,,Alan Shearer/Britney Shears,30,,FALSE,,,38.6,45.4,1752.44,153.4,1.91,1.88,47.5,60.1,14620,7.6,Sheared.Femto.9764-6843,Pass,,iyPanBank1,0.375,SE293345P,24/06/2022
    Production 11,FF10125466,DTOL12955871,,0.77,,,05/07/2022,Cryoprep,30.5,Plant,1h@55C,,,,Yes,FD38542364,SA01034044,B7,0.324,380,123.12,0.296,1.02,0.15,1.133,45219,4.4,2022 07 05 18H 34M,On Hold ULI,,Proceed to ULI,,Gtube,,,FALSE,355,1100,1.47,45,66.15,,,,,53.7,12776,7.9,2022 10 18 22H 48M,Pass,Proceed to ULI,drRobPseu1,0.77262,SE305610F,07/01/2022
    Production 16,FS05302585,DTOL13024292,,0.39,,,26/07/2022,Powermash,0.5,Non-plant,2h@25C,,,,Yes,FD38542482,Rack 3,,0.736,380,279.68,1.944,5.43,0.47,1.227,64788,5.7,2022 07 26 19H 54M,On Hold ULI,,Proceed to ULI,,Gtube,,,FALSE,350,1085,3.38,45,152.1,,,,,54.4,11747,7.8,2022 10 18 22H 48M,Pass,Proceed to ULI,icOulObsc1,0.3912,SE305613I,07/01/2022
    Production 16,FD21232251,DTOL13024293,,3.25,,,26/07/2022,Powermash,0.1,Non-plant,2h@25C,,,,Yes,FD38542483,Rack 3,,0.466,380,177.08,0.864,-1.57,-2.82,0.6023,49679,5.4,2022 07 26 19H 54M,On Hold ULI,,Proceed to ULI,,Gtube,,,FALSE,350,1085,2.48,45,111.6,,,,,63.0,12463,8.1,2022 10 18 22H 48M,Pass,Proceed to ULI,icPacLeth1,3.24696,SE305614J,07/01/2022
    Production 17,FS41960432,DTOL13024294,,1.85,,,25/07/2022,Cryoprep,71.8,Plant,1h@55C,FD32230264,fk00223822,D11,Yes,FD3852455,SA01034046,G11,0.648,380,246.24,1.592,1.41,2.71,1.41,35803,2.8,2022 07 25 15H 57M,Fail,,Fail,,Gtube,4500,,FALSE,,,1.896,46,87.216,6.584,,,,35.4,9666,,2022 11 09 13H 12M,Pass,Proceed to ULI,dcSuaMari1,1.84842,SE306609Q,11/11/2022
    Production 17,FS41960467,DTOL13024296,,1.11,,,25/07/2022,Cryoprep,74.4,Plant,1h@55C,FD32230265,fk00223822,D12,Yes,FD3852457,SA01034046,H1,1.64,380,623.2,5.56,1.76,1.26,1.76,36616,2.5,2022 07 25 15H 57M,Pass,,Proceed to shear and spri,,Ed Sheeran,30,355,FALSE,325,195,7.46,45,335.7,28.84,1.58,0.96,11.76,53.9,17817,8.2,2022 10 20 12H 06M,On Hold ULI,,ddAndPoli5,1.11492,,"

  factory :qc_results_upload, class: 'QcResultsUpload' do
    csv_data { csv_data }
    used_by { 'extraction' }
  end

  factory :qc_results_upload_factory do
    qc_results_upload
  end
end
