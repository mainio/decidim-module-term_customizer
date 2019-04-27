# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe TranslationsImportForm do
        subject { form }

        let(:organization) { create(:organization) }
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.json"),
            "application/json"
          )
        end
        let(:params) { { file: file } }

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        describe "#file_path" do
          it { expect(subject.file_path).to eq(file.path) }
        end

        describe "#mime_type" do
          it { expect(subject.mime_type).to eq(file.content_type) }
        end

        describe "#zip_file?" do
          context "when non-zip file is provided" do
            it { expect(subject.zip_file?).to be(false) }
          end

          context "when zip file is provided" do
            let(:file) do
              fixture_file_upload(
                file_fixture("set-translations.json.zip"),
                "application/zip"
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
            fixture_file_upload(
              file_fixture("set-translations.json"),
              "text/plain"
            )
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
