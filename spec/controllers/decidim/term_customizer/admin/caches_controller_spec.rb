# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::CachesController do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET index" do
        it "redirects to the translation sets path" do
          get :index

          expect(response).to have_http_status(:found)
          expect(subject).to redirect_to(translation_sets_path)
        end
      end

      describe "DELETE clear" do

        it "clears the cache and redirects to the translation sets path" do
          delete :clear

          expect(response).to have_http_status(:found)
          expect(subject).to redirect_to(translation_sets_path)
        end
      end
    end
  end
end
