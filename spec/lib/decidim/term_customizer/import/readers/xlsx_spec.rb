# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::XLSX do
  let(:file) { file_fixture("set-translations.xlsx") }

  it_behaves_like "translation import reader"

  context "with xlsx files containing nils in header" do
    let(:file) { file_fixture("set-translations-with-nils.xlsx") }

  it_behaves_like "translation import reader"
  end
end
