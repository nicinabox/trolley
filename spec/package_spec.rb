require 'json'
require 'trolley/base'
require 'trolley/package'

describe Trolley::Package do
  let(:openssl_json) { JSON.parse(File.read('spec/support/openssl.json')) }
  let(:receiver) { double("receiver") }

  before(:each) do
    Trolley::Package.any_instance.stub(x64: false)
  end

  context "with no version" do
    before(:each) do
      @package = Trolley::Package.new(openssl_json)
    end

    it ".name" do
      @package.name.should == 'openssl'
    end

    it ".versions" do
      @package.versions.count.should == 10
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
    context '32 bit' do
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

    context '64 bit' do
      before(:each) do
        Trolley::Package.any_instance.stub(x64: true)
      end

      it 'supports >' do
        package = Trolley::Package.new(openssl_json, '> 0.9.8')
        package.version['version'].should == '1.0.1f'
      end

      it 'supports <' do
        expect {
          Trolley::Package.new(openssl_json, '< 1.0.0')
        }.to raise_error
      end

      it 'supports =' do
        expect {
          Trolley::Package.new(openssl_json, '= 1.0.1c')
        }.to raise_error
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
        expect {
          Trolley::Package.new(openssl_json, '<= 1.0.1c')
        }.to raise_error
      end
    end
  end

  context 'with matching arch' do
    before(:each) do
    end

    it ".version for i486" do
      @package = Trolley::Package.new(openssl_json, '> 1.0.1c')
      @package.version.should include 'version' => '1.0.1f'
      @package.version.should include 'arch' => 'i486'
    end

    it ".version for x86_64" do
      Trolley::Package.any_instance.stub(x64: true)

      @package = Trolley::Package.new(openssl_json, '> 1.0.1c')
      @package.version.should include 'version' => '1.0.1f'
      @package.version.should include 'arch' => 'x86_64'
    end
  end
end
