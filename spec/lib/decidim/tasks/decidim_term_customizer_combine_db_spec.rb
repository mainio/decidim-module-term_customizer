# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:term_customizer:combine_db", type: :task do
  let!(:translation_set) { create(:translation_set) }
  let!(:translation) { create(:translation, locale: "te", key: "decidim.term_customizer.test.word", value: "bird") }
  let!(:second_translation) { create(:translation, locale: "te", key: "decidim.term_customizer.test.term", value: "empty") }
  let!(:third_translation) { create(:translation, locale: "te", key: "decidim.term_customizer.test.entry", value: "similar") }

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
          expect { task.invoke("no") }.to raise_error(SystemExit).and output("No files found for locale 'no' \n").to_stderr
        end
      end

      context "when locale is not given" do
        it "gives error for missing argument" do
          task.reenable
          expect { task.invoke }.to raise_error(SystemExit).and output("Mandatory argument missing: locale\n").to_stderr
        end
      end
    end

    context "when there are no errors" do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({
                                                        "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } }
                                                      })
        allow(File).to receive(:write)
      end

      it "passes" do
        task.reenable
        expect { task.invoke("te") }.to output("Combined 1 file(s) into 'config/locales/te.yml'\nTranslations combined successfully!\n").to_stdout
        check_no_errors_have_been_printed
      end

      it "writes file correctly" do
        task.reenable
        task.invoke("te")
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

      context "when there's no term customizer translations in the database" do
        before do
          allow(Decidim::TermCustomizer::Translation).to receive(:where).and_return([])
        end

        it "aborts the task" do
          task.reenable
          expect { task.invoke("te") }.to raise_error(SystemExit).and output("No term customizer translations found for locale 'te'\n").to_stderr
        end
      end
    end
  end

  context "when prefix is used" do
    let(:file_path) { "config/locales/test.te.yml" }
    let(:another_file_path) { "config/locales/filler.te.yml" }

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
        expect { task.invoke("te", "custom") }.to raise_error(SystemExit).and output("No files found for locale 'te' with a prefix\n").to_stderr
      end
    end

    context "when prefixed translation files exist" do
      before do
        allow(Dir).to receive(:glob).and_return([file_path, another_file_path])

        allow(YAML).to receive(:load_file) do |path|
          case path
          when file_path
            { "te" => { "decidim" => { "term_customizer" => { "test" => { "word" => "eagle" } } } } }
          when another_file_path
            { "te" => { "decidim" => { "term_customizer" => { "other_test" => { "treasure" => "value" } } } } }
          end
        end
      end

      it "writes file correctly" do
        task.reenable
        task.invoke("te", "custom")
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
