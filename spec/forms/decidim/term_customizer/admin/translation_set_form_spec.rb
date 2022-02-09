# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:name) { Decidim::Faker::Localized.sentence(word_count: 3) }
        let(:params) { { name: name } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the name is not defined" do
          let(:name) { nil }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
