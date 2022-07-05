# frozen_string_literal: true

# Base path of the module
base_path = File.expand_path("..", __dir__)

# Register an additional load path for webpack
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Entrypoints for the module
Decidim::Webpacker.register_entrypoints(
  decidim_term_customizer_admin: "#{base_path}/app/packs/entrypoints/decidim_term_customizer_admin.js"
)

# Stylesheet imports for admin panel
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/term_customizer/admin", group: :admin)
