require 'yaml'
require 'rubygems'
require 'gmail'
require 'net/http'

class Url_checker
  def get_status_code

    # Read in Files

    filename = "urls.txt"

    list = File.new(filename, "r")

    websites_from_file = list.readlines

    list.close

    # Loop Websites

    status_codes = {"exception" => []}
    
    websites_from_file.each do |websites|
      begin
        res = Net::HTTP.get_response(URI.parse(URI.encode(websites.strip)))
        puts res.code

      if !status_codes.key?(res.code) then 
        status_codes[res.code] = []
      end

      status_codes[res.code].push(websites.strip)

      # Catch Exceptions
      
      rescue Exception
        puts "Malformed Error"
        status_codes["exception"].push(websites.strip)
      end
    end
      return status_codes
  end
end



check_urls = Url_checker.new

status_codes = check_urls.get_status_code

emailbody = "These are the urls for 200 #{status_codes["200"]}. These are the urls for 404 #{status_codes["404"]}"

  #Send Email

config = YAML.load_file("cred.yml")

gmail = Gmail.connect(config["config"]["email"], config["config"]["password"])

email = gmail.compose do
  to config["config"]["to"]
  subject "I did it!"
  body "#{emailbody}"

end

email.deliver!

gmail.logout




