# frozen_string_literal: true

require 'securerandom'

namespace :tags do
  desc 'Create tags and tag sets'
  namespace :create do
    desc 'Create all tags'
    task traction_all: :environment do
      Rake::Task['tags:create:pacbio_all'].invoke
      Rake::Task['tags:create:ont_all'].invoke
    end

    desc 'Create all pacbio tags'
    task pacbio_all: :environment do
      Rake::Task['tags:create:pacbio_sequel'].invoke
      Rake::Task['tags:create:pacbio_sequel_bacterial'].invoke
      Rake::Task['tags:create:pacbio_truseq'].invoke
      Rake::Task['tags:create:pacbio_sequel_96'].invoke
      Rake::Task['tags:create:pacbio_isoseq'].invoke
      Rake::Task['tags:create:nextera_ud'].invoke
      Rake::Task['tags:create:pacbio_96_barcode_plate_v3'].invoke
      Rake::Task['tags:create:mas_smrtbell_barcoded_adapters_(v2)'].invoke
      Rake::Task['tags:create:PiMmS_TruSeq_adapters_v1'].invoke
    end

    desc 'Create all ont tags'
    task ont_all: :environment do
      Rake::Task['tags:create:SQK-NBD114.96'].invoke
      Rake::Task['tags:create:SQK-RBK114.96'].invoke
      Rake::Task['tags:create:SQK-PCB114.24'].invoke
    end

    desc 'Create pacbio sequel tags'
    task pacbio_sequel: :environment do
      puts '-> Creating Sequel_16_barcodes_v3 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Sequel_16_barcodes_v3', uuid: '244d96c6-f3b2-4997-5ae3-23ed33ab925f')
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

    desc 'Create 96 barcode plate tags'
    task pacbio_96_barcode_plate_v3: :environment do
      puts '-> Creating Pacbio_96_barcode_plate_v3 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'Pacbio_96_barcode_plate_v3', uuid: '7a7f33e6-4912-4505-0d1e-3ceef7c93695')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'ATCGTGCGACGAGTAT', group_id: 'bc2001' },
        { oligo: 'TGCATGTCATGAGTAT', group_id: 'bc2002' },
        { oligo: 'ACGAGTGCTCGAGTAT', group_id: 'bc2003' },
        { oligo: 'TGCAGTGCTCGAGTAT', group_id: 'bc2004' },
        { oligo: 'TGACTCGATCGAGTAT', group_id: 'bc2005' },
        { oligo: 'CATGCGATCTGAGTAT', group_id: 'bc2006' },
        { oligo: 'ACTAGCATCTGAGTAT', group_id: 'bc2007' },
        { oligo: 'ACGCTAGTCTGAGTAT', group_id: 'bc2008' },
        { oligo: 'CGATCGCACTGAGTAT', group_id: 'bc2009' },
        { oligo: 'TACGTAGTATGAGTAT', group_id: 'bc2010' },
        { oligo: 'CTGACAGTACGAGTAT', group_id: 'bc2011' },
        { oligo: 'TCGTACTACTGAGTAT', group_id: 'bc2012' },
        { oligo: 'CTGCGTAGACGAGTAT', group_id: 'bc2013' },
        { oligo: 'ATACATGCACGAGTAT', group_id: 'bc2014' },
        { oligo: 'CGACATAGATGAGTAT', group_id: 'bc2015' },
        { oligo: 'ATCTGCACGTGAGTAT', group_id: 'bc2016' },
        { oligo: 'CTATGATAGCGAGTAT', group_id: 'bc2017' },
        { oligo: 'CGATCAGTGCGAGTAT', group_id: 'bc2018' },
        { oligo: 'CGTCATAGTCGAGTAT', group_id: 'bc2019' },
        { oligo: 'ACTATGCGTCGAGTAT', group_id: 'bc2020' },
        { oligo: 'CGTACATGCTGAGTAT', group_id: 'bc2021' },
        { oligo: 'TCATCGACGTGAGTAT', group_id: 'bc2022' },
        { oligo: 'TCGCATGACTGAGTAT', group_id: 'bc2023' },
        { oligo: 'CATGATCGACGAGTAT', group_id: 'bc2024' },
        { oligo: 'ACGCACGTACGAGTAT', group_id: 'bc2025' },
        { oligo: 'CAGTAGCGTCGAGTAT', group_id: 'bc2026' },
        { oligo: 'TGACTGTAGCGAGTAT', group_id: 'bc2027' },
        { oligo: 'ACTGCAGCACGAGTAT', group_id: 'bc2028' },
        { oligo: 'TAGCAGTATCGAGTAT', group_id: 'bc2029' },
        { oligo: 'CATACAGCATGAGTAT', group_id: 'bc2030' },
        { oligo: 'ATAGCGTACTGAGTAT', group_id: 'bc2031' },
        { oligo: 'ATAGACGAGTGAGTAT', group_id: 'bc2032' },
        { oligo: 'CGACTCGTATGAGTAT', group_id: 'bc2033' },
        { oligo: 'TACTAGTGACGAGTAT', group_id: 'bc2034' },
        { oligo: 'CAGCTGACATGAGTAT', group_id: 'bc2035' },
        { oligo: 'ACGTCGCTGCGAGTAT', group_id: 'bc2036' },
        { oligo: 'CAGTATGAGCGAGTAT', group_id: 'bc2037' },
        { oligo: 'TCACGACGACGAGTAT', group_id: 'bc2038' },
        { oligo: 'CATGTATGTCGAGTAT', group_id: 'bc2039' },
        { oligo: 'TGCTGCGACTGAGTAT', group_id: 'bc2040' },
        { oligo: 'TATGATCACTGAGTAT', group_id: 'bc2041' },
        { oligo: 'TCTGCACTGCGAGTAT', group_id: 'bc2042' },
        { oligo: 'ACGATGACGTGAGTAT', group_id: 'bc2043' },
        { oligo: 'CGATGATGCTGAGTAT', group_id: 'bc2044' },
        { oligo: 'TACGACAGTCGAGTAT', group_id: 'bc2045' },
        { oligo: 'ATAGCATGTCGAGTAT', group_id: 'bc2046' },
        { oligo: 'CATAGTACTCGAGTAT', group_id: 'bc2047' },
        { oligo: 'TGATGCTAGTGAGTAT', group_id: 'bc2048' },
        { oligo: 'TAGTCTGCGTGAGTAT', group_id: 'bc2049' },
        { oligo: 'CTCATCTATCGAGTAT', group_id: 'bc2050' },
        { oligo: 'TGCATACTGCGAGTAT', group_id: 'bc2051' },
        { oligo: 'CAGACTAGTCGAGTAT', group_id: 'bc2052' },
        { oligo: 'ATCGTGATCTGAGTAT', group_id: 'bc2053' },
        { oligo: 'CTGCGATCACGAGTAT', group_id: 'bc2054' },
        { oligo: 'CTCAGCATACGAGTAT', group_id: 'bc2055' },
        { oligo: 'TCGCAGCGTCGAGTAT', group_id: 'bc2056' },
        { oligo: 'TAGCACGCATGAGTAT', group_id: 'bc2057' },
        { oligo: 'TACTGACGCTGAGTAT', group_id: 'bc2058' },
        { oligo: 'ATCTGACTATGAGTAT', group_id: 'bc2059' },
        { oligo: 'ATACGAGCTCGAGTAT', group_id: 'bc2060' },
        { oligo: 'CGAGCACGCTGAGTAT', group_id: 'bc2061' },
        { oligo: 'TCTGCGTATCGAGTAT', group_id: 'bc2062' },
        { oligo: 'TCTGCATCATGAGTAT', group_id: 'bc2063' },
        { oligo: 'TGCGTGATGCGAGTAT', group_id: 'bc2064' },
        { oligo: 'TGAGCTATGCGAGTAT', group_id: 'bc2065' },
        { oligo: 'CTGTCGTAGTGAGTAT', group_id: 'bc2066' },
        { oligo: 'ATCGATGCATGAGTAT', group_id: 'bc2067' },
        { oligo: 'ACTACGTGATGAGTAT', group_id: 'bc2068' },
        { oligo: 'TCTATGACATGAGTAT', group_id: 'bc2069' },
        { oligo: 'TACTGCTCACGAGTAT', group_id: 'bc2070' },
        { oligo: 'CGAGTCTAGCGAGTAT', group_id: 'bc2071' },
        { oligo: 'TATCAGTAGTGAGTAT', group_id: 'bc2072' },
        { oligo: 'ATCACTAGTCGAGTAT', group_id: 'bc2073' },
        { oligo: 'TATCACGACTGAGTAT', group_id: 'bc2074' },
        { oligo: 'CTCGTCAGATGAGTAT', group_id: 'bc2075' },
        { oligo: 'CAGCAGTGACGAGTAT', group_id: 'bc2076' },
        { oligo: 'TGCGACGTGCGAGTAT', group_id: 'bc2077' },
        { oligo: 'CTCACTGAGTGAGTAT', group_id: 'bc2078' },
        { oligo: 'CACTGAGCGTGAGTAT', group_id: 'bc2079' },
        { oligo: 'CAGCGTCTACGAGTAT', group_id: 'bc2080' },
        { oligo: 'CTACTATGTCGAGTAT', group_id: 'bc2081' },
        { oligo: 'ATGTACAGACGAGTAT', group_id: 'bc2082' },
        { oligo: 'ACTCATCAGTGAGTAT', group_id: 'bc2083' },
        { oligo: 'CTGAGCACTCGAGTAT', group_id: 'bc2084' },
        { oligo: 'ATCATCTACTGAGTAT', group_id: 'bc2085' },
        { oligo: 'TACATGCGATGAGTAT', group_id: 'bc2086' },
        { oligo: 'TCGCTGTCACGAGTAT', group_id: 'bc2087' },
        { oligo: 'ACGCTCATGCGAGTAT', group_id: 'bc2088' },
        { oligo: 'TACTAGCAGCGAGTAT', group_id: 'bc2089' },
        { oligo: 'CGTAGCAGATGAGTAT', group_id: 'bc2090' },
        { oligo: 'CGTGCTCGTCGAGTAT', group_id: 'bc2091' },
        { oligo: 'ACAGCTGTACGAGTAT', group_id: 'bc2092' },
        { oligo: 'TCGATGCTACGAGTAT', group_id: 'bc2093' },
        { oligo: 'TAGATACAGCGAGTAT', group_id: 'bc2094' },
        { oligo: 'CTACTCATACGAGTAT', group_id: 'bc2095' },
        { oligo: 'ATGTACTAGTGAGTAT', group_id: 'bc2096' }
      ]
        .each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> Pacbio_96_barcode_plate_v3 tags successfully created'
    end

    desc 'Create MAS SMRTBell barcoded tags'
    task 'mas_smrtbell_barcoded_adapters_(v2)': :environment do
      puts '-> Creating MAS_SMRTbell_barcoded_adapters_(v2) tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'MAS_SMRTbell_barcoded_adapters_(v2)', uuid: 'd5109545-7f84-97b7-6ab6-ce2ca778e1f5')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'ACAGTC', group_id: 'bcM0001' },
        { oligo: 'ATGACG', group_id: 'bcM0002' },
        { oligo: 'CACGTG', group_id: 'bcM0003' },
        { oligo: 'CATCGC', group_id: 'bcM0004' }
      ]
        .each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> MAS_SMRTbell_barcoded_adapters_(v2) tags successfully created'
    end

    desc 'Create PiMmS_TruSeq_adapters_v1 tags'
    task PiMmS_TruSeq_adapters_v1: :environment do
      puts '-> Creating PiMmS_TruSeq_adapters_v1 tag set and tags'
      set = TagSet.pacbio_pipeline
                  .find_or_create_by!(name: 'PiMmS_TruSeq_adapters_v1', uuid: '985d7948-4608-3729-d897-48127ff86df6')
      puts '-> Tag Set successfully created'
      [
        { oligo: 'AGCGCTAG', group_id: 'D501' },
        { oligo: 'GATATCGA', group_id: 'D502' },
        { oligo: 'CGCAGACG', group_id: 'D503' },
        { oligo: 'TATGAGTA', group_id: 'D504' },
        { oligo: 'AGGTGCGT', group_id: 'D505' },
        { oligo: 'GAACATAC', group_id: 'D506' },
        { oligo: 'ACATAGCG', group_id: 'D507' },
        { oligo: 'GTGCGATA', group_id: 'D508' },
        { oligo: 'CCAACAGA', group_id: 'D509' },
        { oligo: 'TTGGTGAG', group_id: 'D510' },
        { oligo: 'CGCGGTTC', group_id: 'D511' },
        { oligo: 'TATAACCT', group_id: 'D512' },
        { oligo: 'CCGCGGTT', group_id: 'D701' },
        { oligo: 'TTATAACC', group_id: 'D702' },
        { oligo: 'GGACTTGG', group_id: 'D703' },
        { oligo: 'AAGTCCAA', group_id: 'D704' },
        { oligo: 'ATCCACTG', group_id: 'D705' },
        { oligo: 'GCTTGTCA', group_id: 'D706' },
        { oligo: 'CAAGCTAG', group_id: 'D707' },
        { oligo: 'TGGATCGA', group_id: 'D708' },
        { oligo: 'AGTTCAGG', group_id: 'D709' },
        { oligo: 'GACCTGAA', group_id: 'D710' },
        { oligo: 'TCTCTACT', group_id: 'D711' },
        { oligo: 'CTCTCGTC', group_id: 'D712' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> PiMmS_TruSeq_adapters_v1 tags successfully created'
    end

    desc 'Create SQK-NBD114.96 tags'
    task 'SQK-NBD114.96': :environment do
      puts '-> Creating SQK-NBD114.96 tag set and tags'
      set = TagSet.ont_pipeline
                  .find_or_create_by!(name: 'SQK-NBD114.96')
      puts '-> Tag Set successfully created'
      [
        { group_id: 'NB01', oligo: 'CACAAAGACACCGACAACTTTCTT' },
        { group_id: 'NB02', oligo: 'ACAGACGACTACAAACGGAATCGA' },
        { group_id: 'NB03', oligo: 'CCTGGTAACTGGGACACAAGACTC' },
        { group_id: 'NB04', oligo: 'TAGGGAAACACGATAGAATCCGAA' },
        { group_id: 'NB05', oligo: 'AAGGTTACACAAACCCTGGACAAG' },
        { group_id: 'NB06', oligo: 'GACTACTTTCTGCCTTTGCGAGAA' },
        { group_id: 'NB07', oligo: 'AAGGATTCATTCCCACGGTAACAC' },
        { group_id: 'NB08', oligo: 'ACGTAACTTGGTTTGTTCCCTGAA' },
        { group_id: 'NB09', oligo: 'AACCAAGACTCGCTGTGCCTAGTT' },
        { group_id: 'NB10', oligo: 'GAGAGGACAAAGGTTTCAACGCTT' },
        { group_id: 'NB11', oligo: 'TCCATTCCCTCCGATAGATGAAAC' },
        { group_id: 'NB12', oligo: 'TCCGATTCTGCTTCTTTCTACCTG' },
        { group_id: 'NB13', oligo: 'AGAACGACTTCCATACTCGTGTGA' },
        { group_id: 'NB14', oligo: 'AACGAGTCTCTTGGGACCCATAGA' },
        { group_id: 'NB15', oligo: 'AGGTCTACCTCGCTAACACCACTG' },
        { group_id: 'NB16', oligo: 'CGTCAACTGACAGTGGTTCGTACT' },
        { group_id: 'NB17', oligo: 'ACCCTCCAGGAAAGTACCTCTGAT' },
        { group_id: 'NB18', oligo: 'CCAAACCCAACAACCTAGATAGGC' },
        { group_id: 'NB19', oligo: 'GTTCCTCGTGCAGTGTCAAGAGAT' },
        { group_id: 'NB20', oligo: 'TTGCGTCCTGTTACGAGAACTCAT' },
        { group_id: 'NB21', oligo: 'GAGCCTCTCATTGTCCGTTCTCTA' },
        { group_id: 'NB22', oligo: 'ACCACTGCCATGTATCAAAGTACG' },
        { group_id: 'NB23', oligo: 'CTTACTACCCAGTGAACCTCCTCG' },
        { group_id: 'NB24', oligo: 'GCATAGTTCTGCATGATGGGTTAG' },
        { group_id: 'NB25', oligo: 'GTAAGTTGGGTATGCAACGCAATG' },
        { group_id: 'NB26', oligo: 'CATACAGCGACTACGCATTCTCAT' },
        { group_id: 'NB27', oligo: 'CGACGGTTAGATTCACCTCTTACA' },
        { group_id: 'NB28', oligo: 'TGAAACCTAAGAAGGCACCGTATC' },
        { group_id: 'NB29', oligo: 'CTAGACACCTTGGGTTGACAGACC' },
        { group_id: 'NB30', oligo: 'TCAGTGAGGATCTACTTCGACCCA' },
        { group_id: 'NB31', oligo: 'TGCGTACAGCAATCAGTTACATTG' },
        { group_id: 'NB32', oligo: 'CCAGTAGAAGTCCGACAACGTCAT' },
        { group_id: 'NB33', oligo: 'CAGACTTGGTACGGTTGGGTAACT' },
        { group_id: 'NB34', oligo: 'GGACGAAGAACTCAAGTCAAAGGC' },
        { group_id: 'NB35', oligo: 'CTACTTACGAAGCTGAGGGACTGC' },
        { group_id: 'NB36', oligo: 'ATGTCCCAGTTAGAGGAGGAAACA' },
        { group_id: 'NB37', oligo: 'GCTTGCGATTGATGCTTAGTATCA' },
        { group_id: 'NB38', oligo: 'ACCACAGGAGGACGATACAGAGAA' },
        { group_id: 'NB39', oligo: 'CCACAGTGTCAACTAGAGCCTCTC' },
        { group_id: 'NB40', oligo: 'TAGTTTGGATGACCAAGGATAGCC' },
        { group_id: 'NB41', oligo: 'GGAGTTCGTCCAGAGAAGTACACG' },
        { group_id: 'NB42', oligo: 'CTACGTGTAAGGCATACCTGCCAG' },
        { group_id: 'NB43', oligo: 'CTTTCGTTGTTGACTCGACGGTAG' },
        { group_id: 'NB44', oligo: 'AGTAGAAAGGGTTCCTTCCCACTC' },
        { group_id: 'NB45', oligo: 'GATCCAACAGAGATGCCTTCAGTG' },
        { group_id: 'NB46', oligo: 'GCTGTGTTCCACTTCATTCTCCTG' },
        { group_id: 'NB47', oligo: 'GTGCAACTTTCCCACAGGTAGTTC' },
        { group_id: 'NB48', oligo: 'CATCTGGAACGTGGTACACCTGTA' },
        { group_id: 'NB49', oligo: 'ACTGGTGCAGCTTTGAACATCTAG' },
        { group_id: 'NB50', oligo: 'ATGGACTTTGGTAACTTCCTGCGT' },
        { group_id: 'NB51', oligo: 'GTTGAATGAGCCTACTGGGTCCTC' },
        { group_id: 'NB52', oligo: 'TGAGAGACAAGATTGTTCGTGGAC' },
        { group_id: 'NB53', oligo: 'AGATTCAGACCGTCTCATGCAAAG' },
        { group_id: 'NB54', oligo: 'CAAGAGCTTTGACTAAGGAGCATG' },
        { group_id: 'NB55', oligo: 'TGGAAGATGAGACCCTGATCTACG' },
        { group_id: 'NB56', oligo: 'TCACTACTCAACAGGTGGCATGAA' },
        { group_id: 'NB57', oligo: 'GCTAGGTCAATCTCCTTCGGAAGT' },
        { group_id: 'NB58', oligo: 'CAGGTTACTCCTCCGTGAGTCTGA' },
        { group_id: 'NB59', oligo: 'TCAATCAAGAAGGGAAAGCAAGGT' },
        { group_id: 'NB60', oligo: 'CATGTTCAACCAAGGCTTCTATGG' },
        { group_id: 'NB61', oligo: 'AGAGGGTACTATGTGCCTCAGCAC' },
        { group_id: 'NB62', oligo: 'CACCCACACTTACTTCAGGACGTA' },
        { group_id: 'NB63', oligo: 'TTCTGAAGTTCCTGGGTCTTGAAC' },
        { group_id: 'NB64', oligo: 'GACAGACACCGTTCATCGACTTTC' },
        { group_id: 'NB65', oligo: 'TTCTCAGTCTTCCTCCAGACAAGG' },
        { group_id: 'NB66', oligo: 'CCGATCCTTGTGGCTTCTAACTTC' },
        { group_id: 'NB67', oligo: 'GTTTGTCATACTCGTGTGCTCACC' },
        { group_id: 'NB68', oligo: 'GAATCTAAGCAAACACGAAGGTGG' },
        { group_id: 'NB69', oligo: 'TACAGTCCGAGCCTCATGTGATCT' },
        { group_id: 'NB70', oligo: 'ACCGAGATCCTACGAATGGAGTGT' },
        { group_id: 'NB71', oligo: 'CCTGGGAGCATCAGGTAGTAACAG' },
        { group_id: 'NB72', oligo: 'TAGCTGACTGTCTTCCATACCGAC' },
        { group_id: 'NB73', oligo: 'AAGAAACAGGATGACAGAACCCTC' },
        { group_id: 'NB74', oligo: 'TACAAGCATCCCAACACTTCCACT' },
        { group_id: 'NB75', oligo: 'GACCATTGTGATGAACCCTGTTGT' },
        { group_id: 'NB76', oligo: 'ATGCTTGTTACATCAACCCTGGAC' },
        { group_id: 'NB77', oligo: 'CGACCTGTTTCTCAGGGATACAAC' },
        { group_id: 'NB78', oligo: 'AACAACCGAACCTTTGAATCAGAA' },
        { group_id: 'NB79', oligo: 'TCTCGGAGATAGTTCTCACTGCTG' },
        { group_id: 'NB80', oligo: 'CGGATGAACATAGGATAGCGATTC' },
        { group_id: 'NB81', oligo: 'CCTCATCTTGTGAAGTTGTTTCGG' },
        { group_id: 'NB82', oligo: 'ACGGTATGTCGAGTTCCAGGACTA' },
        { group_id: 'NB83', oligo: 'TGGCTTGATCTAGGTAAGGTCGAA' },
        { group_id: 'NB84', oligo: 'GTAGTGGACCTAGAACCTGTGCCA' },
        { group_id: 'NB85', oligo: 'AACGGAGGAGTTAGTTGGATGATC' },
        { group_id: 'NB86', oligo: 'AGGTGATCCCAACAAGCGTAAGTA' },
        { group_id: 'NB87', oligo: 'TACATGCTCCTGTTGTTAGGGAGG' },
        { group_id: 'NB88', oligo: 'TCTTCTACTACCGATCCGAAGCAG' },
        { group_id: 'NB89', oligo: 'ACAGCATCAATGTTTGGCTAGTTG' },
        { group_id: 'NB90', oligo: 'GATGTAGAGGGTACGGTTTGAGGC' },
        { group_id: 'NB91', oligo: 'GGCTCCATAGGAACTCACGCTACT' },
        { group_id: 'NB92', oligo: 'TTGTGAGTGGAAAGATACAGGACC' },
        { group_id: 'NB93', oligo: 'AGTTTCCATCACTTCAGACTTGGG' },
        { group_id: 'NB94', oligo: 'GATTGTCCTCAAACTGCCACCTAC' },
        { group_id: 'NB95', oligo: 'CCTGTCTGGAAGAAGAATGGACTT' },
        { group_id: 'NB96', oligo: 'CTGAACGGTCATAGAGTCCACCAT' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> SQK-NBD114.96 tags successfully created'
    end

    desc 'Create SQK-RBK114.96 tags'
    task 'SQK-RBK114.96': :environment do
      puts '-> Creating SQK-RBK114.96 tag set and tags'
      set = TagSet.ont_pipeline
                  .find_or_create_by!(name: 'SQK-RBK114.96')
      puts '-> Tag Set successfully created'
      [
        { group_id: 'RB01', oligo: 'AAGAAAGTTGTCGGTGTCTTTGTG' },
        { group_id: 'RB02', oligo: 'TCGATTCCGTTTGTAGTCGTCTGT' },
        { group_id: 'RB03', oligo: 'GAGTCTTGTGTCCCAGTTACCAGG' },
        { group_id: 'RB04', oligo: 'TTCGGATTCTATCGTGTTTCCCTA' },
        { group_id: 'RB05', oligo: 'CTTGTCCAGGGTTTGTGTAACCTT' },
        { group_id: 'RB06', oligo: 'TTCTCGCAAAGGCAGAAAGTAGTC' },
        { group_id: 'RB07', oligo: 'GTGTTACCGTGGGAATGAATCCTT' },
        { group_id: 'RB08', oligo: 'TTCAGGGAACAAACCAAGTTACGT' },
        { group_id: 'RB09', oligo: 'AACTAGGCACAGCGAGTCTTGGTT' },
        { group_id: 'RB10', oligo: 'AAGCGTTGAAACCTTTGTCCTCTC' },
        { group_id: 'RB11', oligo: 'GTTTCATCTATCGGAGGGAATGGA' },
        { group_id: 'RB12', oligo: 'CAGGTAGAAAGAAGCAGAATCGGA' },
        { group_id: 'RB13', oligo: 'AGAACGACTTCCATACTCGTGTGA' },
        { group_id: 'RB14', oligo: 'AACGAGTCTCTTGGGACCCATAGA' },
        { group_id: 'RB15', oligo: 'AGGTCTACCTCGCTAACACCACTG' },
        { group_id: 'RB16', oligo: 'CGTCAACTGACAGTGGTTCGTACT' },
        { group_id: 'RB17', oligo: 'ACCCTCCAGGAAAGTACCTCTGAT' },
        { group_id: 'RB18', oligo: 'CCAAACCCAACAACCTAGATAGGC' },
        { group_id: 'RB19', oligo: 'GTTCCTCGTGCAGTGTCAAGAGAT' },
        { group_id: 'RB20', oligo: 'TTGCGTCCTGTTACGAGAACTCAT' },
        { group_id: 'RB21', oligo: 'GAGCCTCTCATTGTCCGTTCTCTA' },
        { group_id: 'RB22', oligo: 'ACCACTGCCATGTATCAAAGTACG' },
        { group_id: 'RB23', oligo: 'CTTACTACCCAGTGAACCTCCTCG' },
        { group_id: 'RB24', oligo: 'GCATAGTTCTGCATGATGGGTTAG' },
        { group_id: 'RB25', oligo: 'GTAAGTTGGGTATGCAACGCAATG' },
        { group_id: 'RB26', oligo: 'CATACAGCGACTACGCATTCTCAT' },
        { group_id: 'RB27', oligo: 'CGACGGTTAGATTCACCTCTTACA' },
        { group_id: 'RB28', oligo: 'TGAAACCTAAGAAGGCACCGTATC' },
        { group_id: 'RB29', oligo: 'CTAGACACCTTGGGTTGACAGACC' },
        { group_id: 'RB30', oligo: 'TCAGTGAGGATCTACTTCGACCCA' },
        { group_id: 'RB31', oligo: 'TGCGTACAGCAATCAGTTACATTG' },
        { group_id: 'RB32', oligo: 'CCAGTAGAAGTCCGACAACGTCAT' },
        { group_id: 'RB33', oligo: 'CAGACTTGGTACGGTTGGGTAACT' },
        { group_id: 'RB34', oligo: 'GGACGAAGAACTCAAGTCAAAGGC' },
        { group_id: 'RB35', oligo: 'CTACTTACGAAGCTGAGGGACTGC' },
        { group_id: 'RB36', oligo: 'ATGTCCCAGTTAGAGGAGGAAACA' },
        { group_id: 'RB37', oligo: 'GCTTGCGATTGATGCTTAGTATCA' },
        { group_id: 'RB38', oligo: 'ACCACAGGAGGACGATACAGAGAA' },
        { group_id: 'RB39', oligo: 'CCACAGTGTCAACTAGAGCCTCTC' },
        { group_id: 'RB40', oligo: 'TAGTTTGGATGACCAAGGATAGCC' },
        { group_id: 'RB41', oligo: 'GGAGTTCGTCCAGAGAAGTACACG' },
        { group_id: 'RB42', oligo: 'CTACGTGTAAGGCATACCTGCCAG' },
        { group_id: 'RB43', oligo: 'CTTTCGTTGTTGACTCGACGGTAG' },
        { group_id: 'RB44', oligo: 'AGTAGAAAGGGTTCCTTCCCACTC' },
        { group_id: 'RB45', oligo: 'GATCCAACAGAGATGCCTTCAGTG' },
        { group_id: 'RB46', oligo: 'GCTGTGTTCCACTTCATTCTCCTG' },
        { group_id: 'RB47', oligo: 'GTGCAACTTTCCCACAGGTAGTTC' },
        { group_id: 'RB48', oligo: 'CATCTGGAACGTGGTACACCTGTA' },
        { group_id: 'RB49', oligo: 'ACTGGTGCAGCTTTGAACATCTAG' },
        { group_id: 'RB50', oligo: 'ATGGACTTTGGTAACTTCCTGCGT' },
        { group_id: 'RB51', oligo: 'GTTGAATGAGCCTACTGGGTCCTC' },
        { group_id: 'RB52', oligo: 'TGAGAGACAAGATTGTTCGTGGAC' },
        { group_id: 'RB53', oligo: 'AGATTCAGACCGTCTCATGCAAAG' },
        { group_id: 'RB54', oligo: 'CAAGAGCTTTGACTAAGGAGCATG' },
        { group_id: 'RB55', oligo: 'TGGAAGATGAGACCCTGATCTACG' },
        { group_id: 'RB56', oligo: 'TCACTACTCAACAGGTGGCATGAA' },
        { group_id: 'RB57', oligo: 'GCTAGGTCAATCTCCTTCGGAAGT' },
        { group_id: 'RB58', oligo: 'CAGGTTACTCCTCCGTGAGTCTGA' },
        { group_id: 'RB59', oligo: 'TCAATCAAGAAGGGAAAGCAAGGT' },
        { group_id: 'RB60', oligo: 'CATGTTCAACCAAGGCTTCTATGG' },
        { group_id: 'RB61', oligo: 'AGAGGGTACTATGTGCCTCAGCAC' },
        { group_id: 'RB62', oligo: 'CACCCACACTTACTTCAGGACGTA' },
        { group_id: 'RB63', oligo: 'TTCTGAAGTTCCTGGGTCTTGAAC' },
        { group_id: 'RB64', oligo: 'GACAGACACCGTTCATCGACTTTC' },
        { group_id: 'RB65', oligo: 'TTCTCAGTCTTCCTCCAGACAAGG' },
        { group_id: 'RB66', oligo: 'CCGATCCTTGTGGCTTCTAACTTC' },
        { group_id: 'RB67', oligo: 'GTTTGTCATACTCGTGTGCTCACC' },
        { group_id: 'RB68', oligo: 'GAATCTAAGCAAACACGAAGGTGG' },
        { group_id: 'RB69', oligo: 'TACAGTCCGAGCCTCATGTGATCT' },
        { group_id: 'RB70', oligo: 'ACCGAGATCCTACGAATGGAGTGT' },
        { group_id: 'RB71', oligo: 'CCTGGGAGCATCAGGTAGTAACAG' },
        { group_id: 'RB72', oligo: 'TAGCTGACTGTCTTCCATACCGAC' },
        { group_id: 'RB73', oligo: 'AAGAAACAGGATGACAGAACCCTC' },
        { group_id: 'RB74', oligo: 'TACAAGCATCCCAACACTTCCACT' },
        { group_id: 'RB75', oligo: 'GACCATTGTGATGAACCCTGTTGT' },
        { group_id: 'RB76', oligo: 'ATGCTTGTTACATCAACCCTGGAC' },
        { group_id: 'RB77', oligo: 'CGACCTGTTTCTCAGGGATACAAC' },
        { group_id: 'RB78', oligo: 'AACAACCGAACCTTTGAATCAGAA' },
        { group_id: 'RB79', oligo: 'TCTCGGAGATAGTTCTCACTGCTG' },
        { group_id: 'RB80', oligo: 'CGGATGAACATAGGATAGCGATTC' },
        { group_id: 'RB81', oligo: 'CCTCATCTTGTGAAGTTGTTTCGG' },
        { group_id: 'RB82', oligo: 'ACGGTATGTCGAGTTCCAGGACTA' },
        { group_id: 'RB83', oligo: 'TGGCTTGATCTAGGTAAGGTCGAA' },
        { group_id: 'RB84', oligo: 'GTAGTGGACCTAGAACCTGTGCCA' },
        { group_id: 'RB85', oligo: 'AACGGAGGAGTTAGTTGGATGATC' },
        { group_id: 'RB86', oligo: 'AGGTGATCCCAACAAGCGTAAGTA' },
        { group_id: 'RB87', oligo: 'TACATGCTCCTGTTGTTAGGGAGG' },
        { group_id: 'RB88', oligo: 'TCTTCTACTACCGATCCGAAGCAG' },
        { group_id: 'RB89', oligo: 'ACAGCATCAATGTTTGGCTAGTTG' },
        { group_id: 'RB90', oligo: 'GATGTAGAGGGTACGGTTTGAGGC' },
        { group_id: 'RB91', oligo: 'GGCTCCATAGGAACTCACGCTACT' },
        { group_id: 'RB92', oligo: 'TTGTGAGTGGAAAGATACAGGACC' },
        { group_id: 'RB93', oligo: 'AGTTTCCATCACTTCAGACTTGGG' },
        { group_id: 'RB94', oligo: 'GATTGTCCTCAAACTGCCACCTAC' },
        { group_id: 'RB95', oligo: 'CCTGTCTGGAAGAAGAATGGACTT' },
        { group_id: 'RB96', oligo: 'CTGAACGGTCATAGAGTCCACCAT' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> SQK-RBK114.96 tags successfully created'
    end

    task 'SQK-PCB114.24': :environment do
      puts '-> Creating SQK-PCB114.24 tag set and tags'
      set = TagSet.ont_pipeline
                  .find_or_create_by!(name: 'SQK-PCB114.24')
      puts '-> Tag Set successfully created'
      [
        { group_id: 'BP01', oligo: 'AAGAAAGTTGTCGGTGTCTTTGTG' },
        { group_id: 'BP02', oligo: 'TCGATTCCGTTTGTAGTCGTCTGT' },
        { group_id: 'BP03', oligo: 'GAGTCTTGTGTCCCAGTTACCAGG' },
        { group_id: 'BP04', oligo: 'TTCGGATTCTATCGTGTTTCCCTA' },
        { group_id: 'BP05', oligo: 'CTTGTCCAGGGTTTGTGTAACCTT' },
        { group_id: 'BP06', oligo: 'TTCTCGCAAAGGCAGAAAGTAGTC' },
        { group_id: 'BP07', oligo: 'GTGTTACCGTGGGAATGAATCCTT' },
        { group_id: 'BP08', oligo: 'TTCAGGGAACAAACCAAGTTACGT' },
        { group_id: 'BP09', oligo: 'AACTAGGCACAGCGAGTCTTGGTT' },
        { group_id: 'BP10', oligo: 'AAGCGTTGAAACCTTTGTCCTCTC' },
        { group_id: 'BP11', oligo: 'GTTTCATCTATCGGAGGGAATGGA' },
        { group_id: 'BP12', oligo: 'CAGGTAGAAAGAAGCAGAATCGGA' },
        { group_id: 'BP13', oligo: 'AGAACGACTTCCATACTCGTGTGA' },
        { group_id: 'BP14', oligo: 'AACGAGTCTCTTGGGACCCATAGA' },
        { group_id: 'BP15', oligo: 'AGGTCTACCTCGCTAACACCACTG' },
        { group_id: 'BP16', oligo: 'CGTCAACTGACAGTGGTTCGTACT' },
        { group_id: 'BP17', oligo: 'ACCCTCCAGGAAAGTACCTCTGAT' },
        { group_id: 'BP18', oligo: 'CCAAACCCAACAACCTAGATAGGC' },
        { group_id: 'BP19', oligo: 'GTTCCTCGTGCAGTGTCAAGAGAT' },
        { group_id: 'BP20', oligo: 'TTGCGTCCTGTTACGAGAACTCAT' },
        { group_id: 'BP21', oligo: 'GAGCCTCTCATTGTCCGTTCTCTA' },
        { group_id: 'BP22', oligo: 'ACCACTGCCATGTATCAAAGTACG' },
        { group_id: 'BP23', oligo: 'CTTACTACCCAGTGAACCTCCTCG' },
        { group_id: 'BP24', oligo: 'GCATAGTTCTGCATGATGGGTTAG' }
      ].each do |tag_attributes|
        set.tags.find_or_create_by!(tag_attributes)
      end
      puts '-> SQK-PCB114.24 tags successfully created'
    end
  end

  task destroy: :environment do
    Tag.destroy_all
    puts '-> Tags successfully deleted'
    TagSet.destroy_all
    puts '-> Tag Sets successfully deleted'
  end
end
