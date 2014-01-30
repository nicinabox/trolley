require 'trolley/cli'

describe Trolley::CLI do
  let!(:openssl_json) { JSON.parse(File.read('spec/support/openssl.json')) }

  before do
    FakeFS.activate!
    Trolley::Package.any_instance.stub(x64?: false)
    Trolley::Package.any_instance.stub(slackware: '13.1.0')
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  let(:cli) { Trolley::CLI.new }

  describe 'search' do
    it 'returns all packages' do
      allow(Trolley::CLI).to receive(:get) {
        JSON.parse('[
            {
              "id": 1,
              "name": "ConsoleKit"
            }
          ]')
      }

      output = capture(:stdout) { cli.search() }
      output.should == <<-out.outdent
        ConsoleKit
      out
    end

    it 'returns matching packages' do
      allow(Trolley::CLI).to receive(:get) {
        JSON.parse('[
          {
            "id": 1,
            "name": "openssl"
          },
          {
            "id": 2,
            "name": "openssl-solibs"
          }
        ]')
      }


      output = capture(:stdout) { cli.search('openssl') }
      output.should == <<-out.outdent
        openssl         openssl-solibs
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

  describe 'install' do
    before(:each) do
      allow(Trolley::CLI).to receive(:get).and_return(openssl_json)
      allow(HTTParty).to receive(:get).and_return([])
    end

    it 'installs a package by name' do
      output = capture(:stdout) { cli.install('openssl') }
      output.should == <<-out.outdent
        => Downloading openssl (0.9.8y i486)
        => Installing
        => Installed
      out

      File.exists?("/boot/extra/openssl-0.9.8y-i486-1_slack13.1.txz").should be_true
    end

    it 'installs a package by name and version' do
      output = capture(:stdout) { cli.install('openssl', '1.0.1c') }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1c i486)
        => Installing
        => Installed
      out
    end

    it 'installs a package by url' do
      output = capture(:stdout) { cli.install('http://slackware.org.uk/people/alien/restricted_slackbuilds/handbrake/pkg64/14.0/handbrake-0.9.9-x86_64-1alien.txz') }
      output.should == <<-out.outdent
        => Downloading handbrake (0.9.9 x86_64)
        => Installing
        => Installed
      out
    end

    it 'returns error for non-existant package' do
      allow(Trolley::CLI).to receive(:get) { [] }

      output = capture(:stdout) { cli.install('nope') }
      output.should == <<-out.outdent
        => No package named nope
      out
    end

    it 'supports a version constraint' do
      output = capture(:stdout) { cli.install('openssl', '> 1.0') }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1f i486)
        => Installing
        => Installed
      out
    end
  end

  describe 'info' do
    before(:each) do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
      allow(Trolley::CLI).to receive(:get) {
        JSON.parse(File.read('spec/support/openssl.json'))
      }
    end

    it 'shows package details' do
      output = capture(:stdout) { cli.info('openssl') }
      output.should == <<-out.outdent
        Name      openssl
        Summary   openssl (Secure Sockets Layer toolkit)
        Versions  0.9.8n, 0.9.8r, 0.9.8y, 1.0.1c, 1.0.1e, 1.0.1f
      out
    end

    it 'shows package details for a version' do
      output = capture(:stdout) { cli.info('openssl', '0.9.8n') }
      output.should == <<-out.outdent
        Name       openssl
        Summary    openssl (Secure Sockets Layer toolkit)
        Version    0.9.8n
        Arch       i486
        Build      1
        Size       9492480 (2359296 compressed)
        Slackware  13.1
        Patch      no
      out
    end
  end

end
