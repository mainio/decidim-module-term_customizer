# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:translation_set) { create(:translation_set, organization: organization) }
        let(:key) { "translation.key" }
        let(:locale) { I18n.locale }
        let(:value) { Decidim::Faker::Localized.sentence(word_count: 3) }
        let(:params) { { key: key, value: value } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization,
            translation_set: translation_set
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when updating an existing translation without changing the key" do
          let(:translation) { create(:translation, key: key, translation_set: translation_set) }
          let(:params) { { id: translation.id, key: key, value: value } }

          it { is_expected.to be_valid }
        end

        it_behaves_like "translation validatable"
      end
    end
  end
end
