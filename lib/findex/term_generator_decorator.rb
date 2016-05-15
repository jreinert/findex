module Findex
  class TermGeneratorDecorator < SimpleDelegator
    def initialize(term_generator, document)
      @term_generator = term_generator
      @document = document
      super(term_generator)
    end

    def []=(prefix, text)
      prefix = prefix ? "X#{prefix}".upcase : ''
      @term_generator.index_text(text.to_s, 1, prefix)
      @term_generator.increase_termpos
    end

    def <<(text)
      self[nil] = text
    end

    def date=(date)
      @document.date = date
    end
  end
end
