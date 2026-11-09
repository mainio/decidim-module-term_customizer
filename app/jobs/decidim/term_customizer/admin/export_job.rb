# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class ExportJob < ApplicationJob
        include Decidim::PrivateDownloadHelper

        queue_as :default

        def perform(user, set, name, format)
          export_data = Decidim::Exporters.find_exporter(format).new(
            set.translations, TranslationSerializer
          ).export

          private_export = attach_archive(export_data, name, user)

          ExportMailer.export(user, private_export).deliver_now
        end
      end
    end
  end
end
