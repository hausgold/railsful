# frozen_string_literal: true

module Railsful
  module Serializable
    def render(options = nil, extra_options = {}, &block)

      # In case we see regular page-render requests like:
      #
      #   render :index, layout: true
      #
      # we just pass them through without modification to Rails.
      if options.is_a?(Symbol) || extra_options.key?(:layout)
        return super(*[options, extra_options], &block)
      end

      super(fast_jsonapi_options(options), extra_options, &block)
    end

    def fast_jsonapi_options(options)
      Serializer.new(self).render(options)
    end
  end
end
