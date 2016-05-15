require 'spec_helper'
require 'findex/document_decorator'

module Findex
  describe DocumentDecorator do
    let(:document) do
      instance_double('Xapian::Document')
    end

    let(:decorator) do
      DocumentDecorator.new(document)
    end

    context 'path' do
      context '#path' do
        it 'accesses the value in slot 0 of the wrapped document' do
          expect(document).to receive(:value).with(0)
          decorator.path
        end

        it 'caches the value' do
          expect(document).to receive(:value).with(0).and_return('test').once
          2.times { decorator.path }
        end
      end

      context '#path=' do
        it 'adds the value to slot 0 of the wrapped document' do
          expect(document).to receive(:add_value).with(0, 'test')
          decorator.path = 'test'
        end

        it 'caches the value' do
          allow(document).to receive(:add_value).with(0, 'test')
          path = 'test'
          decorator.path = path
          expect(decorator.path).to be(path)
        end
      end
    end

    context 'mtime' do
      let(:time) do
        Time.at(Time.now.to_i)
      end

      let(:time_string) do
        time.strftime(DocumentDecorator::TIME_FORMAT)
      end

      context '#mtime' do
        it 'accesses the value in slot 1 of the wrapped document' do
          expect(document).to receive(:value).with(1).and_return(time_string)
          decorator.mtime
        end

        it 'parses the value into a Time object' do
          allow(document).to receive(:value).with(1).and_return(time_string)
          expect(decorator.mtime).to eq(time)
        end

        it 'caches the value' do
          expect(document).to(
            receive(:value).with(1).and_return(time_string).once
          )
          2.times { decorator.mtime }
        end
      end

      context '#mtime=' do
        it 'converts and adds the value to slot 1 of the wrapped document' do
          expect(document).to receive(:add_value).with(1, time_string)
          decorator.mtime = time
        end

        it 'caches the value' do
          allow(document).to receive(:add_value).with(1, time_string)
          decorator.mtime = time
          expect(decorator.mtime).to be(time)
        end
      end
    end

    context 'date' do
      let(:date) do
        Date.today
      end

      let(:date_string) do
        date.strftime(DocumentDecorator::DATE_FORMAT)
      end

      context '#date' do
        it 'accesses the value in slot 2 of the wrapped document' do
          expect(document).to receive(:value).with(2).and_return(date_string)
          decorator.date
        end

        it 'parses the value into a Date object' do
          allow(document).to receive(:value).with(2).and_return(date_string)
          expect(decorator.date).to eq(date)
        end

        it 'caches the value' do
          expect(document).to(
            receive(:value).with(2).and_return(date_string).once
          )
          2.times { decorator.date }
        end
      end

      context '#date=' do
        it 'converts and adds the value to slot 2 of the wrapped document' do
          expect(document).to receive(:add_value).with(2, date_string)
          decorator.date = date
        end

        it 'caches the value' do
          allow(document).to receive(:add_value).with(2, date_string)
          decorator.date = date
          expect(decorator.date).to be(date)
        end
      end
    end

    context 'exists?' do
      it 'returns true only if the file in path exists' do
        allow(decorator).to receive(:path).and_return(__FILE__)
        expect(decorator.exists?).to be(true)
        allow(decorator).to receive(:path).and_return('/some/random/path')
        expect(decorator.exists?).to be(false)
      end
    end

    context 'changed?' do
      it "returns true only if the file's mtime is newer than the stored one" do
        mtime = File.mtime(__FILE__)
        allow(decorator).to receive(:path).and_return(__FILE__)
        allow(decorator).to receive(:mtime).and_return(mtime - 1000)
        expect(decorator.changed?).to be(true)
        allow(decorator).to receive(:mtime).and_return(mtime)
        expect(decorator.changed?).to be(false)
      end
    end

    context 'extension' do
      it 'returns the correct extension for the stored path' do
        allow(decorator).to receive(:path).and_return(__FILE__)
        expect(decorator.extension).to eq('rb')
      end
    end
  end
end
