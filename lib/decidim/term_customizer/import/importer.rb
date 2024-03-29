# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Import
      # Class providing the interface and implementation of an importer. Needs
      # a reader to be passed to the constructor which handles the import file
      # reading depending on its type.
      #
      # You can also use the ImporterFactory class to create an Importer
      # instance.
      class Importer
        # Public: Initializes an Importer.
        #
        # file   - A file with the data to be imported.
        # reader - A Reader to be used to read the data from the file.
        # parser - A Parser to be used during the import.
        def initialize(file, reader = Readers::Base, parser = Parser)
          @file = file
          @reader = reader
          @parser = parser
        end

        # Public: Imports a spreadsheet/JSON to the data collection provided by
        # the parser. The parsed data objects are saved one by one or the data
        # collection is yielded in case block is given in which case the saving
        # should happen outside of this class.
        def import
          if block_given?
            yield collection
            return
          end

          parser.resource_klass.transaction do
            collection.each(&:save!)
          end
        end

        # Returns a data collection of the target data.
        def collection
          @collection ||= collection_data.map { |item| parser.new(item).parse }
        end

        private

        attr_reader :file, :reader, :parser

        def collection_data
          return @collection_data if @collection_data

          @collection_data = []
          data_headers = []
          reader.new(file).read_rows do |rowdata, index|
            if index.zero?
              data_headers = rowdata.map(&:to_sym)
            else
              @collection_data <<
                rowdata.each_with_index.to_h do |val, ind|
                  [data_headers[ind], val]
                end
            end
          end

          @collection_data
        end
      end
    end
  end
end
