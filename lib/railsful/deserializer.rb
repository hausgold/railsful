# frozen_string_literal: true

require 'deep_merge/rails_compat'
require 'active_support/inflector'

module Railsful
  # The deserializer class handles the "unwrapping" of incoming parameters.
  # It translates jsonapi compliant params to those that Rails understands.
  class Deserializer
    attr_reader :params

    def initialize(params)
      @params = params
    end

    # Deserializes the given params.
    #
    # :reek:FeatureEnvy
    def deserialize
      deserialized = {}

      data = params.fetch(:data, {})

      # Merge the resources attributes
      deserialized.merge!(data.fetch(:attributes, {}))

      # Get the already existing relationships
      data.fetch(:relationships, {}).each do |type, payload|
        deserialized.merge!(relationship(type, payload))
      end

      # Get the included elements.
      deserialized.deeper_merge!(included_hash(params))

      # Return the deserialized params.
      ActionController::Parameters.new(deserialized)
    end

    # Fetches all included associations/relationships from the
    # included hash.
    def included_hash(params)
      included_hash = {}

      params.fetch(:included, []).each do |inc|
        type = inc[:type].to_sym
        attrs = inc[:attributes]

        if params.dig(:data, :relationships, type, :data).is_a?(Array)
          # We pluralize the type since we are dealing with a
          # +has_many+ relationship.
          plural = ActiveSupport::Inflector.pluralize(type)

          included_hash["#{plural}_attributes"] ||= []
          included_hash["#{plural}_attributes"] << attrs
        else
          # When the data value is not an Array we are assuming that we
          # deal with a +has_one+ association. To be on the safe side we also
          # call singularize on the type.
          singular = ActiveSupport::Inflector.singularize(type)

          included_hash["#{singular}_attributes"] = attrs
        end
      end

      included_hash
    end

    def relationship(type, payload)
      data = payload[:data]

      return has_many_relationship(type, data) if data.is_a?(Array)

      belongs_to_relationship(type, data)
    end

    # rubocop:disable Naming/PredicateName
    def has_many_relationship(type, data)
      return {} unless data.is_a?(Array)

      ids = data.map { |relation| relation[:id] }.compact

      return {} if ids.empty?

      { :"#{type}_ids" => ids }
    end
    # rubocop:enable Naming/PredicateName

    def belongs_to_relationship(type, data)
      # Fetch a possible id from the data.
      relation_id = data[:id]

      # If no ID is provided skip it.
      return {} unless relation_id

      # Build the relationship hash.
      { :"#{type}_id" => relation_id }
    end
  end
end
