require_relative './config'

module Findex
  class DSL
    attr_reader :definitions

    def initialize
      @definitions = {}
      @config = Config.new
    end

    def on(extension, &block)
      @definitions[extension] = block
    end

    def config(&block)
      return @config unless block_given?
      @config = Config.new(&block)
    end
  end
end
