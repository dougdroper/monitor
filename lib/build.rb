require "net/https"

class Build
  def update(state)
    REDIS.set("status", state)
    notify_monitor
    message_pushover
  end

  def notify_monitor
    Pusher['test_channel'].trigger('state', {
      :status => status,
      :number => number,
      :velocity => velocity
    })
  end

  def update_masters(data)
    branch = data["name"]
    status = data["build"]["status"]

    Pusher['masters_channel'].trigger('state', {
      :status => status,
      :branch => branch
    })
  end

  def message_pushover
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      :token => PUSH_TOKEN,
      :user => PUSH_USER,
      :message => status,
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end

  def phase_for(data)
    if data["build"]["phase"] == "STARTED"
      "building"
    else
      state_for(data["build"]["status"])
    end
  end

  def set_number(n)
    REDIS.set("number", n) unless n == number
  end

  def number
    REDIS.get("number") || 0
  end

  def status
    REDIS.get("status") || "unknown"
  end

  def velocity
    REDIS.get("velocity") || 0
  end

  def velocity=(v)
    REDIS.set("velocity", v)
  end

  def retrieve_velocity
    JSON.parse(RestClient.get(
        P_URL + "/projects/#{PROJECT}?fields=current_velocity", "X-TrackerToken" => "#{TOKEN}"
      )
    )["current_velocity"]
  end

  def test_connection
    JSON.parse(RestClient::Resource.new('http://ci.noths.com/job/master-features-notonthehighstreet/api/json?depth=1', {:user => ENV["J_USER"], :password => ENV["J_PASS"]}, :headers => { :accept => :json, :content_type => :json }).get)
  end

  def update_whodunit(data)
    puts "******************************"
    puts data.inspect
    puts "******************************"
    Pusher['who_channel'].trigger('state', {
      :who => data["name"] || "andrew"
    })
  end

  private

  def state_for(state)
    {"FAILURE" => "red", "SUCCESS" => "green"}[state]
  end
end
