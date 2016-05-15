require_relative './indexer'
require_relative './search'

module Findex
  class Cli
    USAGE = "Usage: #{$PROGRAM_NAME} (index|search) [path] [-- query]".freeze

    def initialize(args)
      query_separator_index = args.find_index('--') || -1
      action = args[0]
      path = query_separator_index != 1 ? args[1] : nil

      case action
      when 'index' then index(path || '.')
      when 'search'
        abort(USAGE) if query_separator_index == -1
        search(path, args[query_separator_index..-1])
      else abort("Unsupported action '#{action}'\n#{USAGE}")
      end
    end

    def index(path)
      Indexer.new(path || '.').start
    end

    def search(path, query_terms)
      Search.new(path || '.').query(query_terms).each do |document|
        puts document.full_path
      end
    end
  end
end
