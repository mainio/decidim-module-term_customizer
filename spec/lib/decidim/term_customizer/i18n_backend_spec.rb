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

  let(:pluralize_translations_list) do
    {
      en: {
        decidim: {
          term1: {
            one: "Term 1 singular",
            other: "Term 1 plural"
          }
        }
      },
      ja: {
        decidim: {
          term1: {
            other: "Term 1 invariant"
          }
        }
      }
    }
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
          create_list(:translation, 3, locale:)
        end
      end

      it "returns an empty result" do
        expect(subject.available_locales).to match_array(locales)
      end
    end

    context "when the translation query raises ActiveRecord::StatementInvalid" do
      it "returns and empty result" do
        allow(Decidim::TermCustomizer::Translation).to receive(
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
      let(:loader) { double }

      before do
        allow(Decidim::TermCustomizer).to receive(:loader).and_return(loader)
        allow(loader).to receive(:translations_hash).and_return([])
      end

      it "returns true" do
        subject.translations
        expect(subject.initialized?).to be(true)
      end
    end
  end

  describe "#reload!" do
    let(:loader) { double }

    before do
      allow(Decidim::TermCustomizer).to receive(:loader).and_return(loader)
      allow(loader).to receive(:translations_hash).and_return([])
    end

    it "resets the translations" do
      subject.translations
      subject.reload!

      expect(subject.initialized?).to be(false)
    end
  end

  describe "#translations" do
    let(:loader) { double }

    before do
      allow(Decidim::TermCustomizer).to receive(:loader).and_return(loader)
      allow(loader).to receive(:translations_hash).and_return(translations_list)
    end

    it "returns the correct translations list" do
      expect(subject.translations).to match(translations_list)
    end
  end

  describe "#translate" do
    it "calls lookup" do
      allow(subject).to receive(:lookup).and_return("Translation") # rubocop:disable RSpec/SubjectStub
      result = subject.translate(:en, "decidim.term1")
      expect(result).to eq("Translation")
    end

    context "with actual translations" do
      let(:loader) { double }

      before do
        allow(Decidim::TermCustomizer).to receive(:loader).and_return(loader)
        allow(loader).to receive(:translations_hash).and_return(translations_list)
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

    context "with plural forms" do
      let(:loader) { double }

      before do
        allow(Decidim::TermCustomizer).to receive(:loader).and_return(loader)
        allow(loader).to receive(:translations_hash).and_return(pluralize_translations_list)
      end

      it "translates the translation keys correctly" do
        expect(subject.translate(:en, "decidim.term1", count: 1)).to eq("Term 1 singular")
        expect(subject.translate(:en, "decidim.term1", count: 2)).to eq("Term 1 plural")
        expect(subject.translate(:ja, "decidim.term1", count: 1)).to eq("Term 1 invariant")
        expect(subject.translate(:ja, "decidim.term1", count: 2)).to eq("Term 1 invariant")
      end
    end
  end
end
