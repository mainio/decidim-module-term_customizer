# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::UpdateTranslation do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationForm }

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

  let!(:translation) { create :translation, locale: :en, value: "Original value" }

  describe "call" do
    let(:space) { create(:participatory_process, organization: organization) }

    let(:form_params) do
      {
        key: "key.of.translation",
        value: {
          en: "English value",
          fi: "Suomenkielinen arvo",
          sv: "Svenska värdet"
        }
      }
    end

    let(:command) do
      described_class.new(form, translation)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the translation" do
        expect do
          command.call
        end.not_to change(translation, :key)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the translation" do
        expect do
          command.call
        end.to change(
          Decidim::TermCustomizer::Translation,
          :count
        ).by(2)

        expect(Decidim::TermCustomizer::Translation.where(
          locale: translation.locale,
          key: translation.key
        ).count).to be(0)
        expect(Decidim::TermCustomizer::Translation.where(
          key: form_params[:key]
        ).count).to be(3)
      end

      context "and the updated key has plural forms" do
        let(:form_params) do
          {
            key: "test.plural.one",
            value: {
              en: "English value",
              fi: "Suomenkielinen arvo",
              sv: "Svenska värdet"
            }
          }
        end

        it "updates the translation and adds its plural forms" do
          command.call

          expect(Decidim::TermCustomizer::Translation.where(
            key: "test.plural.zero"
          ).count).to eq(3)
          expect(Decidim::TermCustomizer::Translation.where(
            key: "test.plural.one"
          ).count).to eq(3)
          expect(Decidim::TermCustomizer::Translation.where(
            key: "test.plural.other"
          ).count).to eq(3)
        end
      end
    end
  end
end
