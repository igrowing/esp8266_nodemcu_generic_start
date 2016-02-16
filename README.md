# esp8266_nodemcu_generic_start
All required files to start develop other functional modules.

## [Getting started with iSmart](https://github.com/igrowing/esp8266_nodemcu_generic_start/wiki/Getting-started-with-iSmart "Easy ramp up")


**The idea:**
- This repository includes basic files fo all types of esp8266 modules with no regard to the module function.
- The functional deifferences are posted in parallel repos, one repo per esp8266 module functionality.
- All esp8266 modules are classified to 2 classes:

1. Sensors
2. Actuators

_Sensors_ are esp8266 modules that mainly deeply sleep :) On periodic basis they are awaken, perform required measurements and send update to the network. Sensors are built by HW and written by SW with the main concern of extremely low power consumption. The power should be taken from the ambient.

_Actuators_ are esp8266 modules that mainly are online 24/7. They should be always ready to receive a command from the network and do the action. Actuators are minded to fastest performance.

**Subclasses:**
- Sensors may have a subclass of "greedy" sensors. The "greediness" is defined by higher power consumption. The nature of greedy sensor comes from necessity to report quickly on upcoming changes. Example: human presense sensor, security sensor, etc. This subclass must have better power supply/management than resular sensor.
- Actuators may have a subclass of "lean" actuators. The "leaniness" comes from lower power consumption, resulted with postponed response/action. Example: garden watering actuator. This subclass is not always on and poered in similar to regular sensor way (from ambient). Some actuators may have a sensor function. Example: power switch can sense the current/voltage/power consumption.

<hr>

**Implemented:**
- Captive screen: the esp8266 dicovers that the module is new (no kept settings) and switches to AP mode. User can dial in from any browser and set the unit properties. Then the unit reboots and connects to your network.
- Settings reset by button: 5 seconds button hold when the unit is powering up (or awaken) will clean all kep settings.

**TODO:**
- Unify all typical general settings (even optional) in init.lua.
- Add OTA support. Adopt from: <a href="http://www.instructables.com/id/ESP8266-WiFi-File-Management/?ALLSTEPS">here</a>, repo: <a href="https://github.com/breagan/ESP8266_WiFi_File_Manager">here</a>

**Public questions:**
- Looking for simpler way to upload files to esp8266.
- Is it possible usnig MQTT to transmit data in backward direction: from cloud/broker to the remote sensor? If yes, how?
- How to implement a mirror of IFTTT (or similar functionality) for the case of abrupted Internet connection?
