# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A command with all the business logic when creating a new translation
      # set in the system.
      class CreateTranslationSet < Rectify::Command
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
            @set = create_translation_set!
          end

          if @set.persisted?
            broadcast(:ok, @set)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def create_translation_set!
          translation_set = TermCustomizer::TranslationSet.create!(
            name: form.name
          )

          form.constraints.each do |c|
            next if c.deleted

            attrs = { organization: form.current_organization }
            if c.subject
              attrs[:subject] = c.subject
            else
              attrs[:subject_type] = c.subject_type
            end

            translation_set.constraints.create!(attrs)
          end

          translation_set
        end
      end
    end
  end
end
