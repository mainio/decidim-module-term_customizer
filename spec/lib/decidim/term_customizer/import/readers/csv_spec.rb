# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::CSV do
  context "without Decidim::TermCustomizer.csv_col_sep defined" do
    let(:file) { file_fixture("set-translations.csv") }

    it_behaves_like "translation import reader"
  end

  context "with Decidim::TermCustomizer.csv_col_sep defined" do
    let(:file) { file_fixture("set-translations-comma.csv") }

    around do |example|
      original_csv_col_sep = Decidim::TermCustomizer.csv_col_sep
      Decidim::TermCustomizer.csv_col_sep = ","
      example.run
      Decidim::TermCustomizer.csv_col_sep = original_csv_col_sep
    end

    it_behaves_like "translation import reader"
  end
end
