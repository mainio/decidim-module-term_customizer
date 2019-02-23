# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when creating new translations
      # from the keys submitted through the form.
      class ImportTranslationKeys < Rectify::Command
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
          form.keys.each do |key|
            form.current_organization.available_locales.each do |locale|
              attrs = {
                translation_set: form.translation_set,
                key: key,
                locale: locale
              }
              next unless TermCustomizer::Translation.find_by(attrs).nil?

              TermCustomizer::Translation.create!(
                attrs.merge(value: I18n.t(key, locale: locale, default: ""))
              )
            end
          end.flatten
        end
      end
    end
  end
end
