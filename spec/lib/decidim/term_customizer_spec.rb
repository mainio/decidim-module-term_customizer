# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer do
  describe "#manifests" do
    it "returns the expected manifests" do
      expect(Decidim::TermCustomizer.manifests.size).to equal(Decidim.participatory_space_manifests.size + 1)
      expect(Decidim::TermCustomizer.manifests).to include(Decidim.find_resource_manifest(:participatory_process_group))
    end
  end
end
