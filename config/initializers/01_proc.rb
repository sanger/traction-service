# frozen_string_literal: true

# www.mattsears.com/articles/2011/11/27ruby-blocks-as-dynamic-callbacks
# rubocop:disable Style/CaseEquality, Style/MethodMissingSuper
class Proc
  def callback(callable, *args)
    self === Class.new do
      method_name = callable.to_sym
      define_method(method_name) { |&block| block ? block.call(*args) : true }
      define_method("#{method_name}?") { true }
      def method_missing(*_args)
        false
      end

      def respond_to_missing?(*)
        true
      end
    end.new
  end
end
# rubocop:enable Style/CaseEquality, Style/MethodMissingSuper
