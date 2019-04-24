# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe TranslationSerializer do
      subject do
        described_class.new(translation)
      end

      let!(:translation) { create(:translation) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: translation.id)
        end

        it "serializes the locale" do
          expect(serialized).to include(locale: translation.locale)
        end

        it "serializes the key" do
          expect(serialized).to include(key: translation.key)
        end

        it "serializes the value" do
          expect(serialized).to include(value: translation.value)
        end
      end
    end
  end
end
