require "rails_helper"

shared_examples_for 'requestor factory' do

  let(:request_model)   { described_class.request_model.to_s.split('::').join('_').downcase }

  context '#initialize' do
    it 'creates an object for each given request' do
      factory = described_class.new(attributes)
      expect(factory.requests.count).to eq(3)
      expect(factory.requests[0].requestable.tube).to be_present
    end

    it 'produces error messages if any of the resources are not valid' do
      attributes << {}
      factory = described_class.new(attributes)
      expect(factory).to_not be_valid
      expect(factory.errors.full_messages).to_not be_empty
    end
  end

  context '#save' do
    it 'creates a request in a tube for each set of attributes if they are valid' do
      factory = described_class.new(attributes)
      expect(factory).to be_valid
      expect(factory.save).to be_truthy
      expect(described_class.request_model.all.count).to eq(attributes.length)
      expect(described_class.request_model.first.tube).to eq(attributes.first[:tube])
    end

    it 'has some requestables' do
      factory = Pacbio::RequestFactory.new(attributes)
      factory.save
      expect(factory.requestables.count).to eq(3)
    end

    it 'doesnt create a sample if it already exists' do
      sample = create(:sample)
      attributes << sample.attributes.extract!('name', 'species', 'external_id').with_indifferent_access.merge(attributes_for(request_model))
      factory = described_class.new(attributes)
      factory.save
      expect(Sample.count).to eq(4)
    end

    it 'does not create any samples if attributes are not valid' do
      attributes << attributes_for(:sample).except(:name).merge(attributes_for(request_model))
      factory = described_class.new(attributes)
      expect(factory).not_to be_valid
      expect(factory.save).to be_falsey
      expect(Tube.all.count).to eq(0)
    end
  end
 
end