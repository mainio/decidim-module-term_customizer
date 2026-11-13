# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::AdminEngine do
  let(:context_class) do
    Class.new do
      def initialize(&block)
        @block = block
      end

      def call(*)
        instance_exec(*, &@block)
      end

      def scope(*)
        yield
      end
    end
  end

  describe "#initialize decidim_term_customizer.admin_mount_routes" do
    it "mounts the routes" do
      expect(Decidim::Core::Engine).to receive(:routes) do |&block|
        context = context_class.new(&block)
        expect(context).to receive(:mount).with(
          described_class,
          at: "/admin/term_customizer",
          as: "decidim_admin_term_customizer"
        )

        context.call
      end

      run_initializer("decidim_term_customizer.admin_mount_routes")
    end
  end

  describe "#initialize decidim_term_customizer.admin_menu" do
    let(:menu) { double }
    let(:routes) { double }
    let(:path) { double }
    let(:organization) { double }
    let(:allowed_to_result) { double }

    it "adds the admin menu item" do
      expect(Decidim).to receive(:menu).with(:admin_menu) do |_name, &block|
        context = context_class.new(&block)
        allow(context).to receive_messages(decidim_admin_term_customizer: routes, current_organization: organization)
        allow(context).to receive(:allowed_to?).with(
          :update,
          :organization,
          organization:
        ).and_return(allowed_to_result)
        allow(routes).to receive(:translation_sets_path).and_return(path)
        expect(menu).to receive(:add_item).with(
          :term_customizer,
          "Term customizer",
          path,
          icon_name: "Decidim::TermCustomizer",
          position: 7.1,
          active: :inclusive,
          if: allowed_to_result
        )

        context.call(menu)
      end
      allow(Decidim).to receive(:menu).with(:term_customizer_translation_sets_menu)

      run_initializer("decidim_term_customizer.admin_menu")
    end

    it "adds the translation sets menu" do
      allow(Decidim).to receive(:menu).with(:admin_menu)
      expect(Decidim).to receive(:menu).with(:term_customizer_translation_sets_menu) do
        context = context_class.new(&block)
        translations_path = double
        add_translations_path = double
        allow(routes).to receive_messages(
          translation_set_translations_path: translations_path,
          translation_set_add_translations_path: add_translations_path
        )

        allow(context).to receive(:decidim_admin_term_customizer).and_return(routes)
        allow(context).to receive(:is_active_link?).with(translations_path).and_return(false)
        allow(context).to receive(:is_active_link?).with(add_translations_path).and_return(true)

        expect(menu).to receive(:add_item).with(
          :term_customizer_translation_sets,
          "Translation set",
          translations_path,
          active: true
        )

        context.call(menu)
      end

      run_initializer("decidim_term_customizer.admin_menu")
    end
  end

  def run_initializer(initializer_name)
    config = described_class.initializers.find do |i|
      i.name == initializer_name
    end
    config.run
  end
end
