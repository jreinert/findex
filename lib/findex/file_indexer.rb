require_relative './index'
require 'filemagic'

module Findex
  class FileIndexer
    TEXT_INDEXER = lambda do |file, index|
      index << File.read(file)
    end

    def initialize(file)
      @file = file
      @mime = FileMagic.open(:mime_type) { |magic| magic.file(file.to_s) }
    end

    def index(term_generator)
      indexer = Findex.definitions[@mime] || TEXT_INDEXER
      indexer.call(@file, term_generator)
    end
  end
end
