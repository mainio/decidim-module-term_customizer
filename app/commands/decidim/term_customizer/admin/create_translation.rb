# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when creating a new translation
      # set in the system.
      class CreateTranslation < Rectify::Command
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
          return broadcast(:invalid) if form.invalid?

          transaction do
            @translations = create_translations
            create_plural_forms(@translations)
          end

          if @translations.length.positive?
            broadcast(:ok, @translations)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_translations
          form.value.map do |locale, value|
            TermCustomizer::Translation.create!(
              translation_set: form.translation_set,
              key: form.key,
              value: value,
              locale: locale
            )
          end
        end
      end
    end
  end
end
