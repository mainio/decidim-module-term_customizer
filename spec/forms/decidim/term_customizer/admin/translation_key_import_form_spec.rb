# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationKeyImportForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:translation_set) { create(:translation_set, organization:) }
        let(:keys) { ["first.key", "second.key", "third.key"] }
        let(:params) { { keys: } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization,
            translation_set:
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
