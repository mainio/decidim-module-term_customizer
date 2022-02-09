# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationsDestroyForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:translation_set) { create(:translation_set, organization: organization) }
        let(:translations) { create_list(:translation, 10, translation_set: translation_set) }
        let(:params) { { translation_ids: translations.map(&:id) } }

        let(:form_translation_set) { translation_set }
        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization,
            translation_set: form_translation_set
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when no translation set is specified" do
          let(:form_translation_set) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when no translations are given" do
          let(:translations) { [] }

          it { is_expected.not_to be_valid }
        end

        describe "#translations" do
          it "returns the translations" do
            expect(subject.translations).to eq(translations)
          end
        end

        describe "#translations_current" do
          it "returns the translations" do
            expect(subject.translations).to eq(translations)
          end
        end

        context "when additional translations are available with other locales" do
          before do
            # Create the translations with the same keys with other locales
            [:fi, :sv].each do |locale|
              translations.each do |tr|
                create(
                  :translation,
                  translation_set: translation_set,
                  locale: locale,
                  key: tr.key,
                  value: Decidim::Faker::Localized.sentence(word_count: 3)
                )
              end
            end
          end

          describe "#translations" do
            it "returns all translations" do
              expect(subject.translations).to eq(
                translation_set.translations.where(
                  key: translations.map(&:key)
                ).order(:id)
              )
            end
          end

          describe "#translations_current" do
            it "returns only the provided translations" do
              expect(subject.translations_current).to eq(translations)
            end
          end
        end
      end
    end
  end
end
