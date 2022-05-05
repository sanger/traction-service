# frozen_string_literal: true

# This allows us to unlock read only tables for testing
def set_read_only(klasses, readonly = false)
  Array(klasses).each do |klass|
    allow_any_instance_of(klass).to receive(:readonly?).and_return(readonly)
  end
end
