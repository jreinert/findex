require_relative './dsl'

module Findex
  def self.index
    dsl = DSL.new
    yield dsl
    @definitions = dsl.definitions
    @config = dsl.config
  end

  def self.definitions
    @definitions
  end

  def self.config
    @config
  end
end
