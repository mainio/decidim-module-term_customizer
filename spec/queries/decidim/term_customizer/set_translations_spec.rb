# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::SetTranslations do
  subject { described_class.new(translation_set) }

  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  let(:translation_set) { create(:translation_set, organization:) }
  let(:other_translation_set) { create(:translation, organization: other_organization) }

  let(:translations_list) { create_list(:translation, 10, translation_set:) }
  let(:other_translations_list) { create_list(:translation, 10, translation_set: other_translation_set) }

  it "returns translations included in a translation set" do
    expect(subject).to match_array(translations_list)
  end

  context "with locale" do
    subject { described_class.new(translation_set, locale) }

    let(:locale) { :en }
    let(:translations_list) { create_list(:translation, 10, translation_set:, locale:) }

    before do
      create_list(:translation, 10, translation_set:, locale: :fi)
    end

    it "returns translations included in a translation set with the given locale" do
      expect(subject).to match_array(translations_list)
    end
  end
end
