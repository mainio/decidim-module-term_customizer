# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from a participatory text.
      class TranslationsImportForm < Decidim::Form
        ACCEPTED_MIME_TYPES = Decidim::TermCustomizer::Import::Readers::ACCEPTED_MIME_TYPES
        MIME_TYPE_ZIP = "application/zip"

        mimic :translations_import

        attribute :file

        validates :file, presence: true
        validate :accepted_mime_type

        def file_path
          file&.path
        end

        def mime_type
          file&.content_type
        end

        def zip_file?
          mime_type == MIME_TYPE_ZIP
        end

        def accepted_mime_type
          accepted_mime_types = ACCEPTED_MIME_TYPES.values + [MIME_TYPE_ZIP]
          return if accepted_mime_types.include?(mime_type)

          errors.add(
            :file,
            I18n.t(
              "activemodel.errors.models.translations_import.attributes.file.invalid_mime_type",
              valid_mime_types: ACCEPTED_MIME_TYPES.keys.map do |m|
                I18n.t("decidim.term_customizer.admin.translations.new_import.accepted_mime_types.#{m}")
              end.join(", ")
            )
          )
        end
      end
    end
  end
end
