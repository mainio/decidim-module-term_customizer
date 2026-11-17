# frozen_string_literal: true

shared_context "with custom available locales" do
  # Certain order of running specs could cause problems because of
  # plural_forms_manager_spec and import_set_translations_spec changing
  # available locales

  around do |example|
    original = I18n.available_locales

    example.run
  ensure
    I18n.available_locales = original

    # The backend loads translations lazily for the locales available at that
    # moment, so reload it to load the default locales again
    I18n.backend.reload!
  end

  before { I18n.available_locales = locales }
end
