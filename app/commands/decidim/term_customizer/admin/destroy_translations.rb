# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when an admin destroys
      # translations from a translation set.
      class DestroyTranslations < Rectify::Command
        include TermCustomizer::PluralFormsForm

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          destroy_plural_forms(form.translations)
          destroy_translations

          broadcast(:ok)
        end

        private

        attr_reader :form

        def destroy_translations
          form.translations.destroy_all
        end
      end
    end
  end
end
