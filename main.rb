require 'sinatra'
require 'pg'

set :bind, '0.0.0.0'
set :port, 4567

$database_password = 'AvyQji-VR-9Ndwh'
$host = 'localhost'
$port = '5432'
$database_name = 'ProgrammingLanguages'
$database_user = 'postgres'

get '/get-all' do
    connection = PG.connect(:host => $host, :port => $port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    entries = connection.exec "SELECT * FROM \"progLanguages\".languages"

    entries.map do |entry|
        JSON[entry] + "\n"
    end
end

get '/get' do
    connection = PG.connect(:host => $host, :port => $port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    value_to_look_for = params["name"]
    entry = connection.exec "SELECT * FROM \"progLanguages\".languages WHERE name = \'#{value_to_look_for}\'"
    
    entry.map do |value|
        JSON[value]
    end
end

post '/add' do
    name = params["name"]
    creation_date = params["creation-date"]
    founder = params["founder"]

    connection = PG.connect(:host => $host, :port => $port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    result = connection.exec "SELECT * FROM \"progLanguages\".languages WHERE name = \'#{name}\'"

    if result.values.length > 0
        return "Programming language already exists!"
    end

    result = connection.exec "INSERT INTO \"progLanguages\".languages(
        name, creation_date, founder)
        VALUES ('#{name}', '#{creation_date}', '#{founder}');"
    
    if result.result_status == 1
        "Successfully added entry in table!"
    else
        "#Ups! Something went wrong."
    end

end