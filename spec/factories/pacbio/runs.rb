FactoryBot.define do
  factory :pacbio_run, class: Pacbio::Run do
    sequence(:name) { |n| "run#{n}"}
    template_prep_kit_box_barcode { 'DM1117100259100111716'}
    binding_kit_box_barcode { 'DM1117100862200111716'}
    sequencing_kit_box_barcode { 'DM0001100861800123120'}
    dna_control_complex_box_barcode { 'Lxxxxx101717600123199'}
  end
end