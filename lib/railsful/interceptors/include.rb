# frozen_string_literal: true

module Railsful
  module Interceptors
    # This interceptors implements the "include" functionality for
    # a given record or a relation.
    module Include
      def render(options)
        super(include_options(options))
      end

      def include_options(options)
        # Check if include key should be merged into options hash.
        return options unless should_include?

        # Deep merge include options, so we do not override existing
        # include options.
        options.deeper_merge(include: includes)
      end

      # Check if options should contain includes.
      #
      # @return [Boolean] The answer.
      def should_include?
        # Only GET requests should have the "include" functionality,
        # since it may be a parameter in a create or update action.
        method == 'GET' && includes.any?
      end

      # Fetch the list of all includes.
      #
      # @return [Array] The list of all include options.
      def includes
        params.fetch(:include, nil).to_s.split(',')
      end
    end
  end
end
