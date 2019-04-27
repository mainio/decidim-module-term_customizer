# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::CSV do
  let(:file) { file_fixture("set-translations.csv") }

  it_behaves_like "translation import reader"
end
