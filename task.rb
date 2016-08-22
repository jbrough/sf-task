require 'net/http'
require 'uri'
require 'json'
require 'digest'

# TODO: Error handling
class Task
  def self.next
    urls = get_urls
    if urls.empty?
      return nil
    else
      buf = get_image(urls)
      r = post(storage_uri(urls), buf)
      return r['Location']
    end
  end

  private

  def self.storage_uri(urls)
    name = Digest::SHA256.hexdigest(urls.to_json)
    URI.parse("http://#{ENV['SF_STORAGE_HOST']}/#{name}")
  end

  def self.get_image(urls)
    get URI.parse("http://#{ENV['SF_MONTAGE_HOST']}/montage?l=#{urls[0]}&r=#{urls[1]}")
  end

  def self.get_urls
    r = post(URI.parse("http://#{ENV['SF_QUEUE_HOST']}/next"))
    JSON.parse(r.body)
  end

  def self.get(uri)
    res = Net::HTTP.get_response(uri)
    res.body
  end

  def self.post(uri, body=nil)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request.body = body
    http.request(request)
  end

end
