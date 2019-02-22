# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetConstraintForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:subject_manifest) { :particpatory_process }
        let(:params) { { subject_manifest: subject_manifest } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end
      end
    end
  end
end
