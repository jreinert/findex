module Findex
  class Config
    attr_accessor :stem_language

    def initialize
      @stem_language = 'none'

      yield self if block_given?
    end
  end
end
