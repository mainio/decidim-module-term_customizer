# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::DestroyTranslations do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationsDestroyForm }

  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user,
      translation_set: translation_set
    )
  end

  let!(:translation_set) { create(:translation_set) }
  let!(:translations) do
    create_list(:translation, 10, translation_set: translation_set)
  end

  describe "call" do
    let(:form_params) do
      {
        translation_ids: translations.map(&:id)
      }
    end

    let(:command) do
      described_class.new(form)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't destroy the translation" do
        expect do
          command.call
        end.not_to change(Decidim::TermCustomizer::Translation, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "destroys the translation" do
        expect do
          command.call
        end.to change(
          Decidim::TermCustomizer::Translation, :count
        ).by(-10)
      end

      context "and the passed translations have plural forms" do
        let!(:translations) do
          [
            create(
              :translation,
              translation_set: translation_set,
              key: "test.plural.one"
            )
          ]
        end

        before do
          # Add a plural form that should also get destroyed
          create(
            :translation,
            translation_set: translation_set,
            key: "test.plural.other"
          )
        end

        it "destroys the translation and its plural forms" do
          expect do
            command.call
          end.to change(
            Decidim::TermCustomizer::Translation, :count
          ).by(-2)
        end
      end
    end
  end
end
