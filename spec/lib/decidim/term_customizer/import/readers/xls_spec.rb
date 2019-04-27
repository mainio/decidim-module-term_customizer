# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::Readers::XLS do
  let(:file) { file_fixture("set-translations.xls") }

  it_behaves_like "translation import reader"
end
