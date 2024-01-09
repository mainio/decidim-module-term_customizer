# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::OrganizationTranslationSets do
  subject { described_class.new(organization) }

  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  let(:translation_set_list) { create_list(:translation_set, 10, organization:) }
  let(:other_translation_set_list) { create_list(:translation_set, 10, organization: other_organization) }

  it "returns translation sets included in an organization" do
    expect(subject).to match_array(translation_set_list)
  end
end
