local worona = require "worona"

local function newNetworkService()

  local network = {}

  function network:getArgs( query )
    query_pos = string.find( query, "%?" ) --: get position of the ?
    if query_pos ~= nil then
      query = string.sub( query, query_pos+1 ) --: remove everything before that

      local parsed = {}
      local pos = 0

      query = string.gsub(query, "&amp;", "&")
      query = string.gsub(query, "&lt;", "<")
      query = string.gsub(query, "&gt;", ">")

      local function ginsert(qstr)
        local first, last = string.find(qstr, "=")
        if first then
          parsed[string.sub(qstr, 0, first-1)] = string.sub(qstr, first+1)
        end
      end

      while true do
        local first, last = string.find(query, "&", pos)
        if first then
          ginsert(string.sub(query, pos, first-1));
          pos = last+1
        else
          ginsert(string.sub(query, pos));
          break;
        end
      end
      return parsed
    else
      return nil
    end
  end

  function network:checkConnection(website, timeout)

    --: private variables :--
    local website = website or "www.google.com" -- if you want to test your site instead, use: string.gsub( worona.wp_url, "[htps]*://", "") -- Note that the test does not work if we put http:// in front
    local timeout = timeout or 3
    local connection_available

    local socket = require("socket")

    local test = socket.tcp()
    test:settimeout( 3 )

    local testResult = test:connect( website, 80)

    if testResult ~= nil then
      worona.log:info("content/checkConnection: Internet access to " .. website .. " is available")
      connection_available = true
    else
      worona.log:info("content/checkConnection: Internet access to " .. website .. " is not available")
      connection_available = false
    end

    test:close()
    test = nil

    return connection_available
  end

  return network

end

worona:do_action( "register_service", { service = "network", creator = newNetworkService } )
