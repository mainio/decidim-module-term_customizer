# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # This command is executed when the user changes a translation set from
      # the admin panel.
      class UpdateTranslationSet < Rectify::Command
        # Initializes a UpdateTranslationSet Command.
        #
        # form - The form from which to get the data.
        # set  - The current instance of the translation set to be updated.
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
            update_translation_set!
          end

          broadcast(:ok, set)
        end

        private

        attr_reader :form, :set

        def update_translation_set!
          set.update!(name: form.name)

          # Update the constraints
          set.constraints.destroy_all
          form.constraints.each do |c|
            next if c.deleted

            attrs = { organization: form.current_organization }
            if c.subject
              attrs[:subject] = c.subject
            else
              attrs[:subject_type] = c.subject_type
            end

            set.constraints.create!(attrs)
          end

          if set.constraints.count < 1
            # Make sure that the organization constraint at least exists always
            set.constraints.create!(organization: form.current_organization)
          end
        end
      end
    end
  end
end
