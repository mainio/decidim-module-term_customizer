# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::TranslationsHelper do
  describe "#mime_types" do
    before do
      allow(helper).to receive(:t).with(
        ".accepted_mime_types.json"
      ).and_return("JSON")
      allow(helper).to receive(:t).with(
        ".accepted_mime_types.csv"
      ).and_return("CSV")
      allow(helper).to receive(:t).with(
        ".accepted_mime_types.xls"
      ).and_return("XLS")
    end

    it "returns the expected mime types" do
      expect(helper.mime_types).to eq("JSON, CSV, XLS")
    end
  end
end
