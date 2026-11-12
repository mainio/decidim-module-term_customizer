# frozen_string_literal: true

require "spec_helper"

describe "Translation" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:translation_set) { create(:translation_set, organization:, name: { en: "Dummy set" }) }

  context "when the translation value is the list" do
    let(:translation_hash) do
      {
        "dummy.translation.one" => "<ul><li>Dummy record</li><li>Dummy record #2</li><li>Dummy record #3</li></ul>",
        "dummy.translation.two" => "Dummy record #4"
      }
    end

    before do
      switch_to_host(organization.host)
      sign_in user
      visit decidim_admin_term_customizer.translation_sets_path(locale: I18n.locale)
      click_link "Dummy set"
      click_link "Add multiple", match: :first
    end

    it "Adds the lists properly" do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::TermCustomizer::TranslationDirectory).to receive(:translations_search).with("dummy re").and_return(translation_hash)
      # rubocop:enable RSpec/AnyInstance

      fill_in "Search", with: "dummy re"
      list_element = page.find(".tc-result-line", text: "Dummy record #2")
      list_element.click

      within "#add-translations" do
        expect(page).to have_css("td", text: "dummy.translation.one")
        expect(page).to have_css("td", text: "Dummy record Dummy record #2 Dummy record #3 (dummy.translation.one)")
      end
    end
  end
end
