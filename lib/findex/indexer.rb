require 'xapian'
require 'pathname'
require_relative './document_decorator'
require_relative './config'

module Findex
  # Class used for indexing files
  class Indexer
    DB_FLAGS = Xapian::DB_CREATE_OR_OPEN

    def initialize(root_path)
      @root_path = Pathname.new(root_path)
      @findex_path = @root_path + '.findex'
      setup
    end

    def start
      @db.begin_transaction
      existing = refresh_existing
      files.each do |file|
        next if existing.include?(file)
        insert(file)
      end
      @db.commit_transaction
    end

    private

    def insert(file)
      xapian_document = Xapian::Document.new
      document = DocumentDecorator.new(xapian_document, @root_path, file)
      document.insert(db, term_generator)
    end

    def files
      Enumerator.new do |y|
        Pathname.glob(@root_path + '**' + '*').each do |path|
          next if path.ascend.any? { |p| p == @findex_path }
          next if path.directory?
          y << Pathname.new(path)
        end
      end
    end

    def refresh_existing
      processed_paths = []

      documents.each do |document|
        if document.deleted?
          @db.delete_document(document.docid)
        elsif document.changed?
          document.update(@db, @term_generator)
          processed_paths << document.full_path
        end
      end

      processed_paths
    end

    def documents
      enquire = Xapian::Enquire.new(@db)
      enquire.query = Xapian::Query::MatchAll
      mset = enquire.mset(0, @db.doccount)
      Enumerator.new do |y|
        mset.matches.each do |match|
          y << DocumentDecorator.new(match.document, @root_path)
        end
      end
    end

    def index(path)
      return index_file(path) if File.file?(path)
      return index_dir(path) if File.directory?(path)
    end

    def index_file(path)
    end

    def index_dir(path)
      Dir[File.join(path, '*')].each(&method(:index))
    end

    def setup
      unless @findex_path.exist?
        @findex_path.mkdir
        File.write(@findex_path + 'config.rb', "Findex.index do |indexer|\nend")
      end

      require((@findex_path + 'config.rb').realpath)
      setup_db
    end

    def setup_db
      @db = Xapian::WritableDatabase.new((@findex_path + 'db').to_s, DB_FLAGS)
      @term_generator = Xapian::TermGenerator.new
      @term_generator.database = @db
      @term_generator.stemmer = Xapian::Stem.new(Findex.config.stem_language)
    end
  end
end
