ENV['RACK_ENV'] = 'test'
require_relative  "../main"
require "spec_helper"
require "rspec"

describe "POST /add" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    it "returns status 400 name contains illegal characters" do
        post '/add', "name=te5t&creation-date=1990-01-01&founder=someFounder"
        expect(last_response.status).to eq(400)
    end

    it "returns status 400 date contains illegal characters" do
        post '/add', "name=test&creation-date=199X-01-01&founder=someFounder"
        expect(last_response.status).to eq(400)
    end

    it "returns status 400 founder contains illegal characters" do
        post '/add', "name=test&creation-date=1990-01-01&founder=someFound3r"
        expect(last_response.status).to eq(400)
    end

    it "returns status 200" do
        post '/add', "name=test&creation-date=1990-01-01&founder=someFounder"
       expect(last_response.status).to eq(200)
    end
end

describe "GET /get" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    it "retrieves specific entry with status 200" do
        get '/get?name=test'
        expect(last_response.status).to eq(200)
    end

    it "retrieves no entry with status 400 wrong character" do
        get '/get?name=py1hon'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq("Names can only contain letters, spaces and dashes and must not be longer than 20 characters!")
    end

    it "retrieves no entry with status 400 wrong size" do
        get '/get?name=thiswordcontainswaytoomanycharacters'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq("Names can only contain letters, spaces and dashes and must not be longer than 20 characters!")
    end

    it "retrives no entry with status 404 name was not found" do
        get '/get?name=notindatabase'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq("Could not find notindatabase in database")
    end
end 

describe "GET /get-all" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    it "retrieves all entries of the database" do
        get '/get-all'
        expect(last_response.status).to eq(200)
    end
end

describe "POSST /delete" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    it "returns status 200" do
        post '/delete', "name=test"
        expect(last_response.status).to eq(200)
    end
end