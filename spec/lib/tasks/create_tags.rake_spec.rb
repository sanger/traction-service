# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# only load Rake tasks if they haven't been loaded already
Rails.application.load_tasks if Rake::Task.tasks.empty?

RSpec.describe 'RakeTasks' do
  describe 'create tags' do
    it 'creates all of the pacbio tag sets' do
      expect { Rake::Task['tags:create:pacbio_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating Sequel_16_barcodes_v3 tag set and tags
          -> Tag Set successfully created
          -> Sequel_16_barcodes_v3 tags successfully created
          -> Creating Sequel_48_Microbial_Barcoded_OHA_v1tag set and tags
          -> Tag Set successfully created
          -> Sequel_48_Microbial_Barcoded_OHA_v1 tags successfully created
          -> Creating TruSeq_CD_i7_i5_D0x_8mer tag set and tags
          -> Tag Set successfully created
          -> TruSeq_CD_i7_i5_D0x_8mer tags successfully created
          -> Creating Sequel_96_Barcoded_OHA_v1 tag set and tags
          -> Tag Set successfully created
          -> Sequel_96_Barcoded_OHA_v1 tags successfully created
          -> Creating Pacbio IsoSeq tag set and tags
          -> Tag Set successfully created
          -> IsoSeq_Primers_12_Barcodes_v1 created
          -> Creating Nextera UD tag set and tags
          -> Tag Set successfully created
          -> Nextera_UD_Index_PlateA tags successfully created
          -> Creating Pacbio_96_barcode_plate_v3 tag set and tags
          -> Tag Set successfully created
          -> Pacbio_96_barcode_plate_v3 tags successfully created
          -> Creating MAS_SMRTbell_barcoded_adapters_(v2) tag set and tags
          -> Tag Set successfully created
          -> MAS_SMRTbell_barcoded_adapters_(v2) tags successfully created
          -> Creating PiMmS_TruSeq_adapters_v1 tag set and tags
          -> Tag Set successfully created
          -> PiMmS_TruSeq_adapters_v1 tags successfully created
        HEREDOC
      ).to_stdout
      expect(TagSet.count).to eq(9)
    end

    it 'creates all of the ont tag sets' do
      expect { Rake::Task['tags:create:ont_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating SQK-NBD114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-NBD114.96 tags successfully created
          -> Creating SQK-RBK114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-RBK114.96 tags successfully created
          -> Creating SQK-PCB114.24 tag set and tags
          -> Tag Set successfully created
          -> SQK-PCB114.24 tags successfully created
        HEREDOC
      ).to_stdout
      expect(TagSet.count).to eq(3)
    end

    it 'creates all of the tag sets' do
      # We need to reenable all tag tasks because they have all already been invoked by this point
      Rake.application.in_namespace(:tags) { |namespace| namespace.tasks.each(&:reenable) }
      expect { Rake::Task['tags:create:traction_all'].invoke }.to output(
        <<~HEREDOC
          -> Creating Sequel_16_barcodes_v3 tag set and tags
          -> Tag Set successfully created
          -> Sequel_16_barcodes_v3 tags successfully created
          -> Creating Sequel_48_Microbial_Barcoded_OHA_v1tag set and tags
          -> Tag Set successfully created
          -> Sequel_48_Microbial_Barcoded_OHA_v1 tags successfully created
          -> Creating TruSeq_CD_i7_i5_D0x_8mer tag set and tags
          -> Tag Set successfully created
          -> TruSeq_CD_i7_i5_D0x_8mer tags successfully created
          -> Creating Sequel_96_Barcoded_OHA_v1 tag set and tags
          -> Tag Set successfully created
          -> Sequel_96_Barcoded_OHA_v1 tags successfully created
          -> Creating Pacbio IsoSeq tag set and tags
          -> Tag Set successfully created
          -> IsoSeq_Primers_12_Barcodes_v1 created
          -> Creating Nextera UD tag set and tags
          -> Tag Set successfully created
          -> Nextera_UD_Index_PlateA tags successfully created
          -> Creating Pacbio_96_barcode_plate_v3 tag set and tags
          -> Tag Set successfully created
          -> Pacbio_96_barcode_plate_v3 tags successfully created
          -> Creating MAS_SMRTbell_barcoded_adapters_(v2) tag set and tags
          -> Tag Set successfully created
          -> MAS_SMRTbell_barcoded_adapters_(v2) tags successfully created
          -> Creating PiMmS_TruSeq_adapters_v1 tag set and tags
          -> Tag Set successfully created
          -> PiMmS_TruSeq_adapters_v1 tags successfully created
          -> Creating SQK-NBD114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-NBD114.96 tags successfully created
          -> Creating SQK-RBK114.96 tag set and tags
          -> Tag Set successfully created
          -> SQK-RBK114.96 tags successfully created
          -> Creating SQK-PCB114.24 tag set and tags
          -> Tag Set successfully created
          -> SQK-PCB114.24 tags successfully created
        HEREDOC
      ).to_stdout
      expect(TagSet.count).to eq(12)
    end
  end
end
