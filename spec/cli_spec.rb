require 'trolley/cli'

describe Trolley::CLI do
  let!(:base_response) {
    {
      last_modified: Date.new(2010, 1, 15).to_s,
      content_length: '1024',
      request_object: HTTParty::Request.new(Net::HTTP::Get, '/'),
      response_object: Net::HTTPOK.new('1.1', 200, 'OK')
    }
  }

  let!(:openssl_response) {
    file = File.read('spec/support/openssl.json')

    base_response[:response_object].stub(:body => file)
    base_response[:response_object]['last-modified'] = base_response[:last_modified]
    base_response[:response_object]['content-length'] = base_response[:content_length]
    parsed_response = lambda { JSON.parse(file) }
    HTTParty::Response.new(base_response[:request_object], base_response[:response_object], parsed_response)
  }

  let!(:kernel_headers_response) {
    file = File.read('spec/support/kernel-headers.json')

    base_response[:response_object].stub(:body => file)
    base_response[:response_object]['last-modified'] = base_response[:last_modified]
    base_response[:response_object]['content-length'] = base_response[:content_length]
    parsed_response = lambda { JSON.parse(file) }
    HTTParty::Response.new(base_response[:request_object], base_response[:response_object], parsed_response)
  }

  let!(:ca_certs_response) {
    file = File.read('spec/support/ca-certificates.json')

    base_response[:response_object].stub(:body => file)
    base_response[:response_object]['last-modified'] = base_response[:last_modified]
    base_response[:response_object]['content-length'] = base_response[:content_length]
    parsed_response = lambda { JSON.parse(file) }
    HTTParty::Response.new(base_response[:request_object], base_response[:response_object], parsed_response)
  }

  let(:not_found_response) {
    not_found_response = base_response

    not_found_response[:response_object] = Net::HTTPOK.new('1.1', 404, 'Not Found')
    not_found_response[:response_object].stub(:body => '{"status":"404","error":"Not Found"}')
    not_found_response[:response_object]['last-modified'] = not_found_response[:last_modified]
    not_found_response[:response_object]['content-length'] = not_found_response[:content_length]
    parsed_response = lambda { JSON.parse(not_found_response[:response_object].body) }
    HTTParty::Response.new(not_found_response[:request_object], not_found_response[:response_object], parsed_response)
  }

  before do
    FakeFS.activate!
    Trolley::Package.any_instance.stub(x64?: false)
    Trolley::Package.any_instance.stub(slackware: '13.1.0')
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

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

      output = capture(:stdout) { Trolley::CLI.start(['search']) }
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


      output = capture(:stdout) { Trolley::CLI.start(['search', 'openssl']) }
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
      output = capture(:stdout) { Trolley::CLI.start(['list']) }
      output.should == <<-out.outdent
        curl     7.20.1
        openssh  5.9p1
        python   2.6.6
        ruby     1.9.3_p484
        trolley  0.1.12
      out
    end

    it "returns installed packages, filtered" do
      output = capture(:stdout) { Trolley::CLI.start(['list', 'curl']) }
      output.should == <<-out.outdent
        curl  7.20.1
      out
    end
  end

  describe 'install' do
    before(:each) do
      allow(Trolley::CLI).to receive(:get).and_return(openssl_response)
      allow(HTTParty).to receive(:get).and_return([])
    end

    it 'by name' do
      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl']) }
      output.should == <<-out.outdent
        => Downloading openssl (0.9.8y i486)
        => Installing
        => Installed
      out

      allow(Trolley::CLI).to receive(:get).and_return(kernel_headers_response)
      output1 = capture(:stdout) { Trolley::CLI.start(['install', 'kernel-headers']) }
      output1.should == <<-out.outdent
        => Downloading kernel-headers (2.6.33.4_smp x86)
        => Installing
        => Installed
      out

      allow(Trolley::CLI).to receive(:get).and_return(ca_certs_response)
      output1 = capture(:stdout) { Trolley::CLI.start(['install', 'ca-certificates']) }
      output1.should == <<-out.outdent
        => Downloading ca-certificates (20130906 noarch)
        => Installing
        => Installed
      out

      File.exists?("/boot/extra/openssl-0.9.8y-i486-1_slack13.1.txz").should be_true
    end

    it 'by name and version' do
      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl', '1.0.1c']) }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1c i486)
        => Installing
        => Installed
      out
    end

    it 'by url' do
      Trolley::Package.any_instance.stub(x64?: true)
      output = capture(:stdout) { Trolley::CLI.start(['install', 'http://slackware.org.uk/people/alien/restricted_slackbuilds/handbrake/pkg64/14.0/handbrake-0.9.9-x86_64-1alien.txz']) }
      output.should == <<-out.outdent
        => Downloading handbrake (0.9.9 x86_64)
        => Installing
        => Installed
      out
    end

    it 'does not install an existing package' do
      FileUtils.mkdir_p '/var/log/packages/openssl-0.9.8y-i486-1_slack13.1'

      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl']) }
      output.should == <<-out.outdent
        => Using openssl (0.9.8y)
      out
    end

    it 'force installs an exitsing package' do
      FileUtils.mkdir_p '/var/log/packages/openssl-0.9.8y-i486-1_slack13.1'

      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl', '-f']) }
      output.should == <<-out.outdent
        => Downloading openssl (0.9.8y i486)
        => Installing
        => Installed
      out
    end

    it 'returns error for non-existant package' do
      allow(Trolley::CLI).to receive(:get) { not_found_response }

      output = capture(:stdout) { Trolley::CLI.start(['install', 'nope']) }
      output.should == <<-out.outdent
        => No package named nope
      out
    end

    it 'supports a version constraint' do
      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl', '> 1.0']) }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1f i486)
        => Installing
        => Installed
      out
    end

    it 'supports keyword: latest' do
      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl', 'latest']) }
      output.should == <<-out.outdent
        => Downloading openssl (1.0.1f i486)
        => Installing
        => Installed
      out
    end
  end

  describe 'update' do
    before(:each) do
      allow(Trolley::CLI).to receive(:get).and_return(openssl_response)
      allow(HTTParty).to receive(:get).and_return([])
    end

    it 'installs a newer version of an existing package' do
      FileUtils.mkdir_p '/var/log/packages/openssl-0.9.8r-i486-3'
      FileUtils.mkdir_p '/boot/extra/openssl-0.9.8r-i486-3.txz'

      output = capture(:stdout) { Trolley::CLI.start(['install', 'openssl']) }
      output.should == <<-out.outdent
        => Downloading openssl (0.9.8y i486)
        => Installing
        => Installed
      out

      File.exists?("/boot/extra/openssl-0.9.8r-i486-3.txz").should be_false
      File.exists?("/boot/extra/openssl-0.9.8y-i486-1_slack13.1.txz").should be_true
    end
  end

  describe 'info' do
    before(:each) do
      allow(Trolley::CLI).to receive(:get).and_return(openssl_response)
      allow(HTTParty).to receive(:get).and_return([])
    end

    it 'shows package details' do
      output = capture(:stdout) { Trolley::CLI.start(['info', 'openssl']) }
      output.should == <<-out.outdent
        Name      openssl
        Summary   openssl (Secure Sockets Layer toolkit)
        Versions  0.9.8n, 0.9.8r, 0.9.8y, 1.0.1c, 1.0.1e, 1.0.1f
      out
    end

    it 'shows extra details if installed' do
      FileUtils.mkdir_p('/var/log/packages')
      FileUtils.touch('/var/log/packages/openssl-0.9.8y-i486-1_slack13.1')
      output = capture(:stdout) { Trolley::CLI.start(['info', 'openssl']) }
      output.should == <<-out.outdent
        Name      openssl
        Summary   openssl (Secure Sockets Layer toolkit)
        Versions  0.9.8n, 0.9.8r, 0.9.8y, 1.0.1c, 1.0.1e, 1.0.1f
        => openssl (0.9.8y) is installed
      out
    end

    it 'shows package details for a version' do
      output = capture(:stdout) { Trolley::CLI.start(['info', 'openssl', '0.9.8n']) }
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
