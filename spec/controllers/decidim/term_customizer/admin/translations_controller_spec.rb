# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::TranslationsController, type: :controller do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:translation_set) { create(:translation_set, organization: organization) }
      let(:other_translation_set) { create(:translation_set, organization: other_organization) }

      let(:params) do
        {
          translation_set_id: translation_set.id
        }
      end

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET index" do
        before do
          create_list(:translation, 10, translation_set: translation_set)
          create_list(:translation, 10, translation_set: other_translation_set)
        end

        it "renders the index listing" do
          get :index, params: params
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(assigns(:translations).count).to eq(10)
        end
      end

      describe "GET new" do
        it "renders the empty form" do
          get :new, params: params
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:new)
        end
      end

      describe "POST create" do
        it "creates a translation" do
          post :create, params: params.merge(
            key: "new.key.to.translation",
            value: { en: "Lorem ipsum dolor" }
          )

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "GET edit" do
        let(:translation) { create(:translation, translation_set: translation_set) }

        it "renders the edit form" do
          get :edit, params: params.merge(id: translation.id)
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
        end
      end

      describe "PUT update" do
        let(:translation) { create(:translation, translation_set: translation_set) }

        it "updates the translation" do
          put :update, params: params.merge(
            id: translation.id,
            key: "updated.translation.key",
            value: { en: "Lorem ipsum dolor" }
          )

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "POST export" do
        let(:translation_set) { create(:translation_set, organization: organization) }

        it "exports the translations" do
          post :export, params: params.merge(format: "JSON")

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "DELETE destroy" do
        let(:translation) { create(:translation, translation_set: translation_set) }

        it "destroys the translation" do
          delete :destroy, params: params.merge(id: translation.id)

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "GET import" do
        it "renders the import form" do
          get :new_import, params: params

          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:new_import)
        end
      end

      describe "POST import" do
        let(:file) do
          fixture_file_upload(
            file_fixture("set-translations.json"),
            "application/json"
          )
        end

        it "runs the import" do
          post :import, params: params.merge(file: file)

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
