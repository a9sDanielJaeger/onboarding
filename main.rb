require 'sinatra'
require 'pg'

set :bind, '0.0.0.0'
set :port, 4567

#Going to be killed for having a password written right here
$database_password = 'AvyQji-VR-9Ndwh'
$database_host = 'localhost'
$database_port = '5432'
$database_name = 'ProgrammingLanguages'
$database_user = 'postgres'

get '/get-all' do
    connection = PG.connect(:host => $database_host, :port => $database_port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    entries = connection.exec "SELECT * FROM \"progLanguages\".languages"

    if entries.result_status == 0
        return "There is no entry"
    end

    entries.map do |entry|
        JSON[entry] + "\n"
    end
end

get '/get' do
    connection = PG.connect(:host => $database_host, :port => $database_port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    name_to_look_for = params["name"].downcase

    if !name_to_look_for.match(/^[a-z\s-]{1,20}$/)
        return "Names can only contain letters, spaces and dashes and must not be longer than 20 characters!"
    end
    
    entry = connection.exec "SELECT * FROM \"progLanguages\".languages WHERE lower(name) = \'#{name_to_look_for}\'"
    
    if entry.values.length == 0
        return "Could not find #{name_to_look_for} in database"
    end

    entry.map do |value|
        JSON[value]
    end
end

post '/add' do
    name = params["name"]
    creation_date = params["creation-date"]
    founder = params["founder"]

    if !creation_date.match(/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/)
        return "The given creation date is not in the format yyyy-mm-dd!"
    end

    if !name.match(/^[a-zA-Z\s-]{1,20}$/)
        return "Names must not contain characters other than letters, spaces and dashes(-) and can have 20 characters at most"
    end

    if !founder.match(/^[a-zA-Z\s-]{1,20}$/)
        return "Founders must not contain characters other than letters, spaces and dashes(-) and can have 20 characters at most"
    end

    connection = PG.connect(:host => $database_host, :port => $database_port, :dbname => $database_name, :user => $database_user, :password => $database_password)

    result = connection.exec "SELECT * FROM \"progLanguages\".languages WHERE name = \'#{name}\'"

    if result.values.length > 0
        return "Programming language already exists!"
    end

    result = connection.exec "INSERT INTO \"progLanguages\".languages(
        name, creation_date, founder)
        VALUES ('#{name}', '#{creation_date}', '#{founder}');"
    
    #if result.result_status == 1
    #    "Successfully added entry in table!"
    #else
    #    "#Ups! Something went wrong."
    #end

    result.res_status(result.result_status)
end