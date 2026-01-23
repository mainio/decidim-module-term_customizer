# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::TranslationParser do
  subject { described_class.new(data) }

  let(:data) do
    {
      :id => 123,
      "id" => 456,
      :locale => "en",
      :key => "translation.key",
      :value => "Term"
    }
  end

  it "removes the IDs from the hash" do
    expect(subject.instance_variable_get(:@data)).to eq(
      locale: "en",
      key: "translation.key",
      value: "Term"
    )
  end

  describe "#resource_klass" do
    it "returns the correct class" do
      expect(described_class.resource_klass).to be(
        Decidim::TermCustomizer::Translation
      )
    end
  end

  describe "#resource_attributes" do
    it "returns the attributes hash" do
      expect(subject.resource_attributes).to eq(
        locale: "en",
        key: "translation.key",
        value: "Term"
      )
    end
  end

  describe "#parse" do
    it "initializes a new Translation record" do
      record = subject.parse

      expect(record).to be_a_new(Decidim::TermCustomizer::Translation)
      expect(record.locale).to eq("en")
      expect(record.key).to eq("translation.key")
      expect(record.value).to eq("Term")
    end
  end
end
