# frozen_string_literal: true

require "spec_helper"

describe "Admin manages translation set constraints" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:space) { create(:participatory_process, organization:, title: { en: "Open budgets" }) }
  let!(:other_space) { create(:participatory_process, organization:, title: { en: "City plan" }) }
  let!(:component) { create(:component, participatory_space: space, name: { en: "Meetings" }) }
  let!(:other_component) { create(:component, participatory_space: other_space, name: { en: "Proposals" }) }
  let(:translation_set) { create(:translation_set, organization:) }

  def pick(selector, option)
    find("select.#{selector} option", text: option, exact_text: true).select_option
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the set has no constraints yet" do
    before do
      translation_set.constraints.destroy_all

      visit "/en/admin/term_customizer/sets/#{translation_set.id}/edit"
      click_on "Add constraint"
    end

    it "loads the components of the space selected in a new constraint", :js do
      within ".constraints-list .constraint-section:last-child" do
        pick("constraint-subject-selector", "Participatory processes")
        pick("constraint-subject-model-selector", "Open budgets")

        expect(page).to have_css("select.constraint-component-selector option", text: "Meetings")
        expect(page).to have_no_css("select.constraint-component-selector option", text: "Proposals")

        pick("constraint-component-selector", "Meetings")
      end

      click_on "Save"

      expect(page).to have_admin_callout("Translation set successfully updated")
      expect(translation_set.reload.constraints.map(&:subject)).to eq([component])
    end

    it "replaces the components when another space is selected", :js do
      within ".constraints-list .constraint-section:last-child" do
        pick("constraint-subject-selector", "Participatory processes")
        pick("constraint-subject-model-selector", "Open budgets")

        expect(page).to have_css("select.constraint-component-selector option", text: "Meetings")

        pick("constraint-subject-model-selector", "City plan")

        expect(page).to have_css("select.constraint-component-selector option", text: "Proposals")
        expect(page).to have_no_css("select.constraint-component-selector option", text: "Meetings")
      end

      click_on "Save"

      expect(page).to have_admin_callout("Translation set successfully updated")
      expect(translation_set.reload.constraints.map(&:subject)).to eq([other_space])
    end

    it "submits only the fields of the selected space", :js do
      within ".constraints-list .constraint-section:last-child" do
        pick("constraint-subject-selector", "Participatory processes")
        pick("constraint-subject-model-selector", "Open budgets")

        expect(page).to have_select(class: "constraint-component-selector")
      end

      component_fields = page.all(
        "form.translation-sets-form [name*='[component_model]']",
        visible: :all
      ).map { |field| field[:name] }

      expect(component_fields).to contain_exactly(
        a_string_ending_with("[component_model][#{space.id}][subject_id]"),
        a_string_ending_with("[component_model][#{space.id}][component_id]")
      )
    end
  end

  context "when the set already has a constraint" do
    before do
      translation_set.constraints.destroy_all
      translation_set.constraints.create!(organization:, subject: component)

      visit "/en/admin/term_customizer/sets/#{translation_set.id}/edit"
    end

    it "keeps the saved selections and saves them back", :js do
      within ".constraints-list .constraint-section:first-child" do
        expect(find("select.constraint-subject-selector").value).to eq("participatory_processes")
        expect(find("select.constraint-subject-model-selector").value).to eq(space.id.to_s)
        expect(find("select.constraint-component-selector").value).to eq(component.id.to_s)
      end

      click_on "Save"

      expect(page).to have_admin_callout("Translation set successfully updated")
      expect(translation_set.reload.constraints.map(&:subject)).to eq([component])
    end

    it "removes the constraint", :js do
      within ".constraints-list .constraint-section:first-child" do
        click_on "Remove"
      end

      click_on "Save"

      expect(page).to have_admin_callout("Translation set successfully updated")
      expect(translation_set.reload.constraints.map(&:subject)).to eq([nil])
    end
  end
end
