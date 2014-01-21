require 'trolley/cli'

describe Trolley::CLI do
  let(:cli) { Trolley::CLI.new }

  describe 'search' do
    it 'returns all packages' do
      output = capture(:stdout) { cli.search() }
      output.should include <<-out.outdent
        ConsoleKit
        M2Crypto
        MPlayer
        PyQt
        QScintilla
        a2ps
      out
    end

    it 'returns matching packages' do
      output = capture(:stdout) { cli.search('openssl') }
      output.should == <<-out.outdent
        openssl
        openssl-solibs
      out
    end
  end

end
