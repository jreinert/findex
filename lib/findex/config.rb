module Findex
  class Config
    attr_accessor :stem_language, :log_level

    def initialize
      @stem_language = 'none'
      @log_level = :info

      yield self if block_given?
    end
  end
end
