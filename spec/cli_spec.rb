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

  describe 'install' do
    before(:each) do
      FileUtils.mkdir_p('/boot/extra')
      FileUtils.touch('/boot/extra/openssl-0.9.8n-i486-1.txz')
        allow(Trolley::CLI).to receive(:get).and_return(
          JSON.parse('{
            "id": 635,
            "name": "openssl",
            "versions": [
              {
                "id": 635,
                "version": "0.9.8n",
                "build": "i486",
                "arch": "i486",
                "patch": false,
                "size_compressed": 2359296,
                "size_uncompressed": 9492480,
                "summary": "openssl (Secure Sockets Layer toolkit)",
                "description": "openssl (Secure Sockets Layer toolkit)\n\nThe OpenSSL certificate management tool and the shared libraries that provide various encryption and decryption algorithms and protocols.\n\nThis product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org).  This product includes cryptographic software written by Eric Young (eay@cryptsoft.com).  This product includes software written by Tim Hudson (tjh@cryptsoft.com).",
                "tarball_name": "openssl-0.9.8n-i486-1",
                "file_name": "openssl-0.9.8n-i486-1.txz",
                "path": "/slackware/slackware-13.1/slackware/n/openssl-0.9.8n-i486-1.txz",
                "slackware": "13.1"
              },
              {
                "id": 2914,
                "version": "1.0.1c",
                "build": "i486",
                "arch": "i486",
                "patch": false,
                "size_compressed": 2899968,
                "size_uncompressed": 11878400,
                "summary": "openssl (Secure Sockets Layer toolkit)",
                "description": "openssl (Secure Sockets Layer toolkit)\n\nThe OpenSSL certificate management tool and the shared libraries that provide various encryption and decryption algorithms and protocols.\n\nThis product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org).  This product includes cryptographic software written by Eric Young (eay@cryptsoft.com).  This product includes software written by Tim Hudson (tjh@cryptsoft.com).",
                "tarball_name": "openssl-1.0.1c-i486-3",
                "file_name": "openssl-1.0.1c-i486-3.txz",
                "path": "/slackware/slackware-14.0/slackware/n/openssl-1.0.1c-i486-3.txz",
                "slackware": "14.0"
              }
            ]
          }'),
        []
      )
    end

    it 'installs a package by name' do
      output = capture(:stdout) { cli.install('openssl') }
      output.should == <<-out.outdent
        => Downloading openssl (0.9.8n)
        => Installing
        => Installed
      out

      File.exists?("/boot/extra/openssl-0.9.8n-i486-1.txz").should be_true
    end

    it 'installs a package by name and version' do
      output = capture(:stdout) { cli.install('openssl', '1.0.1c') }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1c)
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
  end

end
