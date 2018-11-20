# frozen_string_literal: true

require 'ostruct'

# TestController which mocks a "real" ActionController.
# Both concerns are included/prepended.
class TestController
  prepend Railsful::Serializable
  include Railsful::Deserializable

  def render(options = nil, extra_options = {}, &block)
    # We just return the options here so we can test
    # all prepended interceptors.
    options
  end

  def request
    OpenStruct.new(request_method: 'GET')
  end
end
