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
      # Fetch attributes including resource id.
      deserialized = attributes(params)

      # Get the included elements.
      deserialized.deeper_merge!(included_hash(params))

      # Return the deserialized params.
      ActionController::Parameters.new(deserialized)
    end

    # First level attributes from data object.
    #
    # @return [Hash]
    #
    # :reek:FeatureEnvy
    def attributes(params)
      data = params.fetch(:data, {})

      # Merge the resources attributes. Also merge the id since jsonapi does
      # not allow ids in the attribute body.
      attrs = data.fetch(:attributes, {}).merge(id: data[:id])

      # Get the already existing relationships
      data.fetch(:relationships, {}).each do |type, payload|
        attrs.merge!(relationship(type, payload))
      end

      attrs.compact
    end

    # Fetches all included associations/relationships from the
    # included hash.
    #
    # @return [Hash]
    #
    # :reek:UtilityFunction
    # :reek:FeatureEnvy
    def included_hash(params)
      # Gather all necessary data we are working on.
      included = params.fetch(:included, [])
      relationships = params.fetch(:data, {}).fetch(:relationships, {})

      result = {}

      # Make sure that both +included+ and +relationships+ are given.
      # Otherwise we can't do anything and return an empty hash.
      return result if included.empty? || relationships.empty?

      # Iterate over all relationships.
      relationships.each do |type, payload|
        # Get the data value.
        data = payload[:data]

        # Check if we are dealing with a +has_many+ (Array) or +belongs_to+
        # (Hash) relationship.
        if data.is_a?(Array)
          result["#{type}_attributes"] = []

          data.each do |element|
            result["#{type}_attributes"] << get_included(element, included)
          end

          # Remove all nil includes.
          result["#{type}_attributes"].compact!
        else
          result["#{type}_attributes"] = get_included(data, included)
        end
      end

      # Remove all nil includes.
      result.compact
    end

    # Fetch the included object for a given relationship.
    #
    # @return [Hash, NilClass] The extracted included hash.
    #
    # :reek:UtilityFunction
    def get_included(relation, included)
      # Return the attributes of the last found element. But there SHOULD only
      # be one element with the same tempid. If there is a mistake by the client
      # we always take the last.
      found = included.reverse
                      .detect { |inc| inc[:tempid] == relation[:tempid] }

      return nil unless found

      # Return the attributes of the found include hash or an empty hash.
      found.fetch(:attributes, {})
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
