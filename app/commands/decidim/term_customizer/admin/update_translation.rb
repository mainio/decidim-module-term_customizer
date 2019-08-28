# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # This command is executed when the user changes a translation from the
      # admin panel.
      class UpdateTranslation < Rectify::Command
        include TermCustomizer::PluralFormsForm

        # Public: Initializes the command.
        #
        # form        - A form object with the params.
        # translation - The current instance of the translation to be updated.
        def initialize(form, translation)
          @form = form
          @translation = translation
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            @translations = update_translations!
            create_plural_forms(@translations)
          end

          broadcast(:ok, translation)
        end

        private

        attr_reader :form, :translation

        def update_translations!
          form.value.map do |locale, value|
            l_translation = TermCustomizer::Translation.find_by(
              translation_set: translation.translation_set,
              key: translation.key,
              locale: locale
            )

            if l_translation
              l_translation.update!(
                key: form.key,
                value: value,
                locale: locale
              )
            else
              l_translation = TermCustomizer::Translation.create!(
                translation_set: translation.translation_set,
                key: form.key,
                value: value,
                locale: locale
              )
            end

            l_translation
          end
        end
      end
    end
  end
end
