require 'trolley/cli'

describe Trolley::CLI do
  before do
    FakeFS.activate!
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  let(:cli) { Trolley::CLI.new }

  describe 'search' do
    it 'returns all packages' do
      allow(Trolley::CLI).to receive(:get) {
        [
          {
            id: 1,
            name: 'ConsoleKit'
          }
        ]
      }

      output = capture(:stdout) { cli.search() }
      output.should == <<-out.outdent
        ConsoleKit
      out
    end

    it 'returns matching packages' do
      allow(Trolley::CLI).to receive(:get) {
        [
          {
            id: 1,
            name: 'openssl'
          },
          {
            id: 2,
            name: 'openssl-solibs'
          }
        ]
      }


      output = capture(:stdout) { cli.search('openssl') }
      output.should == <<-out.outdent
        openssl
        openssl-solibs
      out
    end
  end

  describe 'list' do
    before(:each) do
      FileUtils.mkdir_p("/var/log/packages")
      packages = [
        "ruby-1.9.3_p484-i486-1_slack14.1",
        "python-2.6.6-i486-1",
        "curl-7.20.1-i486-1",
        "trolley-0.1.12-noarch-unraid",
        "openssh-5.9p1-i486-2_slack13.37"
      ]
      packages.each do |p|
        FileUtils.touch "/var/log/packages/#{p}"
      end

    end

    it 'returns installed packages' do
      output = capture(:stdout) { cli.list() }
      output.should == <<-out.outdent
        curl     7.20.1
        openssh  5.9p1
        python   2.6.6
        ruby     1.9.3_p484
        trolley  0.1.12
      out
    end

    it "returns installed packages, filtered" do
      output = capture(:stdout) { cli.list('curl') }
      output.should == <<-out.outdent
        curl  7.20.1
      out
    end
  end

end
