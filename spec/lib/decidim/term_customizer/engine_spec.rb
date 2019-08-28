# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Engine do
  before do
    ActiveSupport::Notifications.unsubscribe(
      "start_processing.action_controller"
    )
    ActiveSupport::Notifications.unsubscribe(
      "perform_start.active_job"
    )
  end

  it "sets up term customizer i18n backend during initialization" do
    expect(Decidim::TermCustomizer::I18nBackend).to receive(:new).and_call_original

    run_initializer

    expect(I18n.backend).to be_a(I18n::Backend::Chain)
    expect(I18n.backend.backends).to include(Decidim::TermCustomizer::I18nBackend)
  end

  context "when instrumenting the start_processing.action_controller notification" do
    let(:dummy_backend) { double }
    let(:dummy_data) { { headers: dummy_data_headers } }
    let(:dummy_data_headers) { double }
    let(:dummy_organization) { double }
    let(:dummy_space) { double }
    let(:dummy_component) { double }
    let(:dummy_env) do
      {
        "decidim.current_organization" => dummy_organization,
        "decidim.current_participatory_space" => dummy_space,
        "decidim.current_component" => dummy_component
      }
    end
    let(:resolver) { double }

    before do
      expect(Decidim::TermCustomizer::I18nBackend).to receive(:new).and_return(dummy_backend)

      run_initializer

      expect(dummy_data_headers).to receive(:env).and_return(dummy_env)
    end

    it "calls the subscribed block set during initialization" do
      expect(Decidim::TermCustomizer::Resolver).to receive(:new).with(
        dummy_organization,
        dummy_space,
        dummy_component
      ).and_return(resolver)
      expect(Decidim::TermCustomizer::Loader).to receive(:new).with(resolver)
      expect(dummy_backend).to receive(:reload!)

      ActiveSupport::Notifications.instrument(
        "start_processing.action_controller",
        dummy_data
      )
    end

    context "with controller defining the space" do
      let(:controller) { double }
      let(:controller_space) { double }
      let(:dummy_env) do
        {
          "decidim.current_organization" => dummy_organization,
          "decidim.current_participatory_space" => dummy_space,
          "decidim.current_component" => dummy_component,
          "action_controller.instance" => controller
        }
      end

      it "fetches the space from the controller" do
        expect(controller).to receive(:current_participatory_space).and_return(controller_space)

        expect(Decidim::TermCustomizer::Resolver).to receive(:new).with(
          dummy_organization,
          controller_space,
          dummy_component
        ).and_return(resolver)
        expect(Decidim::TermCustomizer::Loader).to receive(:new).with(resolver)
        expect(dummy_backend).to receive(:reload!)

        ActiveSupport::Notifications.instrument(
          "start_processing.action_controller",
          dummy_data
        )
      end
    end
  end

  context "when instrumenting the perform_start.active_job notification" do
    let(:dummy_job) { double }
    let(:dummy_data) { { job: dummy_job } }
    let(:dummy_backend) { double }
    let(:arguments) { [] }
    let(:resolver) { double }

    before do
      allow(dummy_job).to receive(:job_id).and_return(1)
      allow(dummy_job).to receive(:queue_name).and_return("queue")
      allow(dummy_job).to receive(:arguments).and_return(arguments)

      expect(Decidim::TermCustomizer::I18nBackend).to receive(:new).and_return(dummy_backend)

      run_initializer

      expect(dummy_job).to receive(:arguments).and_return(arguments)
    end

    context "with organization in the arguments" do
      let(:organization) { create(:organization) }
      let(:arguments) { [organization] }

      it "creates a resolver with the organization" do
        expect(Decidim::TermCustomizer::Resolver).to receive(:new).with(
          organization,
          nil,
          nil
        ).and_return(resolver)
        expect(Decidim::TermCustomizer::Loader).to receive(:new).with(resolver)
        expect(dummy_backend).to receive(:reload!)

        ActiveSupport::Notifications.instrument(
          "perform_start.active_job",
          dummy_data
        )
      end
    end

    context "with user in the arguments" do
      let(:user) { create(:user) }
      let(:arguments) { [user] }

      it "creates a resolver with the user's organization" do
        expect(Decidim::TermCustomizer::Resolver).to receive(:new).with(
          user.organization,
          nil,
          nil
        ).and_return(resolver)
        expect(Decidim::TermCustomizer::Loader).to receive(:new).with(resolver)
        expect(dummy_backend).to receive(:reload!)

        ActiveSupport::Notifications.instrument(
          "perform_start.active_job",
          dummy_data
        )
      end
    end

    context "with user and organization in the arguments" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user) }
      let(:arguments) { [organization, user] }

      it "creates a resolver with the organization" do
        expect(Decidim::TermCustomizer::Resolver).to receive(:new).with(
          organization,
          nil,
          nil
        ).and_return(resolver)
        expect(Decidim::TermCustomizer::Loader).to receive(:new).with(resolver)
        expect(dummy_backend).to receive(:reload!)

        ActiveSupport::Notifications.instrument(
          "perform_start.active_job",
          dummy_data
        )
      end
    end
  end

  def run_initializer
    config = described_class.initializers.find do |i|
      i.name == "decidim_term_customizer.setup"
    end
    config.run
  end
end
