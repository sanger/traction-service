RSpec.shared_examples "uuidable" do
  it 'has a uuid after creation' do
    uuidable = create(uuidable_model)
    expect(uuidable.uuid).to be_present
  end
end
