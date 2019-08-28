# frozen_string_literal: true

require "zip"

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when importing translations to a
      # set from a file submitted through the form. The file may be one of the
      # supported import formats or a ZIP file containing a supported import
      # file.
      class ImportSetTranslations < Rectify::Command
        include TermCustomizer::PluralFormsForm

        # Public: Initializes the command.
        #
        # form            - A form object with the params.
        # translation_set - The translation set to which the import is
        #                   performed.
        def initialize(form, translation_set)
          @form = form
          @translation_set = translation_set
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          @translations = import_translations
          create_plural_forms(@translations)

          if @translations.length.positive?
            broadcast(:ok, @translations)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :translation_set

        # Private: Handles the import of either a zip file or a regular import
        # file, one of the supported reader formats based on the file provided
        # by the import form.
        #
        # Returns Array or nil. The returned value is an array of the imported
        # translations when the import is successful, otherwise nil.
        def import_translations
          return import_zip(form.file_path) if form.zip_file?

          import_file(form.file_path, form.mime_type)
        end

        # Private: Handles the import of a regular import file, one of the
        # supported reader formats. Will iterate over the whole imported data
        # array and save all records to the database.
        #
        # filepath  - A filepath with the data to be imported.
        # mime_type - The mime type of the provided file.
        #
        # Returns Array or nil. The returned value is an array of the imported
        # translations when the import is successful, otherwise nil.
        def import_file(filepath, mime_type)
          importer_for(filepath, mime_type).import do |records|
            import = TranslationImportCollection.new(
              translation_set,
              records,
              form.current_organization.available_locales
            )

            return translation_set.translations.create(import.import_attributes)
          end

          nil
        end

        # Private: Parses through the provided zip file and searches for the
        # first file with one of the supported import formats. Once found,
        # creates an extracted temp file of that file and passes that back to
        # the import method for the final import to be executed on.
        #
        # If no supported import file is found at the root of the zip archive,
        # nothing will be done and false will be returned.
        #
        # filepath - A filepath with the zip file containing the actual import
        #            file.
        #
        # Returns Array or nil. The returned value is an array of the imported
        # translations when the import is successful, otherwise nil.
        def import_zip(filepath)
          Zip::File.open(filepath) do |zip_file|
            zip_file.each do |entry|
              next unless entry.file?

              ext = File.extname(entry.name)[1..-1]
              mime_type = TranslationsImportForm::ACCEPTED_MIME_TYPES[ext.to_sym]
              next if mime_type.nil?

              collection = nil

              file = Tempfile.new("translations_import.#{ext}")
              begin
                content = entry.get_input_stream.read.force_encoding("UTF-8")
                file.write(content)
                file.close

                collection = import_file(file.path, mime_type)
              ensure
                file.unlink
              end

              return collection
            end
          end

          nil
        end

        # Private: Creates a new imported for the provided file with the given
        # mime type.
        #
        # filepath  - A filepath with the data to be imported.
        # mime_type - The mime type of the provided file.
        #
        # Returns Decidim::TermCustomizer::Import::Importer.
        def importer_for(filepath, mime_type)
          Import::ImporterFactory.build(
            filepath,
            mime_type,
            TranslationParser
          )
        end
      end
    end
  end
end
