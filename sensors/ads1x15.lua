SDA = SDA or 1 -- GPIO 5
SCL = SCL or 2 -- GPIO 4
bus = 0        -- Always 0 in ESP8266
ADDR = 0x48    -- GND->0x48, VDD->0x49, SDA->0x4a, SCL->0x4b

MODE = 1       -- Def = 1 (single). 0 -> continuous.
GAIN = 2       -- Def = 2.048V
DRATE = 4      -- Def = 128SPS
COMP_MODE = 0  -- Def = 0 hysteresis-comparator. 1 -> window-comparator.
COMP_POL = 0   -- Def = 0 active-low
COMP_LAT = 0   -- Def = 0 no-latch
COMP_FLT = 0   -- Def = 3. 0 triggers on every threshold pass.

MODE_SINGLE = 1
MODE_CONT = 0
DR_8SPS = 0
DR_16SPS = 1
DR_32SPS = 2
DR_64SPS = 3
DR_128SPS = 4
DR_250SPS = 5
DR_475SPS = 6
DR_860SPS = 7
GAIN_6V = 0
GAIN_4V = 1
GAIN_2V = 2
GAIN_1V = 3
GAIN_05V = 4
GAIN_025V = 5
CMP_MODE_HYST = 0
CMP_MODE_WIND = 1
CMP_ACT_LO = 0
CMP_ACT_HI = 1
CMP_LATCH = 0
CMP_LATCH_NO = 1
CMP_FLT_1 = 0
CMP_FLT_2 = 1
CMP_FLT_4 = 2
CMP_FLT_DIS = 3
MUX_01 = 0
MUX_03 = 1
MUX_13 = 2
MUX_23 = 3
MUX_0G = 4
MUX_1G = 5
MUX_2G = 6
MUX_3G = 7



-- read data register
function _read_reg(reg_addr, length)
  i2c.start(bus)
  i2c.address(bus, ADDR, i2c.TRANSMITTER)
  i2c.write(bus, reg_addr)
  i2c.stop(bus)
  i2c.start(bus)
  i2c.address(bus, ADDR, i2c.RECEIVER)
  c = i2c.read(bus, length)
  i2c.stop(bus)
  if c == nil then return -1
  else return bit.lshift(string.byte(c, 1), 8) + string.byte(c, 2) end
end

-- write data register
function _write_reg(reg_addr, reg_val)
  local val = {}
  if reg_val > 255 then  -- split int to 2-byte array
    val[1] = bit.rshift(bit.band(reg_val, 0xff00), 8)
    val[2] = bit.band(reg_val, 0xff)
  else
    val = {reg_val}
  end  
  i2c.start(bus)
  i2c.address(bus, ADDR, i2c.TRANSMITTER)
  i2c.write(bus, reg_addr)
  for _, v in ipairs(val) do i2c.write(bus, v) end
  i2c.stop(bus)
  return #val
end

-- read modify write register. mask: 1->care, 0->don't care.
function _rmw(reg, length, mask, value)
    c = _read_reg(reg, length)
    print("Read conf =", string.format("%x", c)) 
    res = bit.bor(bit.band(bit.bnot(mask), c), bit.band(mask, new))
    return _write_reg(reg, res)
end

function init(sda, scl, addr)
  SDA = sda or SDA
  SCL = scl or SCL
  ADDR = addr or ADDR
  i2c.setup(bus, SDA, SCL, i2c.SLOW)
end

-- Set mode single/continuous, data rate: 8/16/32/64/128/250/475/860 SPS, gain
function config(mode, data_rate, gain)
    MODE = (mode ~= nil and mode >= 0 and mode <= 1) ? mode : MODE
    if data_rate ~= nil and data_rate >= 0 and data_rate < 7 then DRATE = data_rate end
    if gain ~= nil and gain >= 0 and gain <= 7 then GAIN = gain end
    new = bit.lshift(GAIN, 9) + bit.lshift(MODE, 8) + bit.lshift(DRATE, 5)
    return _rmw(1, 2, 0xfe0, new)
end

-- Set multiplexer 0+1, 2+3 or every single AIN. Use in conversion...
function set_mux(input)
    input = (input ~= nil and input >= 0 and input <= 7) ? input : 0
    return _rmw(1, 2, 0x7000, bit.lshift(input, 12))
end

-- Set comparator: mode, polarity, latching, filter
function set_comp(mode, polarity, latching, filter)
    COMP_MODE = (mode ~= nil and mode >= 0 and mode <= 1) ? mode : COMP_MODE
    COMP_POL = (polarity ~= nil and polarity >= 0 and polarity <= 1) ? polarity : COMP_POL
    COMP_LAT = (latching ~= nil and latching >= 0 and latching <= 1) ? latching : COMP_LAT
    COMP_FLT = (filter ~= nil and filter >= 0 and filter <= 3) ? filter : COMP_FLT
    new = bit.lshift(COMP_MODE, 4) + bit.lshift(COMP_POL, 3) + bit.lshift(COMP_LAT, 2) + COMP_FLT
    return _rmw(1, 2, 0x1f, new)
end

-- Set thresholds for comparator trigger: hi and lo, 16bit/register
function set_thresholds(high, low)
    _write_reg(2, low)
    _write_reg(3, high)
end

-- Read thresholds of comparator trigger: hi and lo, 16bit/register
function get_thresholds()
    return _read_reg(3, 2), _read_reg(2, 2)
end

-- Read single value
function read_value()
    if MODE == MODE_SINGLE then
        _rmw(1, 2, 0x8000, 0x8000)
        while _read_reg(1, 2) <= 0x8000 do tmr.delay(1) end
    end
    return _read_reg(0, 2)
end

-- Examples:
-- Read single value from separated port.
init()
config(,,GAIN_6V)
set_mux(MUX_0G)
print(read_value())


-- Read continuosly from compared ports.
init()
config(MODE_CONT, DR_860SPS, GAIN_4V)
set_mux(MUX_01)
t = {}
for i=1,100 do 
    t[i] = read_value() 
    tmr.delay(100)
done
print(table.concat(t, ','))


-- Wait until interrupt is asserted by threshold.
init()
config(MODE_CONT, DR_8SPS, GAIN_2V)
set_mux(MUX_01)
set_comp(,,,CMP_FLT_2)
set_thresholds(0x3fff, 0x07ff)
gpio.mode(7, gpio.INT, gpio.PULLUP)  -- GPIO 13
gpio.trig(7, 'both', function(level) print("Level:", level) end)
