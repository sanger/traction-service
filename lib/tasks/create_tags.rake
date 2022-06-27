# frozen_string_literal: true

require 'securerandom'

namespace :tags do
  desc 'Create tags and tag sets'
  namespace :create do
    desc 'Create pacbio sequel tags'
    task pacbio_sequel: :environment do
      puts '-> Creating Sequel_16_barcodes_v3 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Sequel_16_barcodes_v3', uuid: '4d87a8ab-4d16-f0b0-77e5-0f467dba442e')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'CACATATCAGAGTGCGT', group_id: 'bc1001_BAK8A_OA' },
        { oligo: 'ACACACAGACTGTGAGT', group_id: 'bc1002_BAK8A_OA' },
        { oligo: 'ACACATCTCGTGAGAGT', group_id: 'bc1003_BAK8A_OA' },
        { oligo: 'ACAGTCGAGCGCTGCGT', group_id: 'bc1008_BAK8A_OA' },
        { oligo: 'ACACACGCGAGACAGAT', group_id: 'bc1009_BAK8A_OA' },
        { oligo: 'ACGCGCTATCTCAGAGT', group_id: 'bc1010_BAK8A_OA' },
        { oligo: 'CTATACGTATATCTATT', group_id: 'bc1011_BAK8A_OA' },
        { oligo: 'ACACTAGATCGCGTGTT', group_id: 'bc1012_BAK8A_OA' },
        { oligo: 'CGCATGACACGTGTGTT', group_id: 'bc1015_BAK8B_OA' },
        { oligo: 'CATAGAGAGATAGTATT', group_id: 'bc1016_BAK8B_OA' },
        { oligo: 'CACACGCGCGCTATATT', group_id: 'bc1017_BAK8B_OA' },
        { oligo: 'TCACGTGCTCACTGTGT', group_id: 'bc1018_BAK8B_OA' },
        { oligo: 'ACACACTCTATCAGATT', group_id: 'bc1019_BAK8B_OA' },
        { oligo: 'CACGACACGACGATGTT', group_id: 'bc1020_BAK8B_OA' },
        { oligo: 'CTATACATAGTGATGTT', group_id: 'bc1021_BAK8B_OA' },
        { oligo: 'CACTCACGTGTGATATT', group_id: 'bc1022_BAK8B_OA' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Sequel_16_barcodes_v3 tags successfully created'
    end

    desc 'Create pacbio bacterial multiplexing tags'
    task pacbio_sequel_bacterial: :environment do
      puts '-> Creating Sequel_48_Microbial_Barcoded_OHA_v1tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Sequel_48_Microbial_Barcoded_OHA_v1', uuid: 'c808dbb2-a26b-cfae-0a16-c3e7c3b8d7fe')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'TCTGTATCTCTATGTGT', group_id: 'bc1007T' },
        { oligo: 'CAGAGAGATATCTCTGT', group_id: 'bc1023T' },
        { oligo: 'CATGTAGAGCAGAGAGT', group_id: 'bc1024T' },
        { oligo: 'CACAGAGACACGCACAT', group_id: 'bc1026T' },
        { oligo: 'CTCACACTCTCTCACAT', group_id: 'bc1027T' },
        { oligo: 'CTCTGCTCTGACTCTCT', group_id: 'bc1028T' },
        { oligo: 'TATATATGTCTATAGAT', group_id: 'bc1029T' },
        { oligo: 'GATGTCTGAGTGTGTGT', group_id: 'bc1031T' },
        { oligo: 'TCTCGTCGCAGTCTCTT', group_id: 'bc1033T' },
        { oligo: 'ATGTGTATATAGATATT', group_id: 'bc1034T' },
        { oligo: 'GAGACACGTCGCACACT', group_id: 'bc1036T' },
        { oligo: 'ACACATATCGCACTACT', group_id: 'bc1037T' },
        { oligo: 'TGTCATATGAGAGTGTT', group_id: 'bc1040T' },
        { oligo: 'TATAGAGCTCTACATAT', group_id: 'bc1043T' },
        { oligo: 'GCTGAGACGACGCGCGT', group_id: 'bc1044T' },
        { oligo: 'GATATATCGAGTATATT', group_id: 'bc1046T' },
        { oligo: 'TGTCATGTGTACACACT', group_id: 'bc1047T' },
        { oligo: 'GATATACGCGAGAGAGT', group_id: 'bc1050T' },
        { oligo: 'GTGTGAGATATATATCT', group_id: 'bc1052T' },
        { oligo: 'CTCACGTACGTCACACT', group_id: 'bc1053T' },
        { oligo: 'GCGCACGCACTACAGAT', group_id: 'bc1054T' },
        { oligo: 'CACACGAGATCTCATCT', group_id: 'bc1055T' },
        { oligo: 'GACGAGCGTCTGAGAGT', group_id: 'bc1057T' },
        { oligo: 'TGTGTCTCTGAGAGTAT', group_id: 'bc1058T' },
        { oligo: 'CACACGCACTGAGATAT', group_id: 'bc1059T' },
        { oligo: 'GATGAGTATAGACACAT', group_id: 'bc1060T' },
        { oligo: 'GCTGTGTGTGCTCGTCT', group_id: 'bc1061T' },
        { oligo: 'TCTCAGATAGTCTATAT', group_id: 'bc1062T' },
        { oligo: 'TATATACAGAGTCGAGT', group_id: 'bc1064T' },
        { oligo: 'GCGCTCTCTCACATACT', group_id: 'bc1065T' },
        { oligo: 'TATATGCTCTGTGTGAT', group_id: 'bc1066T' },
        { oligo: 'CTCTATATATCTCGTCT', group_id: 'bc1067T' },
        { oligo: 'AGAGAGCTCTCTCATCT', group_id: 'bc1068T' },
        { oligo: 'TGCTCTCGTGTACTGTT', group_id: 'bc1070T' },
        { oligo: 'TGTACGCTCTCTATATT', group_id: 'bc1074T' },
        { oligo: 'GTGCACTCGCGCTCTCT', group_id: 'bc1076T' },
        { oligo: 'TATCTCTCGAGTCGCGT', group_id: 'bc1077T' },
        { oligo: 'CTCACACATACACGTCT', group_id: 'bc1078T' },
        { oligo: 'ATAGTACACTCTGTGTT', group_id: 'bc1079T' },
        { oligo: 'GATATATATGTGTGTAT', group_id: 'bc1081T' },
        { oligo: 'GTGACACACAGAGCACT', group_id: 'bc1082T' },
        { oligo: 'ATATGACATACACGCAT', group_id: 'bc1083T' },
        { oligo: 'CGTCTCTCGTCTGTGCT', group_id: 'bc1084T' },
        { oligo: 'CTATCTAGCACTCACAT', group_id: 'bc1087T' },
        { oligo: 'GTATATATATACGTCTT', group_id: 'bc1091T' },
        { oligo: 'TCTCACGAGAGCGCACT', group_id: 'bc1092T' },
        { oligo: 'ATAGCGACATCTCTCTT', group_id: 'bc1094T' },
        { oligo: 'GCACGATGTCAGCGCGT', group_id: 'bc1095T' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Sequel_48_Microbial_Barcoded_OHA_v1 tags successfully created'
    end

    desc 'Create pacbio truseq tags'
    task pacbio_truseq: :environment do
      puts '-> Creating TruSeq_CD_i7_i5_D0x_8mer tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'TruSeq_CD_i7_i5_D0x_8mer', uuid: 'aa4a2d17-0a82-aef0-ab21-29ecbe96ceaf')
      puts '-> Tag Set successfully created'
      [
        { group_id: 'D501', oligo: 'TATAGCCT' },
        { group_id: 'D502', oligo: 'ATAGAGGC' },
        { group_id: 'D503', oligo: 'CCTATCCT' },
        { group_id: 'D504', oligo: 'GGCTCTGA' },
        { group_id: 'D505', oligo: 'AGGCGAAG' },
        { group_id: 'D506', oligo: 'TAATCTTA' },
        { group_id: 'D507', oligo: 'CAGGACGT' },
        { group_id: 'D508', oligo: 'GTACTGAC' },
        { group_id: 'D701', oligo: 'ATTACTCG' },
        { group_id: 'D702', oligo: 'TCCGGAGA' },
        { group_id: 'D703', oligo: 'CGCTCATT' },
        { group_id: 'D704', oligo: 'GAGATTCC' },
        { group_id: 'D705', oligo: 'ATTCAGAA' },
        { group_id: 'D706', oligo: 'GAATTCGT' },
        { group_id: 'D707', oligo: 'CTGAAGCT' },
        { group_id: 'D708', oligo: 'TAATGCGC' },
        { group_id: 'D709', oligo: 'CGGCTATG' },
        { group_id: 'D710', oligo: 'TCCGCGAA' },
        { group_id: 'D711', oligo: 'TCTCGCGC' },
        { group_id: 'D712', oligo: 'AGCGATAG' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> TruSeq_CD_i7_i5_D0x_8mer tags successfully created'
    end

    desc 'Create pacbio sequel 96 tags'
    task pacbio_sequel_96: :environment do
      puts '-> Creating Sequel_96_Barcoded_OHA_v1 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Sequel_96_Barcoded_OHA_v1', uuid: '478ca5bc-df68-c86d-d8ee-ad11f590c0bd')
      puts '-> Tag Set successfully created'
      [
        { group_id: 'bc1001T', oligo: 'CACATATCAGAGTGCGT' },
        { group_id: 'bc1002T', oligo: 'ACACACAGACTGTGAGT' },
        { group_id: 'bc1003T', oligo: 'ACACATCTCGTGAGAGT' },
        { group_id: 'bc1004T', oligo: 'CACGCACACACGCGCGT' },
        { group_id: 'bc1006T', oligo: 'CATATATATCAGCTGTT' },
        { group_id: 'bc1007T', oligo: 'TCTGTATCTCTATGTGT' },
        { group_id: 'bc1008T', oligo: 'ACAGTCGAGCGCTGCGT' },
        { group_id: 'bc1009T', oligo: 'ACACACGCGAGACAGAT' },
        { group_id: 'bc1010T', oligo: 'ACGCGCTATCTCAGAGT' },
        { group_id: 'bc1011T', oligo: 'CTATACGTATATCTATT' },
        { group_id: 'bc1012T', oligo: 'ACACTAGATCGCGTGTT' },
        { group_id: 'bc1013T', oligo: 'CTCTCGCATACGCGAGT' },
        { group_id: 'bc1015T', oligo: 'CGCATGACACGTGTGTT' },
        { group_id: 'bc1016T', oligo: 'CATAGAGAGATAGTATT' },
        { group_id: 'bc1017T', oligo: 'CACACGCGCGCTATATT' },
        { group_id: 'bc1018T', oligo: 'TCACGTGCTCACTGTGT' },
        { group_id: 'bc1019T', oligo: 'ACACACTCTATCAGATT' },
        { group_id: 'bc1020T', oligo: 'CACGACACGACGATGTT' },
        { group_id: 'bc1021T', oligo: 'CTATACATAGTGATGTT' },
        { group_id: 'bc1022T', oligo: 'CACTCACGTGTGATATT' },
        { group_id: 'bc1023T', oligo: 'CAGAGAGATATCTCTGT' },
        { group_id: 'bc1024T', oligo: 'CATGTAGAGCAGAGAGT' },
        { group_id: 'bc1026T', oligo: 'CACAGAGACACGCACAT' },
        { group_id: 'bc1027T', oligo: 'CTCACACTCTCTCACAT' },
        { group_id: 'bc1028T', oligo: 'CTCTGCTCTGACTCTCT' },
        { group_id: 'bc1029T', oligo: 'TATATATGTCTATAGAT' },
        { group_id: 'bc1030T', oligo: 'TCTCTCTATCGCGCTCT' },
        { group_id: 'bc1031T', oligo: 'GATGTCTGAGTGTGTGT' },
        { group_id: 'bc1032T', oligo: 'GAGACTAGAGATAGTGT' },
        { group_id: 'bc1033T', oligo: 'TCTCGTCGCAGTCTCTT' },
        { group_id: 'bc1034T', oligo: 'ATGTGTATATAGATATT' },
        { group_id: 'bc1035T', oligo: 'GCGCGCGCACTCTCTGT' },
        { group_id: 'bc1036T', oligo: 'GAGACACGTCGCACACT' },
        { group_id: 'bc1037T', oligo: 'ACACATATCGCACTACT' },
        { group_id: 'bc1039T', oligo: 'CGCACACATAGATACAT' },
        { group_id: 'bc1040T', oligo: 'TGTCATATGAGAGTGTT' },
        { group_id: 'bc1043T', oligo: 'TATAGAGCTCTACATAT' },
        { group_id: 'bc1044T', oligo: 'GCTGAGACGACGCGCGT' },
        { group_id: 'bc1045T', oligo: 'ACATATCGTACTCTCTT' },
        { group_id: 'bc1046T', oligo: 'GATATATCGAGTATATT' },
        { group_id: 'bc1047T', oligo: 'TGTCATGTGTACACACT' },
        { group_id: 'bc1048T', oligo: 'GTGTGCACTCACACTCT' },
        { group_id: 'bc1049T', oligo: 'ACACGTGTGCTCTCTCT' },
        { group_id: 'bc1050T', oligo: 'GATATACGCGAGAGAGT' },
        { group_id: 'bc1052T', oligo: 'GTGTGAGATATATATCT' },
        { group_id: 'bc1053T', oligo: 'CTCACGTACGTCACACT' },
        { group_id: 'bc1054T', oligo: 'GCGCACGCACTACAGAT' },
        { group_id: 'bc1055T', oligo: 'CACACGAGATCTCATCT' },
        { group_id: 'bc1056T', oligo: 'AGACACACACGCACATT' },
        { group_id: 'bc1057T', oligo: 'GACGAGCGTCTGAGAGT' },
        { group_id: 'bc1058T', oligo: 'TGTGTCTCTGAGAGTAT' },
        { group_id: 'bc1059T', oligo: 'CACACGCACTGAGATAT' },
        { group_id: 'bc1060T', oligo: 'GATGAGTATAGACACAT' },
        { group_id: 'bc1061T', oligo: 'GCTGTGTGTGCTCGTCT' },
        { group_id: 'bc1062T', oligo: 'TCTCAGATAGTCTATAT' },
        { group_id: 'bc1063T', oligo: 'ACACGCATGACACACTT' },
        { group_id: 'bc1064T', oligo: 'TATATACAGAGTCGAGT' },
        { group_id: 'bc1065T', oligo: 'GCGCTCTCTCACATACT' },
        { group_id: 'bc1066T', oligo: 'TATATGCTCTGTGTGAT' },
        { group_id: 'bc1067T', oligo: 'CTCTATATATCTCGTCT' },
        { group_id: 'bc1068T', oligo: 'AGAGAGCTCTCTCATCT' },
        { group_id: 'bc1069T', oligo: 'GCGAGAGTGAGACGCAT' },
        { group_id: 'bc1070T', oligo: 'TGCTCTCGTGTACTGTT' },
        { group_id: 'bc1071T', oligo: 'AGCGCTGCGACACGCGT' },
        { group_id: 'bc1072T', oligo: 'AGACGCGAGCGCGTAGT' },
        { group_id: 'bc1073T', oligo: 'GCGTGTGTCGAGTGTAT' },
        { group_id: 'bc1074T', oligo: 'TGTACGCTCTCTATATT' },
        { group_id: 'bc1075T', oligo: 'TAGAGAGCGTCGCGTGT' },
        { group_id: 'bc1076T', oligo: 'GTGCACTCGCGCTCTCT' },
        { group_id: 'bc1077T', oligo: 'TATCTCTCGAGTCGCGT' },
        { group_id: 'bc1078T', oligo: 'CTCACACATACACGTCT' },
        { group_id: 'bc1079T', oligo: 'ATAGTACACTCTGTGTT' },
        { group_id: 'bc1080T', oligo: 'TATCTCTGTAGAGTCTT' },
        { group_id: 'bc1081T', oligo: 'GATATATATGTGTGTAT' },
        { group_id: 'bc1082T', oligo: 'GTGACACACAGAGCACT' },
        { group_id: 'bc1083T', oligo: 'ATATGACATACACGCAT' },
        { group_id: 'bc1084T', oligo: 'CGTCTCTCGTCTGTGCT' },
        { group_id: 'bc1085T', oligo: 'ACACAGTAGAGCGAGCT' },
        { group_id: 'bc1087T', oligo: 'CTATCTAGCACTCACAT' },
        { group_id: 'bc1088T', oligo: 'CGTGTCACTCTGCGTGT' },
        { group_id: 'bc1091T', oligo: 'GTATATATATACGTCTT' },
        { group_id: 'bc1092T', oligo: 'TCTCACGAGAGCGCACT' },
        { group_id: 'bc1093T', oligo: 'TAGATGCGAGAGTAGAT' },
        { group_id: 'bc1094T', oligo: 'ATAGCGACATCTCTCTT' },
        { group_id: 'bc1095T', oligo: 'GCACGATGTCAGCGCGT' },
        { group_id: 'bc1096T', oligo: 'TGTGCTCTCTACACAGT' },
        { group_id: 'bc1099T', oligo: 'TCTACTACACTGTACTT' },
        { group_id: 'bc1101T', oligo: 'ATAGCGACGCGATATAT' },
        { group_id: 'bc1102T', oligo: 'TCTCTCGATATGATAGT' },
        { group_id: 'bc1106T', oligo: 'CACGACTATATGCTCTT' },
        { group_id: 'bc1109T', oligo: 'CTGTGTGTGATAGAGTT' },
        { group_id: 'bc1111T', oligo: 'TGAGATATGCATGATGT' },
        { group_id: 'bc1117T', oligo: 'GTGCATACATACATATT' },
        { group_id: 'bc1118T', oligo: 'AGATACACATGATACTT' },
        { group_id: 'bc1119T', oligo: 'TCACATATGTATACATT' },
        { group_id: 'bc1126T', oligo: 'GTGTATCAGCGAGTATT' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Sequel_96_Barcoded_OHA_v1 tags successfully created'
    end

    desc 'Create pacbio IsoSeq tags'
    task pacbio_isoseq: :environment do
      puts '-> Creating Pacbio IsoSeq tag set and tags'
      set = TagSet.pacbio_pipeline
                  .create_with(sample_sheet_behaviour: :hidden)
                  .find_or_create_by!(name: 'IsoSeq_Primers_12_Barcodes_v1', uuid: 'd1bb7419-4343-286f-f6f7-7365fa2d1ee9')

      set.update!(sample_sheet_behaviour: :hidden) unless set.hidden_sample_sheet_behaviour?

      puts '-> Tag Set successfully created'
      [
        { oligo: 'CACATATCAGAGTGCG', group_id: 'bc1001' },
        { oligo: 'ACACACAGACTGTGAG', group_id: 'bc1002' },
        { oligo: 'ACACATCTCGTGAGAG', group_id: 'bc1003' },
        { oligo: 'CACGCACACACGCGCG', group_id: 'bc1004' },
        { oligo: 'CACTCGACTCTCGCGT', group_id: 'bc1005' },
        { oligo: 'CATATATATCAGCTGT', group_id: 'bc1006' },
        { oligo: 'ACAGTCGAGCGCTGCG', group_id: 'bc1008' },
        { oligo: 'ACACTAGATCGCGTGT', group_id: 'bc1012' },
        { oligo: 'TCACGTGCTCACTGTG', group_id: 'bc1018' },
        { oligo: 'ACACACTCTATCAGAT', group_id: 'bc1019' },
        { oligo: 'CACGACACGACGATGT', group_id: 'bc1020' },
        { oligo: 'CAGAGAGATATCTCTG', group_id: 'bc1023' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> IsoSeq_Primers_12_Barcodes_v1 created'
    end

    desc 'Create Nextera UD tags'
    task nextera_ud: :environment do
      puts '-> Creating Nextera UD tag set and tags'
      set = TagSet.pacbio_pipeline
                  .create_with(sample_sheet_behaviour: :hidden)
                  .find_or_create_by!(name: 'Nextera_UD_Index_PlateA', uuid: 'dd87fafe-1432-157f-fd16-b1a8bae9e6a4')

      set.update!(sample_sheet_behaviour: :hidden) unless set.hidden_sample_sheet_behaviour?

      puts '-> Tag Set successfully created'
      [
        { group_id: 'UDP0001_i7', oligo: 'CGCTCAGTTC' },
        { group_id: 'UDP0002_i7', oligo: 'TATCTGACCT' },
        { group_id: 'UDP0003_i7', oligo: 'ATATGAGACG' },
        { group_id: 'UDP0004_i7', oligo: 'CTTATGGAAT' },
        { group_id: 'UDP0005_i7', oligo: 'TAATCTCGTC' },
        { group_id: 'UDP0006_i7', oligo: 'GCGCGATGTT' },
        { group_id: 'UDP0007_i7', oligo: 'AGAGCACTAG' },
        { group_id: 'UDP0008_i7', oligo: 'TGCCTTGATC' },
        { group_id: 'UDP0009_i7', oligo: 'CTACTCAGTC' },
        { group_id: 'UDP0010_i7', oligo: 'TCGTCTGACT' },
        { group_id: 'UDP0011_i7', oligo: 'GAACATACGG' },
        { group_id: 'UDP0012_i7', oligo: 'CCTATGACTC' },
        { group_id: 'UDP0013_i7', oligo: 'TAATGGCAAG' },
        { group_id: 'UDP0014_i7', oligo: 'GTGCCGCTTC' },
        { group_id: 'UDP0015_i7', oligo: 'CGGCAATGGA' },
        { group_id: 'UDP0016_i7', oligo: 'GCCGTAACCG' },
        { group_id: 'UDP0017_i7', oligo: 'AACCATTCTC' },
        { group_id: 'UDP0018_i7', oligo: 'GGTTGCCTCT' },
        { group_id: 'UDP0019_i7', oligo: 'CTAATGATGG' },
        { group_id: 'UDP0020_i7', oligo: 'TCGGCCTATC' },
        { group_id: 'UDP0021_i7', oligo: 'AGTCAACCAT' },
        { group_id: 'UDP0022_i7', oligo: 'GAGCGCAATA' },
        { group_id: 'UDP0023_i7', oligo: 'AACAAGGCGT' },
        { group_id: 'UDP0024_i7', oligo: 'GTATGTAGAA' },
        { group_id: 'UDP0025_i7', oligo: 'TTCTATGGTT' },
        { group_id: 'UDP0026_i7', oligo: 'CCTCGCAACC' },
        { group_id: 'UDP0027_i7', oligo: 'TGGATGCTTA' },
        { group_id: 'UDP0028_i7', oligo: 'ATGTCGTGGT' },
        { group_id: 'UDP0029_i7', oligo: 'AGAGTGCGGC' },
        { group_id: 'UDP0030_i7', oligo: 'TGCCTGGTGG' },
        { group_id: 'UDP0031_i7', oligo: 'TGCGTGTCAC' },
        { group_id: 'UDP0032_i7', oligo: 'CATACACTGT' },
        { group_id: 'UDP0033_i7', oligo: 'CGTATAATCA' },
        { group_id: 'UDP0034_i7', oligo: 'TACGCGGCTG' },
        { group_id: 'UDP0035_i7', oligo: 'GCGAGTTACC' },
        { group_id: 'UDP0036_i7', oligo: 'TACGGCCGGT' },
        { group_id: 'UDP0037_i7', oligo: 'GTCGATTACA' },
        { group_id: 'UDP0038_i7', oligo: 'CTGTCTGCAC' },
        { group_id: 'UDP0039_i7', oligo: 'CAGCCGATTG' },
        { group_id: 'UDP0040_i7', oligo: 'TGACTACATA' },
        { group_id: 'UDP0041_i7', oligo: 'ATTGCCGAGT' },
        { group_id: 'UDP0042_i7', oligo: 'GCCATTAGAC' },
        { group_id: 'UDP0043_i7', oligo: 'GGCGAGATGG' },
        { group_id: 'UDP0044_i7', oligo: 'TGGCTCGCAG' },
        { group_id: 'UDP0045_i7', oligo: 'TAGAATAACG' },
        { group_id: 'UDP0046_i7', oligo: 'TAATGGATCT' },
        { group_id: 'UDP0047_i7', oligo: 'TATCCAGGAC' },
        { group_id: 'UDP0048_i7', oligo: 'AGTGCCACTG' },
        { group_id: 'UDP0049_i7', oligo: 'GTGCAACACT' },
        { group_id: 'UDP0050_i7', oligo: 'ACATGGTGTC' },
        { group_id: 'UDP0051_i7', oligo: 'GACAGACAGG' },
        { group_id: 'UDP0052_i7', oligo: 'TCTTACATCA' },
        { group_id: 'UDP0053_i7', oligo: 'TTACAATTCC' },
        { group_id: 'UDP0054_i7', oligo: 'AAGCTTATGC' },
        { group_id: 'UDP0055_i7', oligo: 'TATTCCTCAG' },
        { group_id: 'UDP0056_i7', oligo: 'CTCGTGCGTT' },
        { group_id: 'UDP0057_i7', oligo: 'TTAGGATAGA' },
        { group_id: 'UDP0058_i7', oligo: 'CCGAAGCGAG' },
        { group_id: 'UDP0059_i7', oligo: 'GGACCAACAG' },
        { group_id: 'UDP0060_i7', oligo: 'TTCCAGGTAA' },
        { group_id: 'UDP0061_i7', oligo: 'TGATTAGCCA' },
        { group_id: 'UDP0062_i7', oligo: 'TAACAGTGTT' },
        { group_id: 'UDP0063_i7', oligo: 'ACCGCGCAAT' },
        { group_id: 'UDP0064_i7', oligo: 'GTTCGCGCCA' },
        { group_id: 'UDP0065_i7', oligo: 'AGACACATTA' },
        { group_id: 'UDP0066_i7', oligo: 'GCGTTGGTAT' },
        { group_id: 'UDP0067_i7', oligo: 'AGCACATCCT' },
        { group_id: 'UDP0068_i7', oligo: 'TTGTTCCGTG' },
        { group_id: 'UDP0069_i7', oligo: 'AAGTACTCCA' },
        { group_id: 'UDP0070_i7', oligo: 'ACGTCAATAC' },
        { group_id: 'UDP0071_i7', oligo: 'GGTGTACAAG' },
        { group_id: 'UDP0072_i7', oligo: 'CCACCTGTGT' },
        { group_id: 'UDP0073_i7', oligo: 'GTTCCGCAGG' },
        { group_id: 'UDP0074_i7', oligo: 'ACCTTATGAA' },
        { group_id: 'UDP0075_i7', oligo: 'CGCTGCAGAG' },
        { group_id: 'UDP0076_i7', oligo: 'GTAGAGTCAG' },
        { group_id: 'UDP0077_i7', oligo: 'GGATACCAGA' },
        { group_id: 'UDP0078_i7', oligo: 'CGCACTAATG' },
        { group_id: 'UDP0079_i7', oligo: 'TCCTGACCGT' },
        { group_id: 'UDP0080_i7', oligo: 'CTGGCTTGCC' },
        { group_id: 'UDP0081_i7', oligo: 'ACCAGCGACA' },
        { group_id: 'UDP0082_i7', oligo: 'TTGTAACGGT' },
        { group_id: 'UDP0083_i7', oligo: 'GTAAGGCATA' },
        { group_id: 'UDP0084_i7', oligo: 'GTCCACTTGT' },
        { group_id: 'UDP0085_i7', oligo: 'TTAGGTACCA' },
        { group_id: 'UDP0086_i7', oligo: 'GGAATTCCAA' },
        { group_id: 'UDP0087_i7', oligo: 'CATGTAGAGG' },
        { group_id: 'UDP0088_i7', oligo: 'TACACGCTCC' },
        { group_id: 'UDP0089_i7', oligo: 'GCTTACGGAC' },
        { group_id: 'UDP0090_i7', oligo: 'CGCTTGAAGT' },
        { group_id: 'UDP0091_i7', oligo: 'CGCCTTCTGA' },
        { group_id: 'UDP0092_i7', oligo: 'ATACCAACGC' },
        { group_id: 'UDP0093_i7', oligo: 'CTGGATATGT' },
        { group_id: 'UDP0094_i7', oligo: 'CAATCTATGA' },
        { group_id: 'UDP0095_i7', oligo: 'GGTGGAATAC' },
        { group_id: 'UDP0096_i7', oligo: 'TGGACGGAGG' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Nextera_UD_Index_PlateA tags successfully created'
    end
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
