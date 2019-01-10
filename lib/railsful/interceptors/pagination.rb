# frozen_string_literal: true

module Railsful
  module Interceptors
    # Interceptor that paginates a given ActiveRecord::Relation
    # with help of the Kaminari gem.
    module Pagination
      def render(options)
        super(pagination_options(options))
      end

      def pagination_options(options)
        # Check if json value should be paginated.
        return options unless paginate?(options)

        # Get the relation from options hash so we can paginate it and
        # check the total count.
        relation = options.fetch(:json)

        # Paginate the relation and store new relation in temporary variable.
        paginated = paginate(relation)

        # Create a meta hash
        meta = {
          total_pages: paginated.try(:total_pages),
          total_count: paginated.try(:total_count),
          current_page: paginated.try(:current_page),
          next_page: paginated.try(:next_page),
          prev_page: paginated.try(:prev_page)
        }

        options.deeper_merge(
          links: links(paginated), meta: meta
        ).merge(json: paginated)
      end

      private

      # Check if given entity is paginatable and request allows pagination.
      #
      # @param options [Hash] The global render options.
      # @return [Boolean] The answer.
      def paginate?(options)
        method == 'GET' &&
          params.fetch(:page, nil) &&
          relation?(options)
      end

      # Paginate given relation
      #
      # @param relation [ActiveRecord::Relation] The relation.
      # @return [ActiveRecord::Relation] The paginated relation.
      def paginate(relation)
        # If page param is not a hash, raise an error.
        unless params.to_unsafe_hash.fetch(:page, nil).is_a?(Hash)
          raise PaginationError,
                'Wrong pagination format. Hash expected.'
        end

        # Get the per page size.
        per_page = params.dig(:page, :size)

        relation = relation.page(params.dig(:page, :number))
        relation = relation.per(per_page) if per_page

        relation
      end

      # Create the pagination links
      #
      # @param relation [ActiveRecord::Relation] The relation to be paginated.
      # @return [Hash] The +links+ hash.
      def links(relation)
        per_page = params.dig(:page, :size)

        {
          self: collection_url(relation.try(:current_page), per_page),
          next: collection_url(relation.try(:next_page), per_page),
          prev: collection_url(relation.try(:prev_page), per_page)
        }
      end

      # The assembled pagination url.
      #
      # @param per_page [Integer] The per page count.
      # @param page [Integer] The page.
      # @return [String] The URL.
      def collection_url(page, per_page)
        return nil unless page

        # Set fallback pagination.
        # TODO: Get it from the model.
        per_page ||= 25

        # The +#url_for+ method comes from the given controller.
        controller.url_for \
          controller: params[:controller],
          action: params[:action],
          params: {
            page: { number: page, size: per_page }
          }
      end
    end
  end
end
