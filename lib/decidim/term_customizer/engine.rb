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
          context = TermCustomizer.controller_context_class.new(data)

          # Create a new resolver instance within the current request scope
          resolver = Resolver.new(
            context.organization,
            context.space,
            context.component
          )

          # Create the loader for the backend to fetch the translations from
          TermCustomizer.loader = Loader.new(resolver)

          # Force the backend to reload the translations for the current request
          customizer_backend.reload!
        end

        # The jobs are generally run in different context than the controllers
        # which causes the term customizations not to be active. During the
        # jobs, only the organization and global context translations are loaded
        # because otherwise this would have to be job specific.
        #
        # Currently this has been only tested against the event notification
        # jobs but it may work for other jobs as well. Because the jobs
        # themselves don't carry any other context information than their
        # arguments, it is difficult to resolve their correct context. Note also
        # that e.g. the email notifications are always created through a single
        # job that may be fired by another job (i.e. the notification job is
        # always performed last).
        ActiveSupport::Notifications.subscribe "perform_start.active_job" do |_name, _started, _finished, _unique_id, data|
          context = TermCustomizer.job_context_class.new(data)

          # Create resolver for the target organization or global context in
          # case organization was not found
          resolver = Resolver.new(
            context.organization,
            context.space,
            context.component
          )

          # Create the loader for the backend to fetch the translations from
          TermCustomizer.loader = Loader.new(resolver)

          # Force the backend to reload the translations for the job
          customizer_backend.reload!
        end
      end
    end
  end
end
