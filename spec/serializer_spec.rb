# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Railsful::Serializer do
  let(:controller) { TestController.new }
  let(:serializer) { described_class.new(controller) }
  let(:renderable) { Dummy.new(1337) }
  let(:params) { {} }

  before do
    allow(controller).to receive(:params).and_return(params)
  end

  describe '#render' do
    context 'when renderable is plain JSON' do
      let(:json) { { json: 'foo'} }

      it 'does nothing' do
        expect(serializer.render(json)).to eq(json)
      end

      context 'when pagination params are given' do
        let(:params) { { page: { number: 1, size: 10 } } }

        it 'does nothing' do
          expect(serializer.render(json)).to eq(json)
        end
      end

      context 'when include params are given' do
        let(:params) { { include: 'address' } }

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
        let(:params) { { include: 'address' } }

        it 'adds a links key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(:json, :include))
            .once

          serializer.render(json)
        end
      end

      context 'when wrong pagination params are given' do
        let(:params) { { page: 1 } }

        before do
          allow(renderable).to receive(:is_a?).and_return(true)
        end

        it 'raises an error' do
          expect { serializer.render(json) }
            .to raise_error(Railsful::PaginationError)
        end
      end

      context 'when pagination include params are given' do
        let(:params) { { page: { number: 1, size: 10 } } }

        before do
          allow(renderable).to receive(:is_a?).and_return(true)
        end

        it 'adds a links key to the options' do
          expect(DummySerializer)
            .to receive(:new)
            .with(renderable, hash_including(:json, :links, :meta))
            .once

          serializer.render(json)
        end
      end

      describe 'errors' do
        before do
          allow(renderable).to receive(:errors).and_return([true])
        end

        it 'does not call the serializer' do
          expect(DummySerializer).not_to receive(:new)
          serializer.render(json)
        end

        it 'replaces the renderable with an errors hash' do
          expect(serializer.render(json))
            .to include(json: { errors: [true] })
        end
      end
    end
  end
end
