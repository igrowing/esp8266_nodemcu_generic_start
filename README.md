# esp8266_nodemcu_generic_start
All required files to start develop other functional modules.

Implemented:
- Captive screen: the esp8266 dicovers that the module is new (no kept settings) and switches to AP mode. User can dial in from any browser and set the unit properties. Then the unit reboots and connects to your network.
- Settings reset by button: 5 seconds button hold when the unit is powering up (or awaken) will clean all kep settings.

TODO:
- Unify all typical general settings (even optional) in init.lua.
- Add OTA support. Adopt from: <a href="http://www.instructables.com/id/ESP8266-WiFi-File-Management/?ALLSTEPS">here</a>, repo: <a href="https://github.com/breagan/ESP8266_WiFi_File_Manager">here</a>

Public questions:
- Looking for simpler way to upload files esp8266.
