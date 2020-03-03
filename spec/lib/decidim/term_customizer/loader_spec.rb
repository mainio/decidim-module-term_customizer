# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Loader do
  subject { described_class.new(resolver) }

  let(:organization) { create(:organization) }
  let(:space) { nil }
  let(:component) { nil }
  let(:resolver) do
    Decidim::TermCustomizer::Resolver.new(organization, space, component)
  end

  describe "#translations_hash" do
    let(:translations_list) do
      {
        en: {
          decidim: {
            term1: "Term 1",
            term2: "Term 2"
          }
        },
        fi: {
          decidim: {
            term1: "Termi 1",
            term2: "Termi 2"
          }
        },
        sv: {
          decidim: {
            term1: "Term 1",
            term2: "Term 2"
          }
        }
      }
    end
    let(:translation_objects) do
      objects = []
      translations_list.each_with_object({}) do |(locale, v)|
        objects << flatten_hash(v).map do |translation_key, translation_term|
          create(:translation, locale: locale, key: translation_key, value: translation_term)
        end
      end
      objects.flatten
    end

    it "returns the correct translations list" do
      expect(resolver).to receive(:translations).and_return(translation_objects)
      expect(subject.translations_hash).to match(translations_list)
    end

    it "caches the result" do
      expect(Rails.cache).to receive(:fetch).with(
        "decidim_term_customizer/organization_#{organization.id}",
        expires_in: 24.hours
      )

      subject.translations_hash
    end
  end

  describe "#clear_cache" do
    context "without organization" do
      let(:organization) { nil }

      it "clears cache with correct key" do
        expect(Rails.cache).to receive(:delete_matched).with(
          "decidim_term_customizer/system/*"
        )

        subject.clear_cache
      end
    end

    context "with organization" do
      it "clears cache with correct key" do
        expect(Rails.cache).to receive(:delete_matched).with(
          "decidim_term_customizer/organization_#{organization.id}/*"
        )

        subject.clear_cache
      end
    end

    context "with organization and space" do
      let(:space) { create(:participatory_process, organization: organization) }

      it "clears cache with correct key" do
        expect(Rails.cache).to receive(:delete_matched).with(
          "decidim_term_customizer/organization_#{organization.id}/*"
        )

        subject.clear_cache
      end
    end

    context "with organization, space and component" do
      let(:space) { create(:participatory_process, organization: organization) }
      let(:component) { create(:proposal_component, participatory_space: space) }

      it "clears cache with correct key" do
        expect(Rails.cache).to receive(:delete_matched).with(
          "decidim_term_customizer/organization_#{organization.id}/*"
        )

        subject.clear_cache
      end
    end

    # The MemCacheStore does not implement `delete_matched` which allows us to
    # test the `clear_cache` functionality when the cache implementation raises
    # a `NotImplementedError`.
    context "when using mem_cache_store" do
      before do
        allow(Rails).to receive(:cache).and_return(
          ActiveSupport::Cache::MemCacheStore.new
        )
      end

      context "without organization" do
        let(:organization) { nil }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/system"
          )

          subject.clear_cache
        end
      end

      context "with organization" do
        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )

          subject.clear_cache
        end
      end

      context "with organization and space" do
        let(:space) { create(:participatory_process, organization: organization) }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}"
          )

          subject.clear_cache
        end
      end

      context "with organization, space and component" do
        let(:space) { create(:participatory_process, organization: organization) }
        let(:component) { create(:proposal_component, participatory_space: space) }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}/component_#{component.id}"
          )

          subject.clear_cache
        end
      end
    end

    # The DalliStore does not implement `delete_matched` which allows us to
    # test the `clear_cache` functionality when the cache implementation raises
    # a `NoMethodError`.
    context "when using dalli_store" do
      before do
        allow(Rails).to receive(:cache).and_return(
          ActiveSupport::Cache.lookup_store(:dalli_store)
        )
      end

      context "without organization" do
        let(:organization) { nil }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/system"
          )

          subject.clear_cache
        end
      end

      context "with organization" do
        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )

          subject.clear_cache
        end
      end

      context "with organization and space" do
        let(:space) { create(:participatory_process, organization: organization) }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}"
          )

          subject.clear_cache
        end
      end

      context "with organization, space and component" do
        let(:space) { create(:participatory_process, organization: organization) }
        let(:component) { create(:proposal_component, participatory_space: space) }

        it "clears cache with correct key" do
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}"
          )
          expect(Rails.cache).to receive(:delete).with(
            "decidim_term_customizer/organization_#{organization.id}/space_#{space.id}/component_#{component.id}"
          )

          subject.clear_cache
        end
      end
    end
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else
        h[k.to_s] = v
      end
    end
  end
end
