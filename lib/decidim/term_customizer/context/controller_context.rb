# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Context
      class ControllerContext < Base
        def resolve!
          env = data[:headers].env
          controller = env["action_controller.instance"]

          @organization = env["decidim.current_organization"]

          # E.g. at the participatory process controller the
          # `decidim.current_participatory_space` environment variable has not
          # been set. Therefore, we need to fetch it directly from the
          # controller using its private method.
          @space =
            if controller.respond_to?(:current_participatory_space, true)
              controller.send(:current_participatory_space)
            else
              env["decidim.current_participatory_space"]
            end

          @component = env["decidim.current_component"]
        end
      end
    end
  end
end
