# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app"

# Run all tests, include all
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Run both by default
task default: [:spec]
