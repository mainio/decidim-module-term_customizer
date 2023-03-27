# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Context
      # A context object resolves and stores the translation context for
      # different application contexts. Contexts can be e.g.
      # - Controller context, which is used to display translations in
      #   controller messages and the views.
      # - Job context, which is used to display messages within jobs, mainly
      #   when sending emails.
      #
      # The initialization method gets the data for the context which is used
      # to resolve the translation context objects (organization, participatory
      # space and component). These are then used to load the correct
      # translations for each context based on the translation set constraints.
      class Base
        attr_reader :organization, :space, :component

        def initialize(data)
          @data = data

          # Implement the resolve! method in the sub-classes
          resolve!
        end

        protected

        attr_reader :data
      end
    end
  end
end
