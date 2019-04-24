# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class ExportJob < ApplicationJob
        queue_as :default

        def perform(user, set, name, format)
          export_data = Decidim::Exporters.find_exporter(format).new(
            set.translations, TranslationSerializer
          ).export

          ExportMailer.export(user, name, export_data).deliver_now
        end
      end
    end
  end
end
