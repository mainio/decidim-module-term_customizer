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
      expect(subject.translations_search("term_customizer").length).to eq(80)
    end
  end

  describe "#translations_by_key" do
    it "does not return any translations for non matching keys" do
      expect(subject.translations_by_key("term customizer").length).to eq(0)
    end

    it "returns correct translations" do
      expect(subject.translations_by_key("term_customizer").length).to eq(80)
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

  context "when using accented characters in the search" do
    it "returns correct translations when the search is case insensitive" do
      expect(subject.translations_search("térm custômizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
    end

    context "when the term contains accents" do
      let(:locale) { :ca }

      # rubocop:disable RSpec/SubjectStub
      before do
        allow(subject).to receive(:all_translations).and_return({
                                                                  en: {
                                                                    decidim: {
                                                                      term_customizer: {
                                                                        menu: {
                                                                          term_customizer: "Term custômizer"
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                })
      end

      it "returns correct translations when the search is case insensitive" do
        expect(subject.translations_search("térm customizer")).to eq(
          "decidim.term_customizer.menu.term_customizer" => "Term custômizer"
        )
      end
    end
  end

  context "when the locale is not present in the translations" do
    let(:locale) { :ca }

    before do
      allow(subject).to receive(:all_translations).and_return({
                                                                en: {
                                                                  decidim: {
                                                                    term_customizer: {
                                                                      menu: {
                                                                        term_customizer: "Term customizer"
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              })
    end
    # rubocop:enable RSpec/SubjectStub

    it "does not return any translations by key when using the secondary language backend" do
      expect(subject.translations.by_key("term_customizer")).to eq({})
    end

    it "returns translations by key when using the English source fallback" do
      expect(subject.canonical_source_terms.by_key("term_customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
    end

    it "still returns the correct translations by key globally" do
      expect(subject.translations_by_key("term_customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
    end

    it "does not return the correct translation by term" do
      expect(subject.translations_by_term("term customizer")).to eq({})
    end

    it "returns the correct translations by term globally with merged search" do
      expect(subject.translations_search("term customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Term customizer"
      )
    end
  end

  context "when the locale has translations for the same keys as the primary language" do
    let(:locale) { :ca }

    # rubocop:disable RSpec/SubjectStub
    before do
      allow(subject).to receive(:all_translations).and_return({
                                                                en: {
                                                                  decidim: {
                                                                    term_customizer: {
                                                                      menu: {
                                                                        term_customizer: "Term customizer",
                                                                        secondary_term: "Secondary term"
                                                                      }
                                                                    }
                                                                  }
                                                                },
                                                                ca: {
                                                                  decidim: {
                                                                    term_customizer: {
                                                                      menu: {
                                                                        term_customizer: "Personalitzador de termes"
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              })
    end
    # rubocop:enable RSpec/SubjectStub

    it "returns the localized value for overlapping keys and falls back to English for missing ones in key searches" do
      expect(subject.translations_by_key("menu.term_customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Personalitzador de termes"
      )

      expect(subject.translations_by_key("menu.secondary_term")).to eq(
        "decidim.term_customizer.menu.secondary_term" => "Secondary term"
      )
    end

    it "prefers the localized value and keeps English fallback when merging global search results" do
      expect(subject.translations_search("menu.term_customizer")).to eq(
        "decidim.term_customizer.menu.term_customizer" => "Personalitzador de termes"
      )

      expect(subject.translations_search("menu.secondary_term")).to eq(
        "decidim.term_customizer.menu.secondary_term" => "Secondary term"
      )
    end
  end
end
