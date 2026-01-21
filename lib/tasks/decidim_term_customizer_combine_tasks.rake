# frozen_string_literal: true

namespace :decidim do
  namespace :term_customizer do
    desc "This task combines your instance's translations with term_customizer's custom translations from the database"
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

namespace :decidim do
  namespace :term_customizer do
    desc "This task combines your instance's translations with term_customizer's custom translations from an excel file"
    task :combine_file, [:locale] => :environment do |_t, args|
      locale = args[:locale]
      prefix = nil
      files = []

      abort "Mandatory argument missing: locale" unless locale

      extra = args.extras

      abort "Missing extra arguments: 'file:*' or 'prefix:*'" if extra.empty?

      extra.each do |argument|
        parsed = parse_arguments(argument)

        prefix = add_arguments(parsed, prefix: prefix, files: files)
      end

      abort "Missing argument 'file:*'" if files.empty?

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

        files.each do |file|
          abort "No translation files found in '#{file}'" unless File.exist?(file)
          data.deep_merge!(term_customizer_file_data(locale, file))
        end

        File.write(output_file, data.to_yaml)

        puts "Combined #{input_files.size} file(s) into '#{output_file}'"

        puts "Translations combined successfully!"
      end
    end
  end
end

def term_customizer_data(locale)
  translations = Decidim::TermCustomizer::Translation.where(locale: locale)

  abort "No term customizer translations found for locale '#{locale}'" if translations.empty?

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

def term_customizer_file_data(locale, file)
  reader = create_reader(file)

  headers = nil
  data = {}

  reader.read_rows do |row, index|
    if index.zero?
      headers = row.map(&:to_s)
      next
    end

    row_hash = headers.zip(row).to_h

    row_locale = row_hash["locale"]
    next unless row_locale == locale

    key_path = row_hash["key"]
    value = row_hash["value"]

    next if row_locale.blank? || key_path.blank?

    data[locale] ||= {}

    keys = key_path.split(".")
    last_key = keys.pop

    current = data[locale]
    keys.each do |key|
      current[key] ||= {}
      current = current[key]
    end

    current[last_key] = value
  end

  data
end

def create_reader(file)
  file_type = File.extname(file).downcase

  file_class = case file_type
               when ".csv" then Decidim::Admin::Import::Readers::CSV
               when ".xlsx" then Decidim::Admin::Import::Readers::XLSX
               when ".json" then Decidim::Admin::Import::Readers::JSON
               else
                 abort "Unsupported file type: '#{file_type}'"
               end

  file_class.new(file)
end

def parse_arguments(argument)
  abort "Argument in wrong format, only 'prefix:*' or 'file:*' allowed after locale" unless argument.start_with?("file:", "prefix:")

  key, value = argument.split(":", 2)

  return nil if key.blank? || value.blank?

  [key.to_sym, value]
end

def add_arguments(parsed, prefix:, files:)
  key, value = parsed

  case key
  when :file
    files << value
    prefix
  when :prefix
    value
  else
    abort "Unknown argument: #{key}"
  end
end
