FactoryBot.define do
  factory :pacbio_well_library, class: Pacbio::WellLibrary do
    well    { create(:pacbio_well) }
    library { create(:pacbio_library) }
  end
end