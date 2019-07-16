# frozen_string_literal: true

###
# Useful in initializers.
#
# There are certain lists  such as location types without which the app will be rendered useless.
#
# Normally these will be in a database table but not when the app is first started.
#
# This class has one method which will check whether the table exists and
# if there are any records in it:
# * If there are it will execute the failure block
# * If there are no records the success block will be executed.
#
# Neither block will run in the test environment.
class DependentLoader
  ##
  # Example:
  #  DependentLoader.start(:some_table) do |on|
  #   on.success do
  #    MyConstant = "new value"
  #   end
  #
  #   on.failure do
  #    MyConstant = SomeTable.first.value
  #   end
  #  end
  def self.start(table, &block)
    return unless ActiveRecord::Base.connection.tables.include?(table_name(table)) &&
                  !defined?(::Rake)
    return if Rails.env.test?

    block.callback :success if table.to_s.classify.constantize.all.empty?
    block.callback :failure
  rescue ActiveRecord::NoDatabaseError
    false
  end

  def self.table_name(table)
    table.to_s.gsub('/', '_')
  end
end
