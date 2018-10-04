# frozen_string_literal: true

module Railsful
  class Railtie < Rails::Railtie
    initializer 'railsful.action_controller' do
      ActiveSupport.on_load(:action_controller) do
        prepend Railsful::Serializable
        include Railsful::Deserializable
      end
    end
  end
end
