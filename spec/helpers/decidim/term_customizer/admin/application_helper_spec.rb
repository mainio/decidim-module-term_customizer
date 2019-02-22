# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::ApplicationHelper do
  describe "#tabs_id_for_constraint" do
    let(:constraint) { double }

    it "returns the expected id" do
      expect(constraint).to receive(:to_param).and_return("test")
      expect(helper.tabs_id_for_constraint(constraint)).to eq("constraint_test")
    end
  end
end
