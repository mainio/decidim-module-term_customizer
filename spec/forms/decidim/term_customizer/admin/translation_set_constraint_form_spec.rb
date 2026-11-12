# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationSetConstraintForm do
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

        describe "#to_param" do
          subject { described_class.new(id:) }

          context "with actual ID" do
            let(:id) { double }

            it "returns the ID" do
              expect(subject.to_param).to be(id)
            end
          end

          context "with nil ID" do
            let(:id) { nil }

            it "returns the ID placeholder" do
              expect(subject.to_param).to eq("constraint-id")
            end
          end

          context "with empty ID" do
            let(:id) { "" }

            it "returns the ID placeholder" do
              expect(subject.to_param).to eq("constraint-id")
            end
          end
        end
      end
    end
  end
end
