# frozen_string_literal: true

module Railsful
  # The base error for this gem.
  class Error < StandardError
    attr_reader :detail, :status

    # Initializer.
    #
    # @param detail [String] The detailed message.
    # @param status [Integer] The status code.
    def initialize(detail = nil, status = 400)
      @detail = detail
      @status = status
    end

    # Format the error as jsonapi wants it to.
    #
    # @return [Hash]
    def as_json(_options = nil)
      {
        errors: [
          {
            status: status,
            title: self.class.name.demodulize.underscore,
            detail: detail
          }
        ]
      }
    end
  end

  # The error that is raised when pagination fails.
  class PaginationError < Error; end
end
