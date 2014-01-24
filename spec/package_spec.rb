require 'json'
require 'trolley/base'
require 'trolley/package'

describe Trolley::Package do
  context "with no version" do
    before(:each) do
      @package = Trolley::Package.new(
        JSON.parse(File.read('spec/support/openssl.json'))
      )
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
      @package = Trolley::Package.new(
        JSON.parse(File.read('spec/support/openssl.json')),
        '1.0.1c'
      )
    end

    it ".version" do
      @package.version.should include 'version' => '1.0.1c'
    end
  end

  context "with bogus version" do
    before(:each) do
      @package = Trolley::Package.new(
        JSON.parse(File.read('spec/support/openssl.json')),
        '0.0.0'
      )
    end

    it ".version" do
      pending
      @package.should raise_error NoVersionError
    end
  end
end
