# frozen_string_literal: true

# Checks if a key belongs to an object
# Parameters:
# object: A Hash
# key: str
# Returns
# true if the key is present, or false if the key is not present
def check_key(object, key)
  unless object.key?(key)
    Rails.logger.error "Cannot find #{key} in object"
    return false
  end
  true
end

# Checks if the value of a key matchs a regular expression defined in another
# object
# Parameters:
# object: Hash that contains a regular expression in the key
# compared_object: hash that contains a value in the key
# key: str
# Returns
# true if the value matches the regular expresion, or false if it doesnt match
# if there is no regular expression it returns nil
def check_regexp(object, compared_object, key)
  return unless compared_object[key].is_a?(Regexp)

  unless compared_object[key].match(object[key].to_s)
    Rails.logger.error "Cannot match regexp for key #{key}"
    return false
  end
  true
end

# Checks if the subtree matches the elements across objects
# object
# Parameters:
# object: Hash that contains a subtree in the key
# compared_object: hash that contains a subtree in the key
# key: str
# Returns
# true if the subtree matches between objects, or false if it doesnt match
# if there is no subtree it returns nil
def check_subtree(object, compared_object, key)
  return unless compared_object[key].is_a?(Hash)

  unless check_objects(object[key], compared_object[key])
    Rails.logger.error "Cannot match subtree at #{key}"
    return false
  end
  true
end

def _compare_array(object, compared_object, key)
  compared_object[key].each_with_index do |_value, pos|
    unless check_objects(object[key][pos], compared_object[key][pos])
      Rails.logger.error "Difference when checking position #{pos} of key #{key}"
      return false
    end
  end
end

# Checks if the arrays matches the elements across objects
# object
# Parameters:
# object: Hash that contains an array in the key
# compared_object: hash that contains an array in the key
# key: str
# Returns
# true if the array matches all elements between objects, or false if it doesnt match
# if there is no array it returns nil
def check_array(object, compared_object, key)
  return unless compared_object[key].is_a?(Array)

  unless object[key].is_a?(Array)
    Rails.logger.error "The element #{key} from the original object is not an array"
    return false
  end

  unless object[key].length == compared_object[key].length
    Rails.logger.error "The length of both arrays at #{key} is different"
    return false
  end

  val = _compare_array(object, compared_object, key)
  return val unless val.nil?

  true
end

# Checks if the value matches across objects for the same key
# object
# Parameters:
# object: Hash that contains a value in the key
# compared_object: hash that contains a value in the key
# key: str
# Returns
# true if the value matches between objects, or false if it doesnt match
def check_value(object, compared_object, key)
  unless compared_object[key] == object[key]
    Rails.logger.error "Cannot match subtree at #{key}"
    return false
  end
  true
end

# Run a pipeline of checks on two objects. If a step in the pipeline
# returns true or false, it will return that value as the result of the check
# but if the step returns nil, it will continue running the next step of
# the pipeline until all of them have been completed, or any of them has returned
# a true/false value.
# If none of the steps of the pipeline returns a boolean at the end, it will consider
# the final result as true.
# Parameters:
# object: Hash
# compared_object: Hash
# key: string
# Returns:
# false if one of the steps of the pipeline returned false; true if one of the steps
# of the pipeline returned true, or if all the steps returned nil
def run_checks_pipeline(object, compared_object, key)
  pipelines = %w[
    check_regexp check_subtree check_array check_value
  ]
  pipelines.each do |method_name|
    value = send(method_name, object, compared_object, key)
    return value unless value.nil?
  end
  true
end

# Performs a recursive check of values between two objects
# Parameters:
# object: Hash
# compared_object: Hash
# Returns
# true if the hashes matches all elements, or false if they dont match
def check_objects(object, compared_object)
  return object == compared_object unless compared_object.is_a?(Hash)

  compared_object.keys.each do |key|
    return false unless check_key(object, key)
    return false unless run_checks_pipeline(object, compared_object, key)
  rescue StandardError => e
    Rails.logger.error("Error while processing #{key} with #{e}")
    return false
  end
  true
end

# Performs a check of values between a json and a Hash object
# Parameters:
# json: JSON string
# compared_object: Hash
# Returns
# true if after converting the json, the hashes matches all elements across both objects
# , or false if they dont match
def match_json(json, compared_object)
  check_objects(JSON.parse(json), compared_object)
end
