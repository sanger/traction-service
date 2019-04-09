module Pipelines
  class Message
    include ActiveModel::Model 

    attr_accessor :object, :configuration

    def timestamp
      Time.current
    end

    def content
      {}.tap do |result|
        configuration.fields.each_with_object(result) do |(k,v), result|
          result[k] = instance_value(v)
        end
        result[:updated_at] = timestamp
        result[:id_lims] = configuration.id_lims
      end 
    end

    private

    def instance_value(chain)
      chain.split('.').inject(object, :send)
    end
  end
end