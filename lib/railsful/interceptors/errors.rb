# frozen_string_literal: true

require 'active_model/errors'

module Railsful
  module Interceptors
    # This interceptor checks the given json object for an 'errors' array
    # and checks if any errors are available.
    module Errors
      def render(options)
        super(errors_options(options))
      end

      def errors_options(options)
        return options unless errors?(options)

        # Fetch all the errors from the passed json value.
        errors = errors(options.fetch(:json))

        # Overwrite the json value and set the errors array.
        options.merge(json: { errors: errors })
      end

      # Transform error output format into more "jsonapi" like.
      def errors(raw_errors)
        errors = []

        raw_errors.details.each do |field, array|
          errors += field_errors(field, array)
        end

        errors
      end

      def field_errors(field, array)
        array.map do |hash|
          formatted_error(hash, field)
        end
      end

      # Format the error by adding additional status and field information.
      #
      # :reek:UtilityFunction
      def formatted_error(hash, field)
        {
          status: '422',
          field: field
        }.merge(hash)
      end

      # Checks if given renderable is an ActiveModel::Error
      #
      # :reek:UtilityFunction
      def errors?(options)
        return false unless options

        options.fetch(:json, nil).is_a?(ActiveModel::Errors)
      end
    end
  end
end
