RSpec.shared_examples "container" do
  let(:factory) { described_class.to_s.downcase.to_sym}

  it 'delegates material call to container_material join object' do
    container = create(factory)
    container_material = create(:container_material, container: container)
    expect(container_material.material).to be_present
    expect(container.material).to eq(container_material.material)
  end

  it "produces nil for delegates material if it doesn't exist" do
    container = create(factory, container_material: nil)
    expect(container.material).to be_nil
  end
end
