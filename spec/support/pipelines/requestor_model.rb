require "rails_helper"

shared_examples_for 'requestor model' do
  
  let(:model)   { described_class.to_s.split('::').join('_').downcase }

  modual = described_class.to_s.deconstantize.constantize

  it 'will have a sample name' do
    expect(create(model).sample_name).to be_present
  end

  modual.request_attributes.each do |attribute|
    it "is not valid without #{attribute.to_s.gsub('_', ' ')}" do
      factory = build(model)
      factory.send("#{attribute}=", nil)
      expect(factory).to_not be_valid
    end
  end
 
end