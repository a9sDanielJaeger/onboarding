require 'sinatra'
require 'pg'
require 'yaml'

$config = YAML.load_file('config/config.yml')['database']

set :bind, '0.0.0.0'
set :port, 8080

def pg_client
  PG.connect(:host => $config['host'], :port => $config['port'], :dbname => $config['name'], :user => $config['user'], :password => $config['password'])
end

get '/get-all' do
    entries = pg_client.exec "SELECT * FROM \"progLanguages\".languages"

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
    
    entry = pg_client.exec "SELECT * FROM \"progLanguages\".languages WHERE lower(name) = \'#{name_to_look_for}\'"
    
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

    connection = pg_client
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

  result = pg_client.exec "DELETE FROM \"progLanguages\".languages WHERE lower(name) = \'#{name}\'"

  result.res_status(result.result_status)
end

get '/' do
  "The Application is up and running!"
end
