# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TermCustomizer
    describe Admin::ConstraintComponentsController do
      include_context "with setup initializer"

      routes { Decidim::TermCustomizer::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let!(:space) { create(:participatory_process, organization:) }
      let!(:component) { create(:component, participatory_space: space, name: { en: "Proposals" }) }
      let(:json_response) { response.parsed_body }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "GET index" do
        it "returns the components of the space" do
          get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

          expect(response).to have_http_status(:ok)
          expect(json_response["manifest"]).to eq("participatory_processes")
          expect(json_response["space_id"]).to eq(space.id)
          expect(json_response["components_supported"]).to be(true)
          expect(json_response["components"]).to eq(
            [{ "id" => component.id, "name" => "Proposals" }]
          )
        end

        it "labels the component field the same way the form does" do
          get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

          expect(json_response["label"]).to eq(
            Admin::TranslationSetConstraintForm.human_attribute_name(:component_id)
          )
        end

        context "when the space has no components" do
          let!(:component) { nil }

          it "returns an empty list" do
            get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

            expect(response).to have_http_status(:ok)
            expect(json_response["components_supported"]).to be(true)
            expect(json_response["components"]).to eq([])
          end
        end

        context "when the space does not have components at all" do
          let(:componentless_space) { Struct.new(:id).new(space.id) }

          before do
            relation = Decidim::ParticipatoryProcess.where(organization:)
            allow(Decidim::ParticipatoryProcess).to receive(:where).and_return(relation)
            allow(relation).to receive(:find_by).and_return(componentless_space)
          end

          it "reports that the space does not support components" do
            get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

            expect(response).to have_http_status(:ok)
            expect(json_response["components_supported"]).to be(false)
            expect(json_response["components"]).to eq([])
          end
        end

        context "when the space belongs to another organization" do
          let!(:space) { create(:participatory_process, organization: other_organization) }

          it "does not leak the components" do
            get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

            expect(response).to have_http_status(:not_found)
            expect(response.body).not_to include("Proposals")
          end
        end

        context "when the manifest does not exist" do
          it "returns a not found response" do
            get :index, params: { manifest: "Decidim::ParticipatoryProcess", space_id: space.id, locale: I18n.locale }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "when the space does not exist" do
          it "returns a not found response" do
            get :index, params: { manifest: "participatory_processes", space_id: space.id + 1_000, locale: I18n.locale }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "when the space is not given" do
          it "returns a not found response" do
            get :index, params: { manifest: "participatory_processes", locale: I18n.locale }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "when the user is not an admin" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "does not return the components" do
            get :index, params: { manifest: "participatory_processes", space_id: space.id, locale: I18n.locale }

            expect(response).not_to have_http_status(:ok)
            expect(response.body).not_to include("Proposals")
          end
        end
      end
    end
  end
end
