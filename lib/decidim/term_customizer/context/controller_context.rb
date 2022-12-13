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
          # controller using its private method. In some edge cases this may not
          # be implemented (https://github.com/mainio/decidim-module-term_customizer/issues/28)
          # in which case we do not have access to the participatory space.
          if controller.respond_to?(:current_participatory_space, true)
            begin
              @space = controller.send(:current_participatory_space)
            rescue ActiveRecord::RecordNotFound
              # In Decidim 0.27+ also consultations and initiatives implement
              # the `current_participatory_space` method but calling it on the
              # index action would cause an `ActiveRecord::RecordNotFound` which
              # would not happen when using these modules normally. Therefore,
              # we take this into account here.
            end
          end
          @space ||= env["decidim.current_participatory_space"]

          @component = env["decidim.current_component"]
        end
      end
    end
  end
end
