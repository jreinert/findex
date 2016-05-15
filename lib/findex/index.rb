require 'logger'
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

  def self.logger
    @logger ||= Logger.new(STDOUT).tap do |logger|
      logger.level = config.log_level
    end
  end
end
