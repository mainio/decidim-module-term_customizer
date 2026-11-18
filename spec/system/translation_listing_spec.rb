# frozen_string_literal: true

require "spec_helper"

describe "TranslationListing" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:translation_set) { create(:translation_set, organization:, name: { en: "Autocomplete" }) }

  context "when input finds large amount of translations" do
    before do
      switch_to_host(organization.host)
      sign_in user
      visit decidim_admin_term_customizer.translation_sets_path(locale: I18n.locale)
      click_link "Autocomplete"
      click_link "Add multiple", match: :first
    end

    it "limits the autocomplete list to 200" do
      fill_in "Search", with: "pro"

      within "form[action$='/add_translations/search']" do
        within "ul#autoComplete_list_1" do
          expect(page).to have_css("li", count: 200)
        end
      end
    end
  end
end
