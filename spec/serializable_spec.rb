# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Railsful::Serializable do
  let(:base_controller) do
    Class.new do
      def render(*args);
        check_render(*args)
      end

      def check_render(*); end
      def request; end
      def params; end
    end
  end
  let(:controller) do
    Class.new(base_controller) do
      prepend Railsful::Serializable

      def index
        render :index
      end

      def new
        render :new, layout: true
      end

      def create
        render json: { test: true }
      end
    end.new
  end

  describe '#render' do
    context 'with layout' do
      it 'does not call #fast_jsonapi_options' do
        expect(controller).not_to receive(:fast_jsonapi_options)
        controller.new
      end

      it 'passes the render request through to its super class' do
        expect(controller).to \
          receive(:check_render).with(:new, { layout: true })
        controller.new
      end
    end

    context 'with page template' do
      it 'does not call #fast_jsonapi_options' do
        expect(controller).not_to receive(:fast_jsonapi_options)
        controller.index
      end

      it 'passes the render request through to its super class' do
        expect(controller).to receive(:check_render).with(:index, {})
        controller.index
      end
    end

    context 'with JSON' do
      it 'calls #fast_jsonapi_options' do
        expect(controller).to \
          receive(:fast_jsonapi_options).with(json: { test: true })
        controller.create
      end
    end
  end
end
