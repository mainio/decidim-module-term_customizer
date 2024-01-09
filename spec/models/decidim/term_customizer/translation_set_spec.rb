# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe TranslationSet do
      subject { translation_set }

      let(:organization) { create(:organization) }
      let(:translation_set) { create(:translation_set, organization:) }

      it { is_expected.to be_valid }

      it "is has a constraint associated with an organization" do
        expect(subject.constraints.first.organization).to eq(organization)
      end
    end
  end
end
