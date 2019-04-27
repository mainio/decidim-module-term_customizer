# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::JSON do
  let(:file) { file_fixture("set-translations.json") }

  it_behaves_like "translation import reader"
end
