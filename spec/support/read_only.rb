  # This allows us to unlock read only tables for testing
  def set_read_only(klasses, readonly=false)
    Array(klasses).each do |klass|
      klass.define_method(:readonly?) { readonly }
    end
  end
