require 'net/http'
require 'uri'
require 'json'

class Task
  def self.next
    urls = get_urls
    if urls.empty?
      return 0
    else
      return get_image(urls)
    end
  end

  private

  def self.get_image(urls)
    get URI.parse("http://localhost:9001/montage?l=#{urls[0]}&r=#{urls[1]}")
  end

  def self.get_urls
    r = get(URI.parse("http://localhost:9000/next"))
    JSON.parse(r)
  end

  def self.get(uri)
    res = Net::HTTP.get_response(uri)
    res.body
  end
end
