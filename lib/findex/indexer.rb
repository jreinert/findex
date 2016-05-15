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
      Findex.logger.info("adding '#{document.path}' to the index")
      document.insert(@db, @term_generator)
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
      documents.map do |document|
        if document.deleted?
          Findex.logger.info("deleting '#{document.path}' from index")
          @db.delete_document(document.docid)
        elsif document.changed?
          Findex.logger.info("updating '#{document.path}'")
          document.update(@db, @term_generator)
        end

        document.full_path
      end
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
