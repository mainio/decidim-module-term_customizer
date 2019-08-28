# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::AddTranslationsController, type: :controller do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:translation_set) { create(:translation_set, organization: organization) }

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
        it "renders the index template" do
          get :index, params: params
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
        end
      end

      describe "POST create" do
        it "creates a translation" do
          post :create, params: params.merge(
            keys: [
              "first.key",
              "second.key",
              "third.key"
            ]
          )

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end

      describe "GET search" do
        context "with no search term provided" do
          it "renders an empty search results JSON" do
            get :search, params: params
            expect(response).to have_http_status(:ok)

            json = JSON.parse(response.body)
            expect(json.length).to eq(0)
          end
        end

        context "with search term provided" do
          it "renders the search results JSON" do
            get :search, params: params.merge(
              term: "term_customizer"
            )
            expect(response).to have_http_status(:ok)

            json = JSON.parse(response.body)
            expect(json.length).to eq(75)
          end
        end
      end
    end
  end
end
