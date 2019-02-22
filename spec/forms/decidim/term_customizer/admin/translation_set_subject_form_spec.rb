# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetSubjectForm do
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

        describe "#map_model" do
          context "with participatory space" do
            let(:space) { create(:participatory_process, organization: organization) }

            it "maps the model" do
              subject.map_model(space)

              expect(subject.subject_manifest).to eq("participatory_processes")
              expect(subject.subject_id).to eq(space.id)
            end
          end
        end
      end
    end
  end
end
