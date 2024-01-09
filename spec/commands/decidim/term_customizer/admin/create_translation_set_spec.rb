# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::CreateTranslationSet do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationSetForm }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  describe "call" do
    let(:space) { create(:participatory_process, organization:) }

    let(:form_params) do
      {
        name: { en: "Name of the set" },
        constraints: [
          {
            subject_manifest: "participatory_processes",
            subject_model: [
              {
                subject_manifest: "participatory_processes",
                subject_id: space.id
              }
            ]
          }
        ]
      }
    end

    let(:command) do
      described_class.new(form)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't add the translation set" do
        expect do
          command.call
        end.not_to change(Decidim::TermCustomizer::TranslationSet, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "adds the translation set" do
        expect do
          command.call
        end.to change(
          Decidim::TermCustomizer::TranslationSet, :count
        ).by(1).and change(
          Decidim::TermCustomizer::Constraint,
          :count
        ).by(1)
      end

      context "without any constraints" do
        let(:form_params) { { name: { en: "Name of the set" } } }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "automatically adds the organization constraint" do
          expect do
            command.call
          end.to change(
            Decidim::TermCustomizer::TranslationSet, :count
          ).by(1).and change(
            Decidim::TermCustomizer::Constraint,
            :count
          ).by(1)

          constraint = Decidim::TermCustomizer::Constraint.last
          expect(constraint.organization).to eq(organization)
          expect(constraint.subject).to be_nil
          expect(constraint.subject_type).to be_nil
        end
      end
    end
  end
end
