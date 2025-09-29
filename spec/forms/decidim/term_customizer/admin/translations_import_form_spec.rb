# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationsImportForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:file) do
          upload_test_file(
            Rack::Test::UploadedFile.new(
              file_fixture("set-translations.json"),
              "application/json"
            )
          )
        end
        let(:params) { { file: } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        describe "#mime_type" do
          it { expect(subject.mime_type).to eq("application/json") }
        end

        describe "#zip_file?" do
          context "when non-zip file is provided" do
            it { expect(subject.zip_file?).to be(false) }
          end

          context "when zip file is provided" do
            let(:file) do
              upload_test_file(
                Rack::Test::UploadedFile.new(
                  file_fixture("set-translations.json.zip"),
                  "application/zip"
                )
              )
            end

            it { expect(subject.zip_file?).to be(true) }
          end
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when no file is provided" do
          let(:file) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when invalid file type is provided" do
          let(:file) do
            upload_test_file(
              Rack::Test::UploadedFile.new(
                file_fixture("set-translations.txt"),
                "text/plain"
              )
            )
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
