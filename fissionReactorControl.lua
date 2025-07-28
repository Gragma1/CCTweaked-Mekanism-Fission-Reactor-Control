-- Mekanism Fission Reactor Control System by Gragma
-- v72825

local REACTOR_NAME = ""
local LOW_COOLANT_PERCENT_THRESHOLD = 0.5
local LOW_FUEL_PERCENT_THRESHOLD = 0.5
local HIGH_HEATED_COOLANT_PERCENT_THRESHOLD = 0.5
local HIGH_WASTE_THRESHOLD = 0.5
local HIGH_TEMPERATURE_THRESHOLD = 1700

-- Treat as emergency instead of warning?
local EMERGENCY_ON_LOW_FUEL = false
local EMERGENCY_ON_HIGH_HEATED_COOLANT = false


local reactor
local coolant_percent
local coolant_type
local fuel_percent
local heated_coolant_percent
local heated_coolant_type
local waste_percent
local temperature
local damage

local is_coolant_low = false
local is_waste_high = false
local is_temperature_high
local is_heated_coolant_high = false
local is_fuel_low = false
local is_damaged = false


local function fetchReactorData()
    coolant_percent = reactor.getCoolantFilledPercentage()
    coolant_type = reactor.getCoolant().name
    fuel_percent = reactor.getFuelFilledPercentage()
    heated_coolant_percent = reactor.getHeatedCoolantFilledPercentage()
    heated_coolant_type = reactor.getHeatedCoolant().type
    waste_percent = reactor.getWasteFilledPercentage()
    temperature = reactor.getTemperature()
    damage = reactor.getDamagePercent()

    is_coolant_low = coolant_percent < LOW_COOLANT_PERCENT_THRESHOLD
    is_fuel_low = fuel_percent < LOW_FUEL_PERCENT_THRESHOLD
    is_heated_coolant_high = heated_coolant_percent > HIGH_HEATED_COOLANT_PERCENT_THRESHOLD
    is_waste_high = waste_percent > HIGH_WASTE_THRESHOLD
    is_temperature_high = temperature > HIGH_TEMPERATURE_THRESHOLD 
    is_damaged = damage > 0
end

local function updateScreen()
    -- update dynamic parts of the screen, eg. percentages and graphs
end

local function isEmergency()
    local conditions = {is_coolant_low, is_waste_high, is_temperature_high, is_damaged}

    for condition in conditions do
        if condition then
            return true
        end
    end

    if EMERGENCY_ON_HIGH_HEATED_COOLANT and is_heated_coolant_high then
        return true
    end

    if EMERGENCY_ON_LOW_FUEL and is_fuel_low then
        return true
    end

    return false
end

reactor = peripheral.find(REACTOR_NAME)

if not reactor then
    print("No reactor found, exiting...")
    return
end

-- TODO draw static parts of the screen, eg. labels

while true do
    -- Normal loop
    while true do
        if not reactor.status() then
            reactor.activate()
        end
        fetchReactorData()
        updateScreen()
        if isEmergency() then
            break
        end
    end

    -- Emergency loop
    while true do
        if reactor.status() then
            reactor.scram()
        end
        fetchReactorData()
        updateScreen()
        if not isEmergency() then
            break
        end
    end
end