# frozen_string_literal: true

RSpec.describe Railsful::Deserializer do
  let(:controller) { TestController.new }
  let(:deserialized) { controller.deserialized_params.to_unsafe_hash }

  let(:params_with_empty) do
    ActionController::Parameters.new({})
  end

  let(:params_with_attributes) do
    ActionController::Parameters.new(
      data: { attributes: { foo: 'bar' } }
    )
  end

  let(:params_with_relationship) do
    ActionController::Parameters.new(
      data: {
        attributes: { foo: 'bar' },
        relationships: { foo: { data: { id: 1 } } }
      }
    )
  end

  let(:params_with_has_many) do
    ActionController::Parameters.new(
      data: {
        attributes: { foo: 'bar' },
        relationships: { foo: { data: [{ id: 1 }] } }
      }
    )
  end

  let(:params_with_included) do
    ActionController::Parameters.new(
      data: {
        attributes: { foo: 'bar' },
        relationships: { address: { data: { tempid: 1 } } }
      },
      included: [
        { type: 'address', tempid: 1, attributes: { street: 'foobar st. 1' } }
      ]
    )
  end

  describe '#deserialized_params' do
    context 'when params are empty' do
      before do
        allow(controller)
          .to receive(:params)
          .and_return(params_with_empty)
      end

      it 'returns an empty hash' do
        expect(deserialized).to be_empty
      end
    end

    context 'when attributes are given' do
      before do
        allow(controller)
          .to receive(:params)
          .and_return(params_with_attributes)
      end

      it 'returns a hash with attributes' do
        expect(deserialized).to eq('foo' => 'bar')
      end
    end

    context 'when relationship is given' do
      before do
        allow(controller)
          .to receive(:params)
          .and_return(params_with_relationship)
      end

      it 'adds the relationship with _id suffix to hash' do
        expect(deserialized).to eq('foo' => 'bar', 'foo_id' => 1)
      end
    end

    context 'when has_many relationship is given' do
      before do
        allow(controller)
          .to receive(:params)
          .and_return(params_with_has_many)
      end

      it 'adds the relationship with _id suffix to hash' do
        expect(deserialized).to eq('foo' => 'bar', 'foo_ids' => [1])
      end
    end

    context 'when included is given' do
      before do
        allow(controller)
          .to receive(:params)
          .and_return(params_with_included)
      end

      it 'adds the included with _attributes suffix' do
        expect(deserialized).to eq(
          'foo' => 'bar',
          'address_attributes' => { 'street' => 'foobar st. 1' }
        )
      end
    end
  end
end
