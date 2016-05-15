require 'time'
require 'date'
require 'xapian'
require_relative './file_indexer'
require_relative './term_generator_decorator'

module Findex
  # A decorator class to be used around Xapian::Documents
  class DocumentDecorator < SimpleDelegator
    TIME_FORMAT = '%s'.freeze
    DATE_FORMAT = '%Y%m%d'.freeze
    VALUE_SLOTS = {
      path: 0,
      mtime: 1,
      date: 2
    }.freeze

    attr_reader :xapian_document

    def initialize(xapian_document, root_path, file = nil)
      @xapian_document = xapian_document
      @root_path = root_path
      super(xapian_document)
      update_values_from(file) if file
    end

    def path
      @path ||= value(:path)
    end

    def path=(path)
      add_value(:path, path.to_s)
      @path = path
    end

    def mtime
      @mtime ||= Time.strptime(value(:mtime), TIME_FORMAT)
    end

    def actual_mtime
      Time.at(full_path.mtime.to_i)
    end

    def mtime=(time)
      add_value(:mtime, time.strftime(TIME_FORMAT))
      @mtime = time
    end

    def date
      @date ||= Date.strptime(value(:date), DATE_FORMAT)
    end

    def date=(date)
      add_value(:date, date.strftime(DATE_FORMAT))
      @date = date
    end

    def exists?
      full_path.exist?
    end

    def deleted?
      !exists?
    end

    def changed?
      actual_mtime > mtime
    end

    def extension
      path.extname[1..-1]
    end

    def value(slot)
      return super if slot.is_a?(Integer)
      super(VALUE_SLOTS[slot]).force_encoding('UTF-8')
    end

    def add_value(slot, value)
      return super if slot.is_a?(Integer)
      super(VALUE_SLOTS[slot], value)
    end

    def update(db, term_generator)
      index(term_generator)
      db.replace_document(docid, xapian_document)
    end

    def insert(db, term_generator)
      index(term_generator)
      db.add_document(xapian_document)
    end

    def full_path
      @root_path + path
    end

    private

    def index(term_generator)
      update_values_from(full_path)
      clear_terms
      term_generator.document = xapian_document
      index_text(TermGeneratorDecorator.new(term_generator))
    end

    def index_text(term_generator)
      file_indexer = FileIndexer.new(full_path)
      term_generator[:path] = path
      file_indexer.index(term_generator)
    end

    def update_values_from(file)
      self.path = file.relative_path_from(@root_path)
      self.mtime = full_path.mtime
      self.date = mtime.to_date
    end
  end
end
