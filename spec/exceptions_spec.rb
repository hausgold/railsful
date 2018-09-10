# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Railsful::Error do
  let(:message) { 'Some message' }
  let(:error) do
    described_class.new(message)
  end

  describe '#as_json' do
    it 'renders the right format' do
      expected = {
        errors: [
          {
            status: 400,
            title: 'error',
            detail: message
          }
        ]
      }

      expect(error.as_json).to eq(expected)
    end
  end
end

RSpec.describe Railsful::PaginationError do
  let(:message) { 'Bad parameters given.' }
  let(:error) do
    described_class.new(message)
  end

  describe '#as_json' do
    it 'renders the right format' do
      expected = {
        errors: [
          {
            status: 400,
            title: 'pagination_error',
            detail: message
          }
        ]
      }

      expect(error.as_json).to eq(expected)
    end
  end
end
