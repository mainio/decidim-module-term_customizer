# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::TranslationSetsController, type: :controller do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET index" do
        before do
          create_list(:translation_set, 10, organization: organization)
          create_list(:translation_set, 10, organization: other_organization)
        end

        it "renders the index listing" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(assigns(:sets).count).to eq(10)
        end
      end

      describe "GET new" do
        render_views

        it "renders the empty form" do
          get :new
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:new)
          expect(assigns(:subject_manifests)).to be_empty
        end

        context "when participatory space exists" do
          before do
            create(:participatory_process, organization: organization)
          end

          it "is available for selection" do
            expected = Decidim.participatory_space_manifests.select do |sm|
              sm.name == :participatory_processes
            end

            get :new
            expect(assigns(:subject_manifests)).to match_array(expected)
          end
        end
      end

      describe "POST create" do
        it "creates a translation set" do
          post :create, params: { name: { en: "Lorem ipsum dolor sit amet" } }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "GET edit" do
        let(:translation_set) { create(:translation_set, organization: organization) }

        it "renders the edit form" do
          get :edit, params: { id: translation_set.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
        end
      end

      describe "PUT update" do
        let(:translation_set) { create(:translation_set, organization: organization) }

        it "updates the translation set" do
          put :update, params: {
            id: translation_set.id,
            name: { en: "Lorem ipsum dolor sit amet" }
          }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "DELETE destroy" do
        let(:translation_set) { create(:translation_set, organization: organization) }

        it "destroys the translation set" do
          delete :destroy, params: { id: translation_set.id }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "POST duplicate" do
        let(:translation_set) { create(:translation_set, organization: organization) }

        it "duplicates a translation set" do
          post :duplicate, params: { id: translation_set.id }

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
