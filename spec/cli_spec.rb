require 'trolley/cli'

describe Trolley::CLI do
  let(:cli) { Trolley::CLI.new }

  describe 'search' do
    it 'returns matching packages' do
      output = capture(:stdout) { cli.search('openssl') }
      output.should == <<-out.outdent
        openssl
        openssl-solibs
      out
    end
  end

end
