# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Railsful::Serializer do
  let(:controller) { TestController.new }
  let(:serializer) { described_class.new(controller) }
  let(:renderable) { Dummy.new(1337) }
  let(:param_hash) { {} }
  let(:params) { ActionController::Parameters.new(param_hash) }

  before do
    allow(controller).to receive(:params).and_return(params)
  end

  describe '#render' do
    context 'when renderable is plain JSON' do
      let(:json) { { json: 'foo' } }

      it 'does nothing' do
        expect(serializer.render(json)).to eq(json)
      end

      context 'when pagination params are given' do
        let(:param_hash) { { page: { number: 1, size: 10 } } }

        it 'does nothing' do
          expect(serializer.render(json)).to eq(json)
        end
      end

      context 'when include params are given' do
        let(:param_hash) { { include: 'address' } }

        it 'does nothing' do
          expect(serializer.render(json)).to eq(json)
        end
      end
    end

    context 'when renderable is an object' do
      let(:json) { { json: renderable } }

      it 'calls the right Serializer' do
        expect(DummySerializer)
          .to receive(:new)
          .with(renderable, hash_including(:json))
          .once

        serializer.render(json)
      end

      context 'when include params are given' do
        let(:param_hash) { { include: 'address' } }

        it 'adds a links key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(:json, :include))
            .once

          serializer.render(json)
        end
      end

      context 'when wrong pagination params are given' do
        let(:param_hash) { { page: 1 } }

        before do
          allow(renderable)
            .to receive(:is_a?).with(ActiveModel::Errors) { false }
          allow(renderable)
            .to receive(:is_a?).with(ActiveRecord::Relation) { true }
        end

        it 'raises an error' do
          expect { serializer.render(json) }
            .to raise_error(Railsful::PaginationError)
        end
      end

      context 'when pagination include params are given' do
        let(:param_hash) { { page: { number: 1, size: 10 } } }

        before do
          allow(renderable)
            .to receive(:is_a?).with(ActiveModel::Errors) { false }
          allow(renderable)
            .to receive(:is_a?).with(ActiveRecord::Relation) { true }
        end

        it 'adds a json key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(
              json: instance_of(Dummy)
            )).once

          serializer.render(json)
        end

        it 'adds a links key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(
              links: { next: nil, prev: nil, self: nil }
            )).once

          serializer.render(json)
        end

        it 'adds a meta key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(
              meta: {
                current_page: nil,
                next_page: nil,
                prev_page: nil,
                total_count: nil,
                total_pages: nil
              }
            )).once

          serializer.render(json)
        end
      end

      context 'when sort params are given' do
        let(:param_hash) { { sort: 'name,-age,-?/,(§)' } }
        let(:order_string) { 'name ASC, age DESC' }

        before do
          allow(renderable)
            .to receive(:is_a?).with(ActiveModel::Errors) { false }
          allow(renderable)
            .to receive(:is_a?).with(ActiveRecord::Relation) { true }
        end

        it 'calls reorder on renderable' do
          expect(renderable)
            .to receive(:reorder)
            .with(order_string)
            .once

          serializer.render(json)
        end

        context 'when relation does not respond to #reorder or #order' do
          it 'raises a SortingError' do
            expect { serializer.render(json) }
              .to raise_error(Railsful::SortingError)
          end
        end
      end

      context 'when a serializer is given via options' do
        let(:options) { { json: renderable, serializer: 'another_dummy' } }

        it 'uses the defined serializer' do
          expect(AnotherDummySerializer).to receive(:new)

          serializer.render(options)
        end

        context 'when the class is given' do
          before do
            options.merge(serializer: AnotherDummySerializer)
          end

          it 'uses the class' do
            expect(AnotherDummySerializer).to receive(:new)

            serializer.render(options)
          end
        end
      end
    end

    context 'when renderable is an ActiveModel::Errors' do
      let(:error) { ActiveModel::Errors.new(renderable) }
      let(:error_hash) do
        { errors: [{ error: 'must be valid', field: :name, status: '422' }] }
      end

      before do
        error.add(:name, 'must be valid')
      end

      it 'renders a jsonapi compliant error' do
        expect(controller.render(json: error))
          .to eq(json: error_hash)
      end
    end
  end
end
