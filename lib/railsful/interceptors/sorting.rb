# frozen_string_literal: true

module Railsful
  module Interceptors
    # Interceptor that paginates a given ActiveRecord::Relation
    # with help of the Kaminari gem.
    module Sorting
      def render(options)
        super(sorting_options(options))
      end

      def sorting_options(options)
        # Check if json value should be sorted.
        return options unless sort?(options)

        # Get the relation from options hash so we can sort it
        relation = options.fetch(:json)

        # Sort the relation and store new relation in temporary variable.
        sorted = sort(relation)
        
        options.merge(json: sorted)
      end

      private

      # Check if given entity is sortable and request allows sorting.
      #
      # @param options [Hash] The global render options.
      # @return [Boolean] The answer.
      def sort?(options)
        method == 'GET' && relation?(options) && params.fetch(:sort, nil)
      end

      # Map the sort params to a database friendly set of strings
      #
      # @return [Array] Array of string e.g. ['name DESC', 'age ASC']
      def order_attributes
        params.fetch(:sort).split(",").map do |attribute|
          next unless attribute =~ /\A-?\w+\z/ # allow only word chars
          if attribute.start_with?("-")
            "#{attribute[1..-1]} DESC"
          else
            "#{attribute} ASC"
          end
        end.compact
      end

      # Sort given relation
      #
      # @param relation [ActiveRecord::Relation] The relation.
      # @return [ActiveRecord::Relation] The paginated relation.
      def sort(relation)
        order_string = order_attributes.join(", ")
        # support both #reorder and #order call on relation
        if relation.respond_to? :reorder
          relation.reorder(order_string)
        elsif relation.respond_to? :order
          relation.order(order_string)
        end
        relation
      end
    end
  end
end
