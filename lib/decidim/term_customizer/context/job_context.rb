# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Context
      class JobContext < Base
        def resolve!
          # Figure out the organization and user through the job arguments if
          # passed for the job.
          user = nil
          data[:job].arguments.each do |arg|
            @organization ||= organization_from_argument(arg)
            @space ||= space_from_argument(arg)
            @component ||= component_from_argument(arg)
            user ||= arg if arg.is_a?(Decidim::User)
          end

          # In case a component was found, define the space as the component
          # space to avoid any conflicts.
          @space = component.participatory_space if component

          # In case a space was found, define the organization as the space
          # organization to avoid any conflicts.
          @organization = space.organization if space

          # In case an organization could not be resolved any other way, check
          # it through the user (if the user was passed).
          @organization ||= user.organization if user
        end

        protected

        def organization_from_argument(arg)
          return arg if arg.is_a?(Decidim::Organization)

          arg.organization if arg.respond_to?(:organization)
        end

        def space_from_argument(arg)
          return arg if arg.is_a?(Decidim::Participable)

          arg.participatory_space if arg.respond_to?(:participatory_space)
        end

        def component_from_argument(arg)
          return arg if arg.is_a?(Decidim::Component)

          arg.component if arg.respond_to?(:component)
        end
      end
    end
  end
end
