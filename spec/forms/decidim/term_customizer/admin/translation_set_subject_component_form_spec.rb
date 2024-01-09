# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetSubjectComponentForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:space) { create(:participatory_process, organization:) }
        let(:component) { create(:proposal_component, participatory_space: space) }
        let(:subject_id) { space.id }
        let(:component_id) { component.id }
        let(:params) { { subject_id:, component_id: } }

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
