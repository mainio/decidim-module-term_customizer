# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    module Admin
      describe ExportJob do
        let(:organization) { create(:organization) }
        let!(:translation_set) { create(:translation_set, organization:) }
        let!(:user) { create(:user, organization:) }

        before do
          # Unsubscribe from the active job notification in order to avoid the
          # "leaked" doubles error from rspec-mocks.
          ActiveSupport::Notifications.unsubscribe(
            "perform_start.active_job"
          )
        end

        it "sends an email with a link to the result of the export" do
          ExportJob.perform_now(user, translation_set, "dummies", "CSV")

          email = last_email
          expect(email.subject).to include("dummies")
          expect(email.body.encoded).to include("download_your_data")
          expect(email.body.encoded).to include("Your download is ready")
        end

        describe "CSV" do
          it "uses the CSV exporter" do
            export_data = double

            expect(Decidim::Exporters::CSV)
              .to(receive(:new).with(anything, TranslationSerializer))
              .and_return(double(export: export_data))

            expect(ExportMailer)
              .to(receive(:export).with(user, anything, export_data))
              .and_return(double(deliver_now: true))

            ExportJob.perform_now(user, translation_set, "dummies", "CSV")
          end
        end

        describe "JSON" do
          it "uses the JSON exporter" do
            export_data = double

            expect(Decidim::Exporters::JSON)
              .to(receive(:new).with(anything, TranslationSerializer))
              .and_return(double(export: export_data))

            expect(ExportMailer)
              .to(receive(:export).with(user, anything, export_data))
              .and_return(double(deliver_now: true))

            ExportJob.perform_now(user, translation_set, "dummies", "JSON")
          end
        end
      end
    end
  end
end
