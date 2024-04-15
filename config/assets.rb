# frozen_string_literal: true

# Base path of the module
base_path = File.expand_path("..", __dir__)

# Register an additional load path for webpack
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Entrypoints for the module
Decidim::Webpacker.register_entrypoints(
  decidim_term_customizer_admin_autocomplete:
    "#{base_path}/app/packs/entrypoints/decidim_term_customizer_admin_autocomplete.js",
  decidim_term_customizer_admin_sets: "#{base_path}/app/packs/entrypoints/decidim_term_customizer_admin_sets.js",
  decidim_term_customizer_admin_bulk: "#{base_path}/app/packs/entrypoints/decidim_term_customizer_admin_bulk.js"
)

# Stylesheet imports for admin panel
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/term_customizer/admin", group: :admin)
