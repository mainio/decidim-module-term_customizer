# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::TranslationSetsController do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET index" do
        before do
          create_list(:translation_set, 10, organization:)
          create_list(:translation_set, 10, organization: other_organization)
        end

        it "renders the index listing" do
          get :index, params: { locale: I18n.locale }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(assigns(:sets).count).to eq(10)
        end
      end

      describe "GET new" do
        render_views

        it "renders the empty form" do
          get :new, params: { locale: I18n.locale }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:new)
          expect(assigns(:subject_manifests)).to be_empty
        end

        context "when participatory space exists" do
          before do
            create(:participatory_process, organization:)
          end

          it "is available for selection" do
            expected = Decidim.participatory_space_manifests.select do |sm|
              sm.name == :participatory_processes
            end

            get :new, params: { locale: I18n.locale }
            expect(assigns(:subject_manifests)).to match_array(expected)
          end
        end
      end

      describe "POST create" do
        it "creates a translation set" do
          post :create, params: { name: { en: "Lorem ipsum dolor sit amet" }, locale: I18n.locale }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "GET edit" do
        let(:translation_set) { create(:translation_set, organization:) }

        it "renders the edit form" do
          get :edit, params: { id: translation_set.id, locale: I18n.locale }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
        end

        context "when the organization has participatory spaces" do
          render_views

          let!(:spaces) { create_list(:participatory_process, 3, organization:) }
          let!(:component) { create(:component, participatory_space: spaces.first) }
          let!(:space_constraint) do
            translation_set.constraints.create!(organization:, subject: spaces.last)
          end
          let!(:component_constraint) do
            translation_set.constraints.create!(organization:, subject: component)
          end

          # The name of every field that would be submitted with the
          # constraints of the form.
          def constraint_field_names
            Nokogiri::HTML(response.body).css(".constraints-list [name]").map { |field| field["name"] }
          end

          def component_field_names
            constraint_field_names.grep(/\[component_model\]/)
          end

          def count_component_queries
            count = 0
            counter = lambda do |_name, _started, _finished, _id, payload|
              count += 1 if payload[:name] == "Decidim::Component Load"
            end

            ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }

            count
          end

          before do
            # The set factory adds an organization wide constraint, the
            # constraints under test are the only ones needed here.
            translation_set.constraints.where(subject: nil).destroy_all
          end

          it "renders the fields of the selected space only" do
            get :edit, params: { id: translation_set.id, locale: I18n.locale }

            expect(component_field_names).to contain_exactly(
              "constraints[#{space_constraint.id}][subject_model][participatory_processes][component_model][#{spaces.last.id}][subject_id]",
              "constraints[#{space_constraint.id}][subject_model][participatory_processes][component_model][#{spaces.last.id}][component_id]",
              "constraints[#{component_constraint.id}][subject_model][participatory_processes][component_model][#{spaces.first.id}][subject_id]",
              "constraints[#{component_constraint.id}][subject_model][participatory_processes][component_model][#{spaces.first.id}][component_id]"
            )
          end

          it "preselects the manifest, the space and the component of a constraint" do
            get :edit, params: { id: translation_set.id, locale: I18n.locale }

            section = Nokogiri::HTML(response.body).at_css("#constraint_#{component_constraint.id}-field")
            selected = section.css("option[selected]").map { |option| option["value"] }

            expect(selected).to eq(
              ["participatory_processes", spaces.first.id.to_s, component.id.to_s]
            )
          end

          it "does not submit more fields when there are more spaces" do
            get :edit, params: { id: translation_set.id, locale: I18n.locale }
            before_fields = constraint_field_names

            create_list(:participatory_process, 20, organization:)

            get :edit, params: { id: translation_set.id, locale: I18n.locale }

            expect(constraint_field_names).to eq(before_fields)
          end

          it "does not load the components of every space" do
            queries = count_component_queries do
              get :edit, params: { id: translation_set.id, locale: I18n.locale }
            end

            create_list(:participatory_process, 20, organization:)

            expect(
              count_component_queries { get :edit, params: { id: translation_set.id, locale: I18n.locale } }
            ).to eq(queries)
          end

          context "when the set has many constraints" do
            before do
              create_list(:participatory_process, 27, organization:)
              8.times { translation_set.constraints.create!(organization:, subject: spaces.first) }
            end

            it "keeps the submitted parameters within the rack query limit" do
              get :edit, params: { id: translation_set.id, locale: I18n.locale }

              # 10 constraints x (manifest + space + component + id + deleted)
              expect(constraint_field_names.count).to eq(70)
            end
          end

          context "when the constraint has no subject" do
            let!(:space_constraint) { translation_set.constraints.create!(organization:) }
            let!(:component_constraint) { translation_set.constraints.create!(organization:) }

            it "renders no component fields" do
              get :edit, params: { id: translation_set.id, locale: I18n.locale }

              expect(component_field_names).to be_empty
            end
          end

          context "when the space of a constraint no longer exists" do
            before do
              Decidim::ParticipatoryProcess.where(id: spaces.last.id).delete_all
            end

            it "still renders the form" do
              get :edit, params: { id: translation_set.id, locale: I18n.locale }

              expect(response).to have_http_status(:ok)
            end
          end
        end
      end

      describe "PUT update" do
        let(:translation_set) { create(:translation_set, organization:) }

        it "updates the translation set" do
          put :update, params: {
            id: translation_set.id,
            name: { en: "Lorem ipsum dolor sit amet" },
            locale: I18n.locale
          }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        context "when the organization has many spaces and the set many constraints" do
          let!(:spaces) { create_list(:participatory_process, 12, organization:) }
          let(:constrained_spaces) { spaces.first(10) }
          let(:constraints_params) do
            constrained_spaces.each_with_index.to_h do |space, index|
              [
                index.to_s,
                {
                  subject_manifest: "participatory_processes",
                  subject_model: {
                    participatory_processes: {
                      subject_manifest: "participatory_processes",
                      subject_id: space.id.to_s,
                      component_model: {
                        space.id.to_s => { subject_id: space.id.to_s, component_id: "" }
                      }
                    }
                  },
                  deleted: "false"
                }
              ]
            end
          end

          it "saves every constraint" do
            put :update, params: {
              id: translation_set.id,
              name: { en: "Lorem ipsum dolor sit amet" },
              constraints: constraints_params,
              locale: I18n.locale
            }

            expect(response).to have_http_status(:found)
            expect(translation_set.reload.constraints.map(&:subject)).to match_array(constrained_spaces)
          end

          it "saves the component of a constraint" do
            component = create(:component, participatory_space: constrained_spaces.first)
            params = constraints_params
            params["0"][:subject_model][:participatory_processes][:component_model][constrained_spaces.first.id.to_s][:component_id] = component.id.to_s

            put :update, params: {
              id: translation_set.id,
              name: { en: "Lorem ipsum dolor sit amet" },
              constraints: params,
              locale: I18n.locale
            }

            expect(translation_set.reload.constraints.map(&:subject)).to include(component)
          end
        end
      end

      describe "DELETE destroy" do
        let(:translation_set) { create(:translation_set, organization:) }

        it "destroys the translation set" do
          delete :destroy, params: { id: translation_set.id, locale: I18n.locale }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "POST duplicate" do
        let(:translation_set) { create(:translation_set, organization:) }

        it "duplicates a translation set" do
          post :duplicate, params: { id: translation_set.id, locale: I18n.locale }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
