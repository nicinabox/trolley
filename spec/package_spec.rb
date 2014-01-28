require 'json'
require 'trolley/base'
require 'trolley/package'

describe Trolley::Package do
  let(:openssl_json) { JSON.parse(File.read('spec/support/openssl.json')) }

  context "with no version" do
    before(:each) do
      @package = Trolley::Package.new(openssl_json)
    end

    it ".name" do
      @package.name.should == 'openssl'
    end

    it ".versions" do
      @package.versions.count.should == 8
    end

    it ".version" do
      @package.version.should include 'version' => '1.0.1f'
    end
  end

  context "with a version" do
    before(:each) do
      @package = Trolley::Package.new(openssl_json, '1.0.1c')
    end

    it ".version" do
      @package.version.should include 'version' => '1.0.1c'
    end
  end

  context 'with version constraints' do
    it 'supports >' do
      package = Trolley::Package.new(openssl_json, '> 0.9.8')
      package.version['version'].should == '1.0.1f'
    end

    it 'supports <' do
      package = Trolley::Package.new(openssl_json, '< 1.0.0')
      package.version['version'].should == '0.9.8y'
    end

    it 'supports =' do
      package = Trolley::Package.new(openssl_json, '= 1.0.1c')
      package.version['version'].should == '1.0.1c'
    end

    it 'supports ~>' do
      package = Trolley::Package.new(openssl_json, '~> 1.0.1c')
      package.version['version'].should == '1.0.1f'
    end

    it 'supports >=' do
      package = Trolley::Package.new(openssl_json, '>= 1.0.1c')
      package.version['version'].should == '1.0.1f'
    end

    it 'supports <=' do
      package = Trolley::Package.new(openssl_json, '<= 1.0.1c')
      package.version['version'].should == '1.0.1c'
    end
  end
end
