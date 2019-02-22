# frozen_string_literal: true

RSpec.shared_context "with setup initializer" do
  before do
    # After the backend is restored,
    config = Decidim::TermCustomizer::Engine.initializers.find do |i|
      i.name == "decidim_term_customizer.setup"
    end
    config.run
  end
end
