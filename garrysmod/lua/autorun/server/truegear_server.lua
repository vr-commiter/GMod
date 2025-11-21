util.AddNetworkString("PlayerGrabItemLogToClient")
util.AddNetworkString("PlayerTeleportLogToClient")
util.AddNetworkString("WeaponFireLogToClient")
util.AddNetworkString("PlayerJumpLogToClient")
util.AddNetworkString("PlayerDeathLogToClient")
util.AddNetworkString("PlayerHurtLogToClient")
util.AddNetworkString("PlayerSwitchWeaponLogToClient")
util.AddNetworkString("PlayerHitGroundLogToClient")
util.AddNetworkString("PlayerSwitchFlashlightLogToClient")
util.AddNetworkString("PlayerPostThinkLogToClient")
util.AddNetworkString("DoAnimationLogToClient")
util.AddNetworkString("EntityTakeDamageLogToClient")
util.AddNetworkString("VehicleMoveLogToClient")

--/////////////////////////////////////////////////////////////

function GetEnemyRelativeAngle(player, enemy)
    if not IsValid(player) or not IsValid(enemy) then return nil end

    local plyPos = player:GetPos()
    local enemyPos = enemy:GetPos()
    local dir = enemyPos - plyPos
    dir.z = 0

    local plyYaw = player:EyeAngles().y

    local enemyYaw = math.deg(math.atan2(dir.y, dir.x))
    local relativeYaw = enemyYaw - plyYaw

    if relativeYaw < 0 then
        relativeYaw = relativeYaw + 360
    end

    return relativeYaw
end

--/////////////////////////////////////////////////////////////


net.Receive("TrueGearPlayerTeleportLogToServer", function()
    local logText = net.ReadString()
    local logEntity = net.ReadEntity()
    print("Serve Recive Teleport")
    net.Start("PlayerTeleportLogToClient")
        net.WriteString(logText)
    net.Send(logEntity)
end)

net.Receive("TrueGearPlayerGrabLogToServer", function()
    local logBool = net.ReadBool()
    local logEntity = net.ReadEntity()
    print(logBool)
    print(logEntity)
end)

net.Receive("TrueGearPlayerReleaseLogToServer", function()
    local logEntity = net.ReadEntity()
    print(logEntity)
end)


--/////////////////////////////////////////////////////////////

hook.Add("PostEntityFireBullets", "TrueGearPostEntityFireBullets_Server", function(entity)
    if not IsValid(entity) or not entity:IsPlayer() then
        return
    end
    
    local weapon = entity:GetActiveWeapon()
    if not IsValid(weapon) then
        return
    end
    
    local weaponClass = weapon:GetClass():lower() 
    local fireType = "PistolShoot"
    
    if string.find(weaponClass, "shotgun") then
        fireType = "ShotgunShoot"
    elseif string.find(weaponClass, "smg") then
        fireType = "SMGShoot"
    elseif string.find(weaponClass, "ar") or string.find(weaponClass, "rifle") then
        fireType = "RifleShoot"
    end

    net.Start("WeaponFireLogToClient")
        net.WriteString(fireType)
    net.Send(entity)
end)

hook.Add("OnPlayerJump", "TrueGearOnPlayerJump", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end

    net.Start("PlayerJumpLogToClient")
        net.WriteString("PlayerJump")
    net.Send(ply)
end)

hook.Add( "PlayerDeath", "TrueGearPlayerDeath", function( victim )
    if not IsValid(victim) or not victim:IsPlayer() then
        return
    end
    net.Start("PlayerDeathLogToClient")
        net.WriteString("PlayerDeath")
    net.Send(victim)
end )   

hook.Add( "PlayerHurt", "TrueGearPlayerHurt", function( victim, attacker )
    if not IsValid(victim) or not victim:IsPlayer() then
        return
    end

    local hurtType = "NoDirectionDamage"
    if victim == attacker then
        hurtType = "NoDirectionDamage"
    else
        if not attacker:IsValid() then
            hurtType = "NoDirectionDamage"
        else
            local angle = GetEnemyRelativeAngle(victim,attacker)
            hurtType = "DefaultDamage," .. angle .. ",0"
        end        
    end
    net.Start("PlayerHurtLogToClient")
        net.WriteString(hurtType)
    net.Send(victim)
end )  

hook.Add( "PlayerSwitchWeapon", "TrueGearPlayerSwitchWeapon", function(  player,  oldWeapon,  newWeapon )
    if not IsValid(player) or not player:IsPlayer() then
        return
    end
    net.Start("PlayerSwitchWeaponLogToClient")
        net.WriteString("PlayerSwitchWeapon")
    net.Send(player)
end )

hook.Add( "OnPlayerHitGround", "TrueGearOnPlayerHitGround", function( player )
    if not IsValid(player) or not player:IsPlayer() then
        return
    end
    net.Start("PlayerHitGroundLogToClient")
        net.WriteString("PlayerFall")
    net.Send(player)
end )

hook.Add( "EntityTakeDamage", "TrueGearEntityTakeDamage", function( target,dmg  )
    if dmg:GetAttacker() == nil or not IsValid(dmg:GetAttacker()) or not dmg:GetAttacker():IsPlayer() then
        return
    end
    local damageMessage = nil
    if dmg:GetDamageType() == 128 or dmg:GetDamageType() == 0 then
        damageMessage = "MeleeHit"
    elseif dmg:GetDamageType() == 8388608 and string.find(dmg:GetWeapon():GetClass(),"cannon") then 
        damageMessage = "ShotgunShoot"
    end
    if damageMessage == nil then
        return
    end
    net.Start("EntityTakeDamageLogToClient")            
        net.WriteString(damageMessage)
    net.Send(dmg:GetAttacker())
end )

hook.Add( "VehicleMove", "TrueGearVehicleMove", function( ply,veh,mv )
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end
    local logText = string.format(
        "%s,%s,%s,%s",
        veh:GetSpeed(),
        veh:GetRPM(),
        veh:GetSteering(),
        veh:GetThrottle()
    )
    net.Start("VehicleMoveLogToClient")
        net.WriteString(logText)
    net.Send(ply)
end )

hook.Add( "PlayerSwitchFlashlight", "TrueGearPlayerSwitchFlashlight", function( ply )
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end
    net.Start("PlayerSwitchFlashlightLogToClient")
        net.WriteString("PlayerSwitchFlashlight")
    net.Send(ply)
end )

hook.Add( "PlayerPostThink", "TrueGearPlayerPostThink", function( ply )
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end
    net.Start("PlayerPostThinkLogToClient")
        net.WriteString(ply:Health())
    net.Send(ply)
end )

hook.Add( "DoAnimationEvent", "TrueGearDoAnimationEvent", function( ply, event, data )
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end
    if event == 0 and string.find(ply:GetActiveWeapon():GetClass(),"gmod_tool") then 
        net.Start("DoAnimationLogToClient")
            net.WriteString("PistolShoot")
        net.Send(ply)
    end
end )