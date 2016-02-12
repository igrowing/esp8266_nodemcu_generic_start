function run_setup()
    wifi.setmode(wifi.SOFTAP)
    cfg={}
    cfg.ssid="SHM"..node.chipid()
    wifi.ap.config(cfg)

    print("Opening WiFi credentials portal")
    dofile ("dns-liar.lc")
    dofile ("server.lc")
end

function read_wifi_credentials()
    -- TODO: Add here check of pressed button for 3 sec.
    -- If button pressed then remove netconfig file
    
    if file.open("netconfig.lc", "r") then
        dofile('netconfig.lc')
        file.close()
    end

	-- set DNS to second slot if configured.
	if wifi_dns ~= nil or wifi_dns ~= '' then net.dns.setdnsserver(wifi_dns, 1) end
	
    if wifi_ssid ~= nil and wifi_ssid ~= "" and wifi_password ~= nil then
        return wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw, wifi_desc
    end
    return nil, nil, nil, nil, nil, nil
end

function try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wifi_ssid, wifi_password)
    wifi.sta.connect()
    wifi.sta.autoconnect(1)
    -- Set IP if no DHCP required
    if wifi_ip ~= "" then wifi.sta.setip({ip=wifi_ip, netmask=wifi_nm, gateway=wifi_gw}) end

    tmr.alarm(0, 1000, 1, function()
        if wifi.sta.status() ~= 5 then
          print("Connecting to AP...")
        else
          tmr.stop(1)
          tmr.stop(0)
          print("Connected as: " .. wifi.sta.getip())
          collectgarbage()
          -- TODO: Add your functionality here to do AFTER connection established.
          --
        end
    end)

    tmr.alarm(1, 8000, 0, function()
        if wifi.sta.status() ~= 5 then
            tmr.stop(0)
            print("Failed to connect to \"" .. wifi_ssid .. "\"")
            run_setup()
        end
    end)
end

-------------------------
------  MAIN  -----------
-------------------------
dofile("button_setup.lc")  -- uses timer 5
wifi.sta.disconnect()
wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw, wifi_desc = read_wifi_credentials()
-- TODO: Add your functionality here to do BEFORE connection established.
--
if wifi_ssid ~= nil and wifi_password ~= nil then
    print("Retrieved stored WiFi credentials")
    print("---------------------------------")
    print("wifi_ssid     : " .. wifi_ssid)
    print("wifi_password : " .. wifi_password)
    print("wifi_ip : " .. wifi_ip)
    print("wifi_nm : " .. wifi_nm)
    print("wifi_gw : " .. wifi_gw)
    print("wifi_desc : " .. wifi_desc)
    try_connecting(wifi_ssid, wifi_password, wifi_ip, wifi_nm, wifi_gw)
else
    run_setup()
end
