# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # This command is executed when the user duplicates a translation set from
      # the admin panel.
      class DuplicateTranslationSet < Rectify::Command
        # Initializes a DuplicateTranslationSet Command.
        #
        # form - A form object with the params.
        # set  - The instance of the translation set to be duplicated.
        def initialize(form, set)
          @form = form
          @set = set
        end

        # Updates the blog if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            duplicate_translation_set!
          end

          broadcast(:ok, set)
        end

        private

        attr_reader :form, :set

        def duplicate_translation_set!
          duplicated = TermCustomizer::TranslationSet.create!(name: form.name)

          # Add the constraints
          set.constraints.each do |c|
            duplicated.constraints.create!(
              organization: form.current_organization,
              subject: c.subject,
              subject_type: c.subject_type
            )
          end

          # Add the translations
          set.translations.each do |t|
            duplicated.translations.create!(
              locale: t.locale,
              key: t.key,
              value: t.value
            )
          end

          duplicated
        end
      end
    end
  end
end
