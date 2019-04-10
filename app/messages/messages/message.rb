# frozen_string_literal: true

module Messages
  # This class is responsible for building messages to go to RabbitMQ
  class Message
    attr_accessor :run

    def initialize(run)
      @run = run
    end

    def generate_json
      {
        'id' => @run.id,
        'name' => @run.name,
        'chip_barcode' => @run&.chip&.barcode
      }.to_json
    end
  end
end