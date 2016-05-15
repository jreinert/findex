# Findex

Findex is a command line file indexing tool. It performs full text indexing
with [Xapian](http://xapian.org) as Backend and allows a great deal of
customization via a simple DSL.

## Installation

    $ gem install findex

## Usage

### Indexing

    $ findex index [path]

### Searching

    $ findex search [path] -- some xapian search query

The following prefixes are available by default:

- `date` - the mtime of the document (allows [value range queries](http://xapian.org/docs/valueranges.html)
- `path` - the relative path of the file

## DSL

Findex will add a directory `.findex` in the indexed path. This directory
contains the database and a `config.rb` file.  This way you can move your
indexed directory to another location without affecting the index. This also
simplifies backups.

You can customize the behavior of the index by editing `config.rb`.

### Options

Below are the available options for Findex with their defaults. It should give
you an idea how to change them to fit your needs.

``` ruby
indexer.stem_language = 'none'
```

### Mimetypes

Findex uses libmagic to determine the mimetypes of files to be indexed. To
configure special handling for pdf files you could add the following to your
`config.rb`:

``` ruby
indexer.on('application/pdf') do |file, index|
  metadata = `pdfinfo "#{file}"`.lines.map { |l| l.chomp.split(/:\s+/) }.to_h
  index[:title] = metadata["Title"]
  index[:author] = metadata["Author"]
  index << `pdf2text "#{file}" -`
end
```

An example search query:

    $ findex search path/to/my/library -- author:'Jules Verne'

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jreinert/findex.

