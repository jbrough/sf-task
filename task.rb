require 'net/http'
require 'uri'
require 'json'

class Task
  def self.next
    url1, url2, filename, empty = get_urls
    return nil, nil if empty

    urls = [url1, url2]
    buf, err = get_image(urls)
    return handle_err(urls) if err

    r, err = post(storage_url(filename), buf)
    return handle_err(urls) if err

    return r['Location'], nil
  end

  private

  def self.handle_err(urls)
    post("http://#{ENV['SF_QUEUE_HOST']}/add/error", urls.to_json)
    # TODO: log errors in post, as failures will be missing from both queues
    return nil, nil, nil
  end

  def self.storage_url(name)
    "http://#{ENV['SF_STORAGE_HOST']}/#{name}"
  end

  def self.get_image(urls)
    buf, err = get("http://#{ENV['SF_MONTAGE_HOST']}/montage?l=#{urls[0]}&r=#{urls[1]}")
  end

  def self.get_urls
    r = post("http://#{ENV['SF_QUEUE_HOST']}/next")
    res = JSON.parse(r.body)

    if res['empty']
      return nil, nil, nil, true
    else
      return res['item']
    end
  end

  def self.get(uri)
    res = Net::HTTP.get_response(uri)
    res.body
  end

  def self.get(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)

    if response_ok?(res)
      return res.body, nil
    else
      return nil, "Bad Download Response"
    end
  end

  def self.response_ok?(response)
    # this implicty checks it's not a 404 etc
    response.response.content_type == "image/jpeg"
  end

  def self.post(url, body=nil)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request.body = body
    http.request(request)
  end

end
