require_relative './index'

module Findex
  class FileIndexer
    TEXT_INDEXER = lambda do |file, index|
      index << File.read(file)
    end

    def initialize(file)
      @file = file
      @extension = File.extname(file)[1..-1]
    end

    def index(term_generator)
      indexer = Findex.definitions[@extension] || TEXT_INDEXER
      indexer.call(@file, term_generator)
    end
  end
end
