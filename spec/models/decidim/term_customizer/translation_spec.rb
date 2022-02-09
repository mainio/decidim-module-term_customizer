# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Translation do
      subject { translation }

      let(:organization) { create(:organization) }
      let(:translation_set) { create(:translation_set, organization: organization) }
      let(:translation) do
        build(
          :translation,
          translation_set: translation_set,
          locale: locale,
          key: key,
          value: value
        )
      end
      let(:locale) { :en }
      let(:key) { "translation.key" }
      let(:value) { ::Faker::Lorem.sentence(word_count: 3) }

      it { is_expected.to be_valid }

      it "is attached to the correct translation set" do
        expect(subject.translation_set).to eq(translation_set)
      end

      context "when locale is empty" do
        let(:locale) { nil }

        it { is_expected.to be_invalid }
      end

      it_behaves_like "translation validatable"
    end
  end
end
