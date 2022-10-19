require 'sinatra'
require 'pg'
require 'yaml'

$config = YAML.load_file('config/config.yml')['database']

set :bind, '0.0.0.0'
set :port, 8080

def find_service_key_in_json(data)
  service_name = ""
  data.keys.each do |next_key|
    service_name = next_key if next_key.include?('postgresql')
  end

  service_name
end

def setup_database(connection)
  connection.exec "CREATE SCHEMA IF NOT EXISTS \"progLanguages\""
  connection.exec "CREATE TABLE IF NOT EXISTS \"progLanguages\".languages  (name VARCHAR ( 20 ) PRIMARY KEY, creation_date date NOT NULL, founder VARCHAR ( 20 ) NOT NULL);"
end

def pg_client
  if ENV["VCAP_SERVICES"].nil?
    connection = PG.connect(:host => $config["host"], :port => $config["port"], :dbname => $config["name"], :user => $config["user"], :password => $config["password"])
    setup_database(connection)
    connection
  else
    data = JSON.parse(ENV["VCAP_SERVICES"])
    service_name = find_service_key_in_json(data)
    raise Exception.new "no database service found" if service_name.empty?
    connection = PG.connect(:host => data[service_name][0]["credentials"]["host"], :port => data[service_name][0]["credentials"]["port"], :dbname => data[service_name][0]["credentials"]["name"], :user => data[service_name][0]["credentials"]["username"], :password => data[service_name][0]["credentials"]["password"])
    setup_database(connection)
    connection
  end
end

get '/get-all' do
    begin
      entries = pg_client.exec "SELECT * FROM \"progLanguages\".languages"
    rescue Exception => e
      status 500
      return e.message
    end

    status 404
    return "There is no entry" if entries.result_status == 0
   
    status 200
    entries.map do |entry|
        JSON[entry] + "\n"
    end
end

get '/get' do

    name_to_look_for = params["name"].downcase

    status 400
    return "Names can only contain letters, spaces and dashes and must not be longer than 20 characters!" unless name_to_look_for.match(/^[a-z\s-]{1,20}$/)
    
    begin
      entry = pg_client.exec "SELECT * FROM \"progLanguages\".languages WHERE lower(name) = \'#{name_to_look_for}\'"
    rescue Exception => e
      status 500
      return e.message
    end
    
    status 404
    return "Could not find #{name_to_look_for} in database" if entry.values.length == 0

    status 200
    entry.map do |value|
        JSON[value]
    end
end

post '/add' do
    status 400
    creation_date = params["creation-date"]
    return "The given creation date is not in the format yyyy-mm-dd!" unless creation_date.match(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/)

    name = params["name"]
    return "Names must not contain characters other than letters, spaces and dashes(-) and can have 20 characters at most" unless name.match(/^[a-zA-Z\s-]{1,20}$/)

    founder = params["founder"]
    return "Founders must not contain characters other than letters, spaces and dashes(-) and can have 20 characters at most" unless founder.match(/^[a-zA-Z\s-]{1,20}$/)

    connection = nil
    begin
      connection = pg_client
    rescue Exception => e
      status 500
      return e.message
    end
    result = connection.exec "SELECT * FROM \"progLanguages\".languages WHERE name = \'#{name}\'"

    return "Programming language already exists!" if result.values.length > 0

    status 200

    result = connection.exec "INSERT INTO \"progLanguages\".languages(
        name, creation_date, founder)
        VALUES ('#{name}', '#{creation_date}', '#{founder}');"
    

    result.res_status(result.result_status)
end

post '/delete' do
  name = params["name"].downcase

  begin
    result = pg_client.exec "DELETE FROM \"progLanguages\".languages WHERE lower(name) = \'#{name}\'"
  rescue Exception => e
    status 500
    return e.message
  end

  result.res_status(result.result_status)
end

get '/' do
  "The Application is up and running! Hurray!"
end
