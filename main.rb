require 'net/http' # probably patched cuz of nexus pipe .. gg
require 'uri'
require 'digest/md5'
require 'nokogiri'
require 'artii'

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def cyan
    colorize(36)
  end
end

checkpoints = {
  1 => "https://fluxteam.net/windows/checkpoint/check1.php",
  2 => "https://fluxteam.net/windows/checkpoint/check2.php",
  3 => "https://fluxteam.net/windows/checkpoint/main.php",
}

artii = Artii::Base.new(font: 'block')

puts artii.asciify("Fluxus Key Bypass").cyan
puts "---------------------"
puts "System Info".red
puts "---------------------"
hw_profile_guid = `reg query "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\IDConfigDB\\Hardware Profiles\\0001" /v HwProfileGuid`
hw_profile_guid = hw_profile_guid.split("\n")[2].strip.split("    ")[2].gsub("{", "").gsub("}", "").gsub("-", "")
puts "HwProfileGuid: #{hw_profile_guid}"

system_manufacturer = `reg query "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\SystemInformation" /v SystemManufacturer`
system_manufacturer = system_manufacturer.split("\n")[2].strip.split("    ")[2]
puts "SystemManufacturer: #{system_manufacturer}"

hwid = hw_profile_guid + Digest::MD5.hexdigest(system_manufacturer)
puts "HWID: #{hwid}".green
puts "----------------------------"

puts "Checkpoints".cyan
puts "---------------------"
total_checkpoints = checkpoints.length
successful_checkpoints = 0

headers = {
  "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:113.0) Gecko/20100101 Firefox/113.0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
  "Accept-Language" => "en-US,en;q=0.5",
  "Upgrade-Insecure-Requests" => "1",
  "Sec-Fetch-Dest" => "document",
  "Sec-Fetch-Mode" => "navigate",
  "Sec-Fetch-Site" => "cross-site",
  "Referer" => "https://linkvertise.com/"
}

params = {
  "HWID" => hwid
}

checkpoints.each do |url_index, url|
  headers["Referer"] = "https://linkvertise.com/"

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme == 'https'

  request = Net::HTTP::Get.new(uri.request_uri)
  headers.each { |k, v| request[k] = v }

  response = http.request(request)
  if response.code == "200"
    successful_checkpoints += 1
  end

  puts "Checkpoint #{url_index}/#{total_checkpoints} | #{response.code.green}"

  if url_index == 3
    content_match = response.body.match(/let content = \("(.+?)"\);/)

    if content_match
      content = content_match[1]
      puts "\nKey: #{content}".green
    else
      puts "\nKey has not been found, please run the script again.".red
    end
  end
end

puts "\nOverall Result:".cyan
if successful_checkpoints == total_checkpoints
  puts "All checkpoints passed! You have the key.".green
else
  puts "Not all checkpoints passed. Key retrieval failed.".red
end
