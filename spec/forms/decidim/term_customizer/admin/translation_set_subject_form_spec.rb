# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetSubjectForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:subject_manifest) { :particpatory_process }
        let(:params) { { subject_manifest: } }

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
            let(:space) { create(:participatory_process, organization:) }

            it "maps the model" do
              subject.map_model(space)

              expect(subject.subject_manifest).to eq("participatory_processes")
              expect(subject.subject_id).to eq(space.id)
            end
          end
        end

        describe "#component" do
          let(:space) { create(:participatory_process, organization:) }
          let(:form_subject) { space }

          before do
            subject.map_model(form_subject)
          end

          context "with participatory space containing components" do
            let(:form_subject) { create(:proposal_component, participatory_space: space) }

            it "returns the correct component" do
              expect(subject.component).to eq(form_subject)
            end
          end

          context "with participatory space containing no components" do
            it "returns the correct component" do
              expect(subject.component).to be_nil
            end
          end
        end
      end
    end
  end
end
