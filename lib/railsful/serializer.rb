# frozen_string_literal: true

require 'railsful/interceptors/errors'
require 'railsful/interceptors/include'
require 'railsful/interceptors/pagination'
require 'railsful/interceptors/sorting'

module Railsful
  # This class allows to encapsulate the interceptor logic from the
  # prepended controller, so the controller is not polluted with
  # all needed (helper) methods.
  class Serializer
    # All interceptors that provide jsonapi logic.
    prepend Interceptors::Include
    prepend Interceptors::Pagination
    prepend Interceptors::Sorting
    prepend Interceptors::Errors

    attr_reader :controller

    # Keep a reference to the controller, so all helper methods
    # like +url_for+ can be used.
    def initialize(controller)
      @controller = controller
    end

    # The render function every interceptor MUST implement in order to
    # add certain functionality.
    #
    # @param options [Hash] The render options hash.
    # @return [Hash] The (modified) render options hash.
    #
    # :reek:FeatureEnvy
    def render(options)
      # Get the renderable (Object that should be rendered) from options hash.
      renderable = options[:json]

      # Return if renderable is blank
      return options unless renderable

      # Try to fetch the right serializer for given renderable.
      serializer = serializer_for(renderable, options)

      # When no serializer is found just pass the original options hash.
      return options unless serializer

      # Replace json value with new serializer
      options.merge(json: serializer.new(renderable, options))
    end

    # Find the right serializer for given object.
    # First we will look if the options hash includes a serializer. If not,
    # we try to guess the right serializer from the model/class name.
    #
    # @param renderable [ApplicationRecord, ActiveRecord::Relation]
    # @param options [Hash]
    # @return [Class] The serializer class.
    #
    # :reek:UtilityFunction
    def serializer_for(renderable, options = {})
      serializer_by_options(options) || serializer_by_renderable(renderable)
    end

    # Check the options hash for a serializer key.
    #
    # @return [Class] The serializer class.
    #
    # :reek:UtilityFunction
    def serializer_by_options(options)
      serializer = options[:serializer]
      return unless serializer

      # If the given serializer is a class return it.
      return serializer if serializer.is_a? Class

      "#{serializer.to_s.classify}Serializer".safe_constantize
    end

    # @return [Class] The serializer class.
    #
    # :reek:UtilityFunction
    def serializer_by_renderable(renderable)
      # Get the class in order to find the right serializer.
      klass = if renderable.is_a?(ActiveRecord::Relation)
                renderable.model.name
              else
                renderable.class.name
              end

      "#{klass}Serializer".safe_constantize
    end

    # Fetch the params from controller.
    #
    # @return [] The params.
    def params
      controller.params
    end

    # Fetch the HTTP method from controllers request.
    #
    # @return [String] The method.
    def method
      controller.request.request_method
    end

    # Check if given options contain an ActiveRecord::Relation.
    #
    # @param options [Hash] The options.
    # @return [Boolean] The answer.
    #
    # :reek:UtilityFunction
    def relation?(options)
      options[:json].is_a?(ActiveRecord::Relation)
    end
  end
end
