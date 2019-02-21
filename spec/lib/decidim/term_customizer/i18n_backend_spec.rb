# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::I18nBackend do
  let(:translations_list) do
    {
      en: {
        decidim: {
          term1: "Term 1",
          term2: "Term 2"
        }
      },
      fi: {
        decidim: {
          term1: "Termi 1",
          term2: "Termi 2"
        }
      },
      sv: {
        decidim: {
          term1: "Term 1",
          term2: "Term 2"
        }
      }
    }
  end
  let(:translation_objects) do
    objects = []
    translations_list.each_with_object({}) do |(locale, v)|
      objects << flatten_hash(v).map do |translation_key, translation_term|
        create(:translation, locale: locale, key: translation_key, value: translation_term)
      end
    end
    objects.flatten
  end

  describe "#available_locales" do
    context "when no translations are available" do
      it "returns an empty result" do
        expect(subject.available_locales).to be_empty
      end
    end

    context "when translations are available" do
      let(:locales) { [:en, :fi, :sv, :no, :da, :ee, :lv, :lt, :pl, :de] }

      before do
        locales.each do |locale|
          create_list(:translation, 3, locale: locale)
        end
      end

      it "returns an empty result" do
        expect(subject.available_locales).to match_array(locales)
      end
    end

    context "when the translation query raises ActiveRecord::StatementInvalid" do
      it "returns and empty result" do
        expect(Decidim::TermCustomizer::Translation).to receive(
          :available_locales
        ).and_raise(ActiveRecord::StatementInvalid)

        expect(subject.available_locales).to be_empty
      end
    end
  end

  describe "#initialized?" do
    context "when translations are not loaded" do
      it "returns false" do
        expect(subject.initialized?).to be(false)
      end
    end

    context "when translations are loaded" do
      let(:resolver) { double }

      before do
        allow(Decidim::TermCustomizer).to receive(:resolver).and_return(resolver)
        expect(resolver).to receive(:translations).and_return([])
      end

      it "returns true" do
        subject.translations
        expect(subject.initialized?).to be(true)
      end
    end
  end

  describe "#reload!" do
    let(:resolver) { double }

    before do
      allow(Decidim::TermCustomizer).to receive(:resolver).and_return(resolver)
      expect(resolver).to receive(:translations).and_return([])
    end

    it "resets the translations" do
      subject.translations
      subject.reload!

      expect(subject.initialized?).to be(false)
    end
  end

  describe "#translations" do
    let(:resolver) { double }

    before do
      translations = translation_objects
      allow(Decidim::TermCustomizer).to receive(:resolver).and_return(resolver)
      expect(resolver).to receive(:translations).and_return(translations)
    end

    it "returns the correct translations list" do
      expect(subject.translations).to match(translations_list)
    end
  end

  describe "#translate" do
    it "calls lookup" do
      expect(subject).to receive(:lookup).and_return("Translation")
      subject.translate(:en, "decidim.term1")
    end

    context "with actual translations" do
      let(:resolver) { double }

      before do
        translations = translation_objects
        allow(Decidim::TermCustomizer).to receive(:resolver).and_return(resolver)
        expect(resolver).to receive(:translations).and_return(translations)
      end

      it "translates the translation keys correctly" do
        expect(subject.translate(:en, "decidim.term1")).to eq("Term 1")
        expect(subject.translate(:en, "decidim.term2")).to eq("Term 2")
        expect(subject.translate(:fi, "decidim.term1")).to eq("Termi 1")
        expect(subject.translate(:fi, "decidim.term2")).to eq("Termi 2")
        expect(subject.translate(:sv, "decidim.term1")).to eq("Term 1")
        expect(subject.translate(:sv, "decidim.term2")).to eq("Term 2")
      end
    end
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else
        h[k.to_s] = v
      end
    end
  end
end
