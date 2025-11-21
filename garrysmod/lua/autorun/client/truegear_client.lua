local vehicleTime = 0
local lastSpeed = 0
local lastRPM = 0
local lastPlayerHealth = 100
local physgunBeamTime = 0

function split(str, sep)
	assert(type(str) == 'string' and type(sep) == 'string', 'The arguments must be <string>')
	if sep == '' then return {str} end
	
	local res, from = {}, 1
	repeat
	  local pos = str:find(sep, from)
	  res[#res + 1] = str:sub(from, pos and pos - 1)
	  from = pos and pos + #sep
	until not from
	return res
end

function SendMessage(content)
    print("[TrueGear] :{" .. content .."}\n")
end

--///////////////////////////////////////////////////////////////

-- net.Receive("PlayerWeaponReloadLogToClient", function()
--     local logText = net.ReadString()
--     SendMessage(logText)
-- end)

local canGrabItem = true

net.Receive("TrueGearPlayerGrabLogToServer", function()
    local logBool = net.ReadBool()
    if canGrabItem then
        if logBool then
            SendMessage("LeftHandGrabItem")
        else
            SendMessage("RightHandGrabItem")
        end
        canGrabItem = false
    end
    
    
end)

net.Receive("TrueGearPlayerReleaseLogToServer", function()
    local logString = net.ReadString()
    SendMessage(logString)
    canGrabItem = true
end)



net.Receive("PlayerTeleportLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerGrabItemLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("WeaponFireLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerJumpLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerDeathLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerHurtLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerSwitchWeaponLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerHitGroundLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerSwitchFlashlightLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("PlayerPostThinkLogToClient", function()
    local logText = net.ReadString()
    
    if lastPlayerHealth < tonumber(logText) then
        SendMessage("PlayerHealing")
    end

    lastPlayerHealth = tonumber(logText)
end)

net.Receive("DoAnimationLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("EntityTakeDamageLogToClient", function()
    local logText = net.ReadString()
    SendMessage(logText)
end)

net.Receive("VehicleMoveLogToClient", function()
    local logText = net.ReadString()

    local vehicleData = split(logText, ",")
    local speed = tonumber(vehicleData[1])
    local rmp = tonumber(vehicleData[2])
    local steering = tonumber(vehicleData[3])
    local throttle = tonumber(vehicleData[4])

    if os.clock() - vehicleTime < 0.1 then
        return
    end
    vehicleTime = os.clock()
    local acc = (speed - lastSpeed) / 0.1
    lastSpeed = speed
    if acc <= -100 then
        SendMessage("VehicleCollision")
    end
    if lastRPM ~= rmp and rmp > 1000 then
        local result = math.floor(rmp / 1000)
        if result > 5 then
            result = 5
        end
        SendMessage("RPM" .. result)
    end
    lastRPM = rmp
    if acc ~= 0 and steering > 0 then
        local result = math.floor(steering / 0.2)
        SendMessage("TurnRight" .. result)
    elseif acc ~= 0 and steering < 0 then
        local result = math.floor(steering / 0.2)
        SendMessage("TurnLeft" .. math.abs(result))
    end
    if rmp == 0 and throttle > 0 then
        local result = math.floor(steering / 0.2)
        SendMessage("Throttle" .. result)
    end

    -- SendMessage(logText)
end)

--///////////////////////////////////////////////////////////////



hook.Add( "OnEntityCreated", "TrueGearOnEntityCreated", function( entity)    
    if entity:IsValid() and entity:GetOwner():IsPlayer() and entity:GetOwner() == LocalPlayer() then
        if string.find(entity:GetClass(),"prop_combine_ball") or string.find(entity:GetClass(),"crossbow_bolt") or string.find(entity:GetClass(),"rpg_missile") or string.find(entity:GetClass(),"hunter_flechette") then
            SendMessage("ShotgunShoot")
        elseif string.find(entity:GetClass(),"_grenade") or string.find(entity:GetClass(),"_satchel") then
            SendMessage("ThrowItem")
        end
        print("OnEntityCreated")
        print(entity:GetParent())
        print(entity:GetClass())
        print(entity:GetOwner())
        print("SERVER:", SERVER, "CLIENT:", CLIENT)
    end
end )

hook.Add( "DrawPhysgunBeam", "TrueGearDrawPhysgunBeam", function(ply,physgun,enabled,target,physBone,hitPos)
    if enabled and ply == LocalPlayer() then
        if os.clock() - physgunBeamTime < 0.1 then
            return
        end
        physgunBeamTime = os.clock()
        print("DrawPhysgunBeam")
        print(ply)
        print("SERVER:", SERVER, "CLIENT:", CLIENT)
        SendMessage("PhysgunBeamShoot")
    end
end )

hook.Add( "HUDAmmoPickedUp", "TrueGearHUDAmmoPickedUp", function(  )
    print("HUDAmmoPickedUp")
    SendMessage("PickUpItem")
end )

hook.Add( "HUDItemPickedUp", "TrueGearHUDItemPickedUp", function(  )
    print("HUDItemPickedUp")
    SendMessage("PickUpItem")
end )

hook.Add( "HUDWeaponPickedUp", "TrueGearHUDWeaponPickedUp", function(  )
    print("HUDWeaponPickedUp")
    SendMessage("PickUpItem")
end )











