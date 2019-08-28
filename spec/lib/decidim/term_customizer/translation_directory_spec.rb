# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::TranslationDirectory do
  subject { described_class.new(locale) }

  let(:locale) { :en }

  describe "#backend" do
    it "returns the correct backend" do
      expect(subject.backend).to be_a(I18n::Backend::Simple)
    end
  end

  describe "#translations" do
    it "returns a translation store" do
      expect(subject.translations).to be_a(Decidim::TermCustomizer::TranslationStore)
    end
  end

  describe "#translations_search" do
    it "returns correct translations" do
      expect(subject.translations_search("term customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
      expect(subject.translations_search("term_customizer").length).to eq(75)
    end
  end

  describe "#translations_by_key" do
    it "does not return any translations for non matching keys" do
      expect(subject.translations_by_key("term customizer").length).to eq(0)
    end

    it "returns correct translations" do
      expect(subject.translations_by_key("term_customizer").length).to eq(75)
    end
  end

  describe "#translations_by_term" do
    it "does not return any translations for non matching terms" do
      expect(subject.translations_by_term("term_customizer").length).to eq(0)
    end

    it "returns correct translations" do
      expect(subject.translations_by_term("term customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
    end
  end
end
