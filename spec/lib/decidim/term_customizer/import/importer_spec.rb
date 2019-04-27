# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Importer do
  subject { described_class.new(file, reader, parser) }

  let(:parser) { Decidim::TermCustomizer::TranslationParser }

  context "with CSV" do
    let(:file) { file_fixture("set-translations.csv") }
    let(:reader) { Decidim::TermCustomizer::Import::Readers::CSV }

    it_behaves_like "translation importer"
  end

  context "with JSON" do
    let(:file) { file_fixture("set-translations.json") }
    let(:reader) { Decidim::TermCustomizer::Import::Readers::JSON }

    it_behaves_like "translation importer"
  end

  context "with XLS" do
    let(:file) { file_fixture("set-translations.xls") }
    let(:reader) { Decidim::TermCustomizer::Import::Readers::XLS }

    it_behaves_like "translation importer"
  end
end
