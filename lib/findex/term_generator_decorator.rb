module Findex
  class TermGeneratorDecorator
    def initialize(term_generator)
      @term_generator = term_generator
    end

    def []=(prefix, text)
      prefix = prefix ? "X#{prefix}".upcase : nil
      @term_generator.index_text(text, 1, prefix)
      @term_generator.increase_termpos
    end

    def <<(text)
      self[nil] = text
    end
  end
end
