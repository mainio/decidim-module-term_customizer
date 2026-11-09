# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::CSV do
  context "when Decidim.default_csv_col_sep is `;`" do
    let(:file) { file_fixture("set-translations.csv") }

    it_behaves_like "translation import reader"
  end

  context "when Decidim.default_csv_col_sep is `,`" do
    let(:file) { file_fixture("set-translations-comma.csv") }

    around do |example|
      original_csv_col_sep = Decidim.default_csv_col_sep
      Decidim.default_csv_col_sep = ","
      example.run
      Decidim.default_csv_col_sep = original_csv_col_sep
    end

    it_behaves_like "translation import reader"
  end
end
