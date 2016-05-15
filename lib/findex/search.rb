module Findex
  class Search
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
      @findex_path = @root_path + '.findex'
      setup
    end

    def query(query_terms)
      enquire = Xapian::Enquire.new(@db)
      add_prefixes(query_terms)
      add_value_range_processors
      query_terms.map! { |term| term =~ /\s+/ ? %("#{term}") : term }
      enquire.query = @query_parser.parse_query(query_terms.join(' '))
      mset = enquire.mset(0, @db.doccount)
      Enumerator.new do |y|
        mset.matches.each do |match|
          document = DocumentDecorator.new(match.document, @root_path)
          y << document
        end
      end
    end

    private

    def add_prefixes(query_terms)
      prefix_regex = /(?<prefix>\w+):/
      query_terms.each do |term|
        match = term.match(prefix_regex)
        next unless match
        prefix = match[:prefix]
        @query_parser.add_prefix(prefix, "X#{prefix}".upcase)
      end
    end

    def add_value_range_processors
      date_processor = Xapian::DateValueRangeProcessor.new(
        DocumentDecorator::VALUE_SLOTS[:date],
        'date:',
        true
      )
      @query_parser.add_valuerangeprocessor(date_processor)
    end

    def setup
      db_path = @findex_path + 'db'
      unless @findex_path.exist? && db_path.exist?
        raise "No index in '#{@root_path}', run index first."
      end
      require((@findex_path + 'config.rb').realpath)
      setup_db(db_path)
    end

    def setup_db(db_path)
      @db = Xapian::Database.new(db_path.to_s)
      @query_parser = Xapian::QueryParser.new
      @query_parser.stemmer = Xapian::Stem.new(Findex.config.stem_language)
      @query_parser.database = @db
    end
  end
end
