# frozen_string_literal: true

# www.mattsears.com/articles/2011/11/27ruby-blocks-as-dynamic-callbacks
<<<<<<< HEAD
# rubocop:disable Style/CaseEquality
=======
>>>>>>> develop
class Proc
  def callback(callable, *args)
    self === Class.new do
      method_name = callable.to_sym
      define_method(method_name) { |&block| block ? block.call(*args) : true }
      define_method("#{method_name}?") { true }
      def method_missing(*_args)
        super
        false
      end

      def respond_to_missing?(*)
        super
        true
      end
    end.new
  end
end
<<<<<<< HEAD
# rubocop:enable Style/CaseEquality
=======
>>>>>>> develop
