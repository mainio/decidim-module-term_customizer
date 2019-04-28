# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::TranslationImportCollection do
  subject { described_class.new(translation_set, records, locales) }

  let(:translation_set) { create(:translation_set) }
  let(:records) do
    build_list(:translation, 10, translation_set: translation_set)
  end
  let(:locales) { [:en] }

  describe "#import_attributes" do
    let(:expected_attributes) do
      records.map do |tr|
        { locale: tr.locale, key: tr.key, value: tr.value }
      end
    end

    it "returns the correct attributes" do
      expect(subject.import_attributes).to eq(expected_attributes)
    end

    context "with multiple locales" do
      let(:locales) { [:en, :fi, :sv] }

      let(:expected_attributes) do
        records.map do |tr|
          locales.map do |locale|
            if locale.to_s == tr.locale
              { locale: tr.locale, key: tr.key, value: tr.value }
            else
              { locale: locale.to_s, key: tr.key, value: "" }
            end
          end
        end.flatten
      end

      before do
        I18n.available_locales = locales
      end

      it "returns the correct attributes" do
        expect(subject.import_attributes).to eq(expected_attributes)
      end
    end

    context "with duplicate keys" do
      let(:records) do
        duplicate_attributes.map do |attr|
          build(
            :translation,
            locale: attr[:locale],
            key: attr[:key],
            value: attr[:value],
            translation_set: translation_set
          )
        end
      end

      let(:duplicate_attributes) do
        [
          { locale: "en", key: "key1", value: "Value1" },
          { locale: "en", key: "key1", value: "Value1-1" },
          { locale: "en", key: "key2", value: "Value2" },
          { locale: "en", key: "key2", value: "Value2-2" }
        ]
      end

      let(:expected_attributes) do
        [
          { locale: "en", key: "key1", value: "Value1" },
          { locale: "en", key: "key2", value: "Value2" }
        ]
      end

      it "returns the correct attributes with duplicates removed" do
        expect(subject.import_attributes).to eq(expected_attributes)
      end
    end
  end
end
