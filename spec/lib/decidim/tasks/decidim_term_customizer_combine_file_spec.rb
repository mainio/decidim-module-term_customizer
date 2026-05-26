# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:term_customizer:combine_file", type: :task do
  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "when prefix is not used" do
    context "when there are errors" do
      context "when locale is not found" do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        it "gives error for missing locale" do
          task.reenable
          expect { task.invoke("no", "file:testfiles/blank.xlsx") }.to raise_error(SystemExit).and output("No files found for locale 'no' \n").to_stderr
        end
      end

      context "when locale is not given" do
        it "gives error for missing argument" do
          task.reenable
          expect { task.invoke }.to raise_error(SystemExit).and output("Mandatory argument missing: locale\n").to_stderr
        end
      end

      context "when only locale is given and locale is found" do
        it "gives error for missing extra arguments" do
          task.reenable
          expect { task.invoke("te") }.to raise_error(SystemExit).and output("Missing extra arguments: 'file:*' or 'prefix:*'\n").to_stderr
        end
      end

      context "when given locale and prefix without file" do
        it "gives error" do
          task.reenable
          expect { task.invoke("te", "prefix:test") }.to raise_error(SystemExit).and output("Missing argument 'file:*'\n").to_stderr
        end
      end

      context "when given wrong format extra argument" do
        it "gives error for wrong format argument" do
          task.reenable
          expect { task.invoke("te", "file:testfiles/blank.xlsx", "test:test") }.to raise_error(SystemExit).and output("Argument in wrong format, only 'prefix:*' or 'file:*' allowed after locale\n").to_stderr
        end
      end
    end

    context "when there are no errors" do
      let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.xlsx") }
      let!(:file) do
        Rack::Test::UploadedFile.new(
          file_path,
          Decidim::Admin::Import::Readers::XLSX::MIME_TYPE
        )
      end

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({
                                                        "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } }
                                                      })
        allow(File).to receive(:write)
      end

      it "passes" do
        task.reenable
        expect { task.invoke("te", "file:#{file_path}") }
          .to output("Combined 1 file(s) into 'config/locales/te.yml'\nTranslations combined successfully!\n").to_stdout
          .and(not_output.to_stderr)
      end

      it "writes file correctly" do
        task.reenable
        expect { task.invoke("te", "file:#{file_path}") }.to output("Combined 1 file(s) into 'config/locales/te.yml'\nTranslations combined successfully!\n").to_stdout
        expect(File).to have_received(:write) do |output_file, yaml_content|
          expect(output_file).to eq("config/locales/te.yml")

          data = YAML.safe_load(yaml_content)

          expect(data).to include(
            "te" => {
              "decidim" => {
                "term_customizer" => {
                  "test" => {
                    "word" => "bird",
                    "term" => "empty",
                    "entry" => "similar"
                  }
                }
              }
            }
          )
        end
      end

      context "when term customizer file type is csv" do
        let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.csv") }
        let!(:file) do
          Rack::Test::UploadedFile.new(
            file_path,
            Decidim::Admin::Import::Readers::CSV::MIME_TYPE
          )
        end

        it "writes file correctly" do
          task.reenable
          expect { task.invoke("te", "file:#{file_path}") }.to output("Combined 1 file(s) into 'config/locales/te.yml'\nTranslations combined successfully!\n").to_stdout
          expect(File).to have_received(:write) do |output_file, yaml_content|
            expect(output_file).to eq("config/locales/te.yml")

            data = YAML.safe_load(yaml_content)

            expect(data).to include(
              "te" => {
                "decidim" => {
                  "term_customizer" => {
                    "test" => {
                      "word" => "bird",
                      "term" => "empty",
                      "entry" => "similar"
                    }
                  }
                }
              }
            )
          end
        end
      end

      context "when term customizer file type is json" do
        let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.json") }
        let!(:file) do
          Rack::Test::UploadedFile.new(
            file_path,
            Decidim::Admin::Import::Readers::JSON::MIME_TYPE
          )
        end

        it "writes file correctly" do
          task.reenable
          expect { task.invoke("te", "file:#{file_path}") }.to output("Combined 1 file(s) into 'config/locales/te.yml'\nTranslations combined successfully!\n").to_stdout
          expect(File).to have_received(:write) do |output_file, yaml_content|
            expect(output_file).to eq("config/locales/te.yml")

            data = YAML.safe_load(yaml_content)

            expect(data).to include(
              "te" => {
                "decidim" => {
                  "term_customizer" => {
                    "test" => {
                      "word" => "bird",
                      "term" => "empty",
                      "entry" => "similar"
                    }
                  }
                }
              }
            )
          end
        end
      end

      context "when term customizer file type is incorrect" do
        let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.json") }
        let!(:file) do
          Rack::Test::UploadedFile.new(
            file_path,
            Decidim::Admin::Import::Readers::JSON::MIME_TYPE
          )
        end

        before do
          allow(File).to receive(:extname).and_return(".wrong")
        end

        it "writes file correctly" do
          task.reenable
          expect { task.invoke("te", "file:#{file_path}") }.to raise_error(SystemExit).and output("Unsupported file type: '.wrong'\n").to_stderr
        end
      end
    end
  end

  context "when prefix is used" do
    let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.xlsx") }
    let!(:file) do
      Rack::Test::UploadedFile.new(
        file_path,
        Decidim::Admin::Import::Readers::XLSX::MIME_TYPE
      )
    end

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).and_return({
                                                      "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } }
                                                    })
      allow(File).to receive(:write)
    end

    context "when prefixed translation files do not exist" do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it "gives error for no files found" do
        task.reenable
        expect { task.invoke("te", "prefix:custom", "file:#{file_path}") }.to raise_error(SystemExit).and output("No files found for locale 'te' with a prefix\n").to_stderr
      end
    end

    context "when prefixed translation files exist" do
      let(:first_path) { "config/locales/test.te.yml" }
      let(:another_file_path) { "config/locales/filler.te.yml" }
      let(:file_path) { Decidim::TermCustomizer::Engine.root.join("lib/decidim/term_customizer/test/assets/term_translations.xlsx") }
      let!(:file) do
        Rack::Test::UploadedFile.new(
          file_path,
          Decidim::Admin::Import::Readers::XLSX::MIME_TYPE
        )
      end

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({
                                                        "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } }
                                                      })
        allow(File).to receive(:write)
        allow(Dir).to receive(:glob).and_return([first_path, another_file_path])

        allow(YAML).to receive(:load_file) do |path|
          case path
          when first_path
            { "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } } }
          when another_file_path
            { "te" => { "decidim" => { "term_customizer" => { "other_test" => { "treasure" => "value" } } } } }
          end
        end
      end

      it "writes file correctly" do
        task.reenable
        task.invoke("te", "file:#{file_path}", "prefix:custom")
        expect(File).to have_received(:write) do |output_file, yaml_content|
          expect(output_file).to eq("config/locales/custom.te.yml")

          data = YAML.safe_load(yaml_content)

          expect(data).to include(
            "te" => {
              "decidim" => {
                "term_customizer" => {
                  "test" => {
                    "word" => "bird",
                    "term" => "empty",
                    "entry" => "similar"
                  },
                  "other_test" => {
                    "treasure" => "value"
                  }
                }
              }
            }
          )
        end
      end
    end
  end
end
