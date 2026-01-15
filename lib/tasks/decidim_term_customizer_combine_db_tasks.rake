# frozen_string_literal: true

namespace :decidim do
  namespace :term_customizer do
    desc "This task combines your instance's translations with term_customizer's custom translations"
    task :combine_db, [:locale, :prefix] => :environment do |_t, args|
      locale = args[:locale]
      prefix = args[:prefix]

      abort "Mandatory argument missing: locale" unless locale

      input_files = if prefix
                      Dir.glob("config/locales/*.#{locale}.yml")
                    else
                      ["config/locales/#{locale}.yml"]
                    end

      output_file = if prefix
                      "config/locales/#{prefix}.#{locale}.yml"
                    else
                      "config/locales/#{locale}.yml"
                    end

      input_files.select! { |file| File.exist?(file) }

      data = {}

      if input_files.empty?
        abort "No files found for locale '#{locale}' #{prefix ? "with a prefix" : ""}"
      else
        input_files.each do |input_file_path|
          file_data = YAML.load_file(input_file_path)

          data.deep_merge!(file_data)
        end

        data.deep_merge!(term_customizer_data(locale))

        File.write(output_file, data.to_yaml)

        puts "Combined #{input_files.size} file(s) into '#{output_file}'"

        puts "Translations combined successfully!"
      end
    end
  end
end

def term_customizer_data(locale)
  translations = Decidim::TermCustomizer::Translation.where(locale: locale)

  data = { locale => {} }

  translations.each do |translation|
    keys = translation.key.split(".")
    last_key = keys.pop

    current = data[locale]

    keys.each do |key|
      current[key] ||= {}
      current = current[key]
    end

    current[last_key] = translation.value
  end

  data
end
