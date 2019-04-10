module Messages
  class Message
    include ActiveModel::Model 

    attr_accessor :object, :configuration

    def timestamp
      Time.current
    end

    def content
      {}.tap do |result|
        result[configuration.key] = configuration.fields.each_with_object({}) do |(k,v), result|
          result[k] = instance_value(v)
        end
        result[configuration.key][:updated_at] = timestamp
        result[:lims] = configuration.lims
      end 
    end

    def payload
      content.to_json
    end

    private

    def instance_value(chain)
      chain.split('.').inject(object, :send)
    end
  end
end