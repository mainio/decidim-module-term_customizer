# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Import::ImporterFactory do
  describe ".build" do
    let(:file) { double }
    let(:mime_type) { double }
    let(:reader) { double }
    let(:parser) { double }

    context "when reader exists" do
      it "creates a new importer with the correct reader" do
        allow(Decidim::TermCustomizer::Import::Readers).to receive(
          :find_by_mime_type
        ).with(mime_type).and_return(reader)
        expect(Decidim::TermCustomizer::Import::Importer).to receive(:new).with(
          file,
          reader,
          parser
        )
        described_class.build(file, mime_type, parser)
      end
    end

    context "when reader does not exist" do
      it "raises a NotImplementedError" do
        allow(Decidim::TermCustomizer::Import::Readers).to receive(
          :find_by_mime_type
        ).with(mime_type).and_return(nil)
        expect do
          described_class.build(file, mime_type, parser)
        end.to raise_error(NotImplementedError)
      end
    end
  end
end
