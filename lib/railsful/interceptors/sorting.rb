# frozen_string_literal: true

module Railsful
  module Interceptors
    # Interceptor that sorts a given ActiveRecord::Relation
    module Sorting
      def render(options)
        super(sorting_options(options))
      end

      def sorting_options(options)
        # Check if json value should be sorted.
        return options unless sort?(options)

        # Get the relation from options hash so we can sort it
        relation = options.fetch(:json)

        options.merge(json: sort(relation))
      end

      private

      # Check if given entity is sortable and request allows sorting.
      #
      # @param options [Hash] The global render options.
      # @return [Boolean] The answer.
      def sort?(options)
        method == 'GET' && params.fetch(:sort, false) && relation?(options)
      end

      # Format a sort string to a database friendly order string
      #
      # @return [String] database order query e.g. 'name DESC'
      #
      # :reek:UtilityFunction
      def order(string)
        string.start_with?('-') ? "#{string[1..-1]} DESC" : "#{string} ASC"
      end

      # Map the sort params to a database friendly set of strings
      #
      # @return [Array] Array of string e.g. ['name DESC', 'age ASC']
      def orders
        params.fetch(:sort).split(',').map do |string|
          next unless string =~ /\A-?\w+\z/ # allow only word chars

          order(string)
        end.compact
      end

      # Sort given relation
      #
      # @param relation [ActiveRecord::Relation] The relation.
      # @return [ActiveRecord::Relation] The sorted relation.
      def sort(relation)
        order_string = orders.join(', ')
        # support both #reorder and #order call on relation
        return relation.reorder(order_string) if relation.respond_to?(:reorder)
        return relation.order(order_string) if relation.respond_to?(:order)

        raise SortingError, 'Relation does not respond to #reorder or #order.'
      end
    end
  end
end
