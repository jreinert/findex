module Findex
  class TermGeneratorDecorator < SimpleDelegator
    def initialize(term_generator)
      @term_generator = term_generator
      super
    end

    def []=(prefix, text)
      prefix = prefix ? "X#{prefix}".upcase : ''
      @term_generator.index_text(text.to_s, 1, prefix)
      @term_generator.increase_termpos
    end

    def <<(text)
      self[nil] = text
    end
  end
end
