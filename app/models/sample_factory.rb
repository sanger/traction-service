class SampleFactory
  include ActiveModel::Model

  validate :check_samples

  def initialize(attributes = [])
    attributes.each { |sample| samples << Sample.new(sample) }
  end

  def samples
    @samples ||= []
  end

  def save
    return false unless valid?
    samples.collect(&:save)
    true
  end

  private

  def check_samples
    samples.each do |sample|
      next if sample.valid?
      sample.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end

end
