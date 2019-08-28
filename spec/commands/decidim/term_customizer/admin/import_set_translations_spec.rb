# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::ImportSetTranslations do
  let(:form_klass) { Decidim::TermCustomizer::Admin::TranslationsImportForm }

  let(:locales) { [:en, :fi] }
  let(:organization) { create(:organization, available_locales: locales) }
  let(:translation_set) { create(:translation_set, organization: organization) }
  let(:file) { nil }
  let(:form_params) { { file: file } }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end

  before do
    I18n.available_locales = locales
  end

  describe "call" do
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

      it "doesn't add the translations" do
        expect do
          command.call
        end.not_to change(Decidim::TermCustomizer::Translation, :count)
      end
    end

    describe "when the form is valid" do
      shared_examples "functional translation import" do
        include_context "with translation import data"

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "adds the translations" do
          # NOTE:
          # The source translations only include the `:one` key for:
          # activerecord.models.decidim/participatory_process_group
          # The `:other` plural form key is also added for this translation
          # automatically by the PluralFormsManager which increases the amount
          # of added translations to 8 (import file only includes 6).
          expect do
            command.call
          end.to change(
            Decidim::TermCustomizer::Translation, :count
          ).by(8)

          expected_data.each do |data|
            tr = translation_set.translations.find_by(
              locale: data[:locale],
              key: data[:key]
            )
            expect(tr).to be_a(Decidim::TermCustomizer::Translation)
            expect(tr.value).to eq(data[:value])
          end
        end
      end

      context "with CSV import file" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.csv"),
            "text/csv"
          )
        end

        it_behaves_like "functional translation import"
      end

      context "with JSON import file" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.json"),
            "application/json"
          )
        end

        it_behaves_like "functional translation import"
      end

      context "with XLS import file" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.xls"),
            "application/vnd.ms-excel"
          )
        end

        it_behaves_like "functional translation import"
      end

      context "with ZIP import file containing a CSV" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.csv.zip"),
            "application/zip"
          )
        end

        it_behaves_like "functional translation import"
      end

      context "with ZIP import file containing a JSON" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.json.zip"),
            "application/zip"
          )
        end

        it_behaves_like "functional translation import"
      end

      context "with ZIP import file containing a XLS" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.xls.zip"),
            "application/zip"
          )
        end

        it_behaves_like "functional translation import"
      end
    end
  end
end
