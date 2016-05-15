require_relative './indexer'

module Findex
  class Cli
    USAGE = "Usage: #{$PROGRAM_NAME} (index|search) [path] [-- query]".freeze

    def initialize(args)
      query_separator_index = args.find_index('--') || -1
      action, path = args[0..query_separator_index]

      case action
      when 'index' then Indexer.new(path || '.').start
      when 'search'
        query = args[query_separator_index..-1] || []
      else abort("Unsupported action '#{action}'\n#{USAGE}")
      end
    end
  end
end
