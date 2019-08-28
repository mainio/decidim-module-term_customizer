# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::DuplicateTranslationSet do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationSetForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end
  let!(:translation_set) { create :translation_set }

  describe "call" do
    let(:space) { create(:participatory_process, organization: organization) }

    let(:form_params) { { name: { en: "Name of the set" } } }

    let(:command) do
      described_class.new(form, translation_set)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
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
      before do
        translation_set.constraints.create!(
          organization: organization
        )
        translation_set.constraints.create!(
          organization: organization,
          subject_type: "Decidim::ParticipatoryProcess",
          subject: space
        )
        translation_set.constraints.create!(
          organization: organization,
          subject_type: "Decidim::Assembly"
        )

        translation_set.translations.create!(
          locale: "en",
          key: "test.key",
          value: "Value"
        )
        translation_set.translations.create!(
          locale: "en",
          key: "other.key",
          value: "Other value"
        )
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "duplicates the translation set" do
        expect do
          command.call
        end.to change(
          Decidim::TermCustomizer::TranslationSet, :count
        ).by(1).and change(
          Decidim::TermCustomizer::Constraint,
          :count
        ).by(3).and change(
          Decidim::TermCustomizer::Translation,
          :count
        ).by(2)

        constraints = translation_set.constraints.all
        expect(constraints[0].organization).to eq(organization)
        expect(constraints[0].subject).to be_nil
        expect(constraints[0].subject_type).to be_nil
        expect(constraints[1].organization).to eq(organization)
        expect(constraints[1].subject.id).to eq(space.id)
        expect(constraints[1].subject_type).to eq("Decidim::ParticipatoryProcess")
        expect(constraints[2].organization).to eq(organization)
        expect(constraints[2].subject).to be_nil
        expect(constraints[2].subject_type).to eq("Decidim::Assembly")

        translations = translation_set.translations.all
        expect(translations[0].locale).to eq("en")
        expect(translations[0].key).to eq("test.key")
        expect(translations[0].value).to eq("Value")
        expect(translations[1].locale).to eq("en")
        expect(translations[1].key).to eq("other.key")
        expect(translations[1].value).to eq("Other value")
      end
    end
  end
end
