# frozen_string_literal: true

require "spec_helper"

describe "explore adding translation", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:translation_set) { create(:translation_set, organization: organization, name: { en: "Dummy set" }) }

  context "when the translation value is the list" do
    # let!(:translation1) { create(:translation, key: "dummy.translation.one", value: "<ul><li>dummy translation list</li></ul>") }
    # let!(:translation2) { create(:translation, key: "dummy.translation.two", value: "dummy translation string") }
    let(:translation_hash) do
      {
        "dummy.translation.one" => "<ul><li>dummy translation list</li></ul>",
        "dummy.translation.two" => "dummy translation string"
      }
    end

    before do
      switch_to_host(organization.host)
      sign_in user
      visit decidim_admin_term_customizer.translation_sets_path
      click_link "Dummy set"
      click_link "Add multiple", match: :first
    end

    it "Adds the lists properly" do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::TermCustomizer::TranslationDirectory).to receive(:translations_search).with("dummy tran").and_return(translation_hash)
      # rubocop:enable RSpec/AnyInstance

      fill_in "Search", with: "dummy tran"
      li_element = page.find("li", text: "<ul><li>dummy translation list</li></ul>")
      within "ul#autoComplete_list_1" do
        expect(li_element).not_to have_css(".hide")
        expect(page).to have_css("li", text: "<ul><li>dummy translation list</li></ul>")
        expect(page).to have_css("li", text: "dummy translation string")
        li_element.click
        expect(li_element).not_to have_css("li", text: "<ul><li>dummy translation list</li></ul>")
      end
      within "table.table-list" do
        expect(page).to have_css("th", text: "Translation key")
        expect(page).to have_css("td", text: "dummy.translation.one")
        expect(page).to have_css("td", text: "<ul><li>dummy translation list</li></ul>")
      end
    end
  end
end
