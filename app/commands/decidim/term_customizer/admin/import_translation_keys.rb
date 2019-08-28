# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when creating new translations
      # from the keys submitted through the form.
      class ImportTranslationKeys < Rectify::Command
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
          items = form.keys.map do |key|
            form.current_organization.available_locales.map do |locale|
              attrs = {
                key: key,
                locale: locale
              }
              next unless form.translation_set.translations.find_by(attrs).nil?

              attrs.merge(value: I18n.t(key, locale: locale, default: ""))
            end
          end.flatten

          form.translation_set.translations.create!(items)
        end
      end
    end
  end
end
