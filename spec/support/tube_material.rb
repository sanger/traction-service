shared_examples "tube_material" do
  it { is_expected.to have_one(:tube) }
end
