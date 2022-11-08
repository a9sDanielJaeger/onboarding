ENV['RACK_ENV'] = 'test'
require_relative  "../greeting"
require "spec_helper"
require "rspec"


describe "prints a greeting for specific person" do
  include Rack::Test::Methods

  it "returns Hello Peter" do
    greetingInstance = Greeting.new

    result = greetingInstance.greetPerson("Peter")
    expect(result).to eq("Hello Dieter!")
  end


end
