# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::TermCustomizer

      initializer "decidim_term_customizer.setup" do
        customizer_backend = Decidim::TermCustomizer::I18nBackend.new
        I18n.backend = I18n::Backend::Chain.new(
          customizer_backend,
          I18n.backend
        )

        # Setup a controller hook to setup the term customizer before the
        # request is processed and the translations are printed out. This is
        # done through a notification to get access to the `current_*`
        # environment variables within Decidim.
        ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |_name, _started, _finished, _unique_id, data|
          env = data[:headers].env
          controller = data[:headers].env["action_controller.instance"]

          # E.g. at the participatory process controller the
          # `decidim.current_participatory_space` environment variable has not
          # been set. Therefore, we need to fetch it directly from the
          # controller using its private method.
          space =
            if controller.respond_to?(:current_participatory_space, true)
              controller.send(:current_participatory_space)
            else
              env["decidim.current_participatory_space"]
            end

          # Create a new resolver instance within the current request scope
          TermCustomizer.resolver = Resolver.new(
            env["decidim.current_organization"],
            space,
            env["decidim.current_component"]
          )

          # Force the backend to reload the translations for the current request
          customizer_backend.reload!
        end
      end
    end
  end
end
