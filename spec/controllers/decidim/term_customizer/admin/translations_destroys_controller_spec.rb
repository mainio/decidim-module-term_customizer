# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::TranslationsDestroysController, type: :controller do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:translation_set) { create(:translation_set, organization: organization) }
      let!(:translations) { create_list(:translation, 10, translation_set: translation_set) }

      let(:params) do
        {
          translation_set_id: translation_set.id,
          translation_ids: translations.map(&:id)
        }
      end

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET new" do
        it "renders the confirm view" do
          get :new, params: params
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:new)
          expect(assigns(:form).translations.count).to eq(10)
        end
      end

      describe "DELETE destroy" do
        let(:translation) { create(:translation, translation_set: translation_set) }

        it "destroys the translations" do
          delete :destroy, params: params

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        context "with no translations" do
          let!(:translations) { [] }

          it "redirects with an alert" do
            delete :destroy, params: params

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
