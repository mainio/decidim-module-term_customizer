# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::ImportTranslationKeys do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationKeyImportForm }

  let(:organization) { create(:organization) }
  let(:translation_set) { create(:translation_set, organization: organization) }
  let(:keys) do
    [
      "decidim.admin.actions.new_translation",
      "decidim.term_customizer.admin.translation_sets.constraint_fields.remove",
      "decidim.term_customizer.menu.term_customizer",
      "unexisting.key"
    ]
  end
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      translation_set: translation_set
    )
  end

  describe "call" do
    let(:form_params) { { keys: keys } }

    let(:command) do
      described_class.new(form)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't add the translation" do
        expect do
          command.call
        end.not_to change(Decidim::TermCustomizer::Translation, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "adds the translation" do
        expect do
          command.call
        end.to change(
          Decidim::TermCustomizer::Translation, :count
        ).by(12)

        keys.each do |key|
          expect(
            Decidim::TermCustomizer::Translation.where(key: key).count
          ).to eq(3)
        end
      end
    end

    context "when the key exists in another translation set" do
      let!(:translation_set_2) do
        create(:translation_set, organization: organization)
      end
      let(:key) { "decidim.admin.actions.new_translation" }
      let!(:translation) do
        create(
          :translation,
          translation_set: translation_set_2,
          locale: :en,
          key: key
        )
      end

      it "adds the translation" do
        command.call

        expect(
          Decidim::TermCustomizer::Translation.where(key: key).count
        ).to eq(4)
      end
    end

    context "and the passed keys have plural forms" do
      let(:keys) do
        ["test.plural.one"]
      end

      it "adds the translation and its plural forms" do
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
