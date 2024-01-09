# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Constraint do
      subject { constraint }

      let(:organization) { create(:organization) }
      let(:constraint) { build(:translation_set_constraint, organization:) }

      it { is_expected.to be_valid }

      it "is associated with organization" do
        expect(subject.organization).to eq(organization)
      end
    end
  end
end
