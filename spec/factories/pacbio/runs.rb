FactoryBot.define do
  factory :pacbio_run, class: Pacbio::Run do
    sequence(:binding_kit_box_barcode) { |n| "DM111710086220011171#{n}"}
    sequence(:sequencing_kit_box_barcode) { |n| "DM000110086180012312#{n}"}
    sequence(:dna_control_complex_box_barcode) { |n| "Lxxxxx10171760012319#{n}"}
    system_name { 'Sequel II' } 
    comments { 'A Run Comment'}
  end
end
