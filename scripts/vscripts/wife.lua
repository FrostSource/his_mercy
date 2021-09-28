
--[[
    User1 = Respawned
    User2 = Disappeared
    User3 = Moved towards player
    User4 = Caught player
]]

CHASE_DISAPPEAR_DISTANCE = CHASE_DISAPPEAR_DISTANCE or 10240
CHASE_TIME_NORMAL = CHASE_TIME_NORMAL or 2--1.7
CHASE_TIME_AGGRO = CHASE_TIME_AGGRO or 2--1
THINK_INTERVAL = THINK_INTERVAL or 0
SPAWN_RANGE = SPAWN_RANGE or 350
ChaseTime = ChaseTime or CHASE_TIME_NORMAL
LastChaseTime = LastChaseTime or 0
CurrentMoveTarget = CurrentMoveTarget or nil
CannotMoveCount = CannotMoveCount or 0
KillDistance = KillDistance or 35

---@param activateType "0"|"1"|"2"
function Activate(activateType)
    --thisEntity:SetThink(Thinker, "Thinker", 0.01)
    --thisEntity:SetThink(ChaseThink, "ChaseThink", 0.01)
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "point_teleport" then
            thisEntity:SetContext("spawn_point_name", child:GetName(), 0)
            child:Kill()
        end
    end
    Disappear()
end

function Thinker()
    --DoEntFireByInstanceHandle(thisEntity, "SetAnimGraphParameter", "head_twitch="..RandomInt(0,180), 0, nil, nil)
    DoEntFireByInstanceHandle(thisEntity, "SetAnimGraphParameter", "head_twitch=0", 0, nil, nil)
    --thisEntity:SetGraphParameterFloat("head_twitch", RandomFloat(0,180))
    --thisEntity:SetGraphParameterVector("head_twitch_pos", Vector(RandomInt(-9, 9),RandomInt(-30,30),RandomInt(-10,10)))
    --local eye = thisEntity:EyePosition()
    --local d = 512
    --thisEntity:SetGraphParameterVector("head_twitch_pos", eye+Vector( RandomInt(-d, d) , RandomInt(-d,d) , eye.z ))
    --thisEntity:SetGraphParameterVector("head_twitch_pos", eye+Vector( RandomInt(-d, d) , RandomInt(-256,-) , eye.z ))

    --print('active', thisEntity:GetGraphParameter("head_twitch"))
    return 0.5
end

function SetSpawn(name)
    thisEntity:SetContext("spawn_point_name", name, 0)
end

function GetRandomNormal()
    return Vector(RandomFloat(-1,1),RandomFloat(-1,1),RandomFloat(-1,1))
end

function Respawn()
    print("Wife spawning")
    CannotMoveCount = 0
    local player_pos = Entities:GetLocalPlayer():GetOrigin()
    local usable_spawns = {}
    for _, spawn in ipairs(Entities:FindAllByName(thisEntity:GetContext("spawn_point_name"))) do
        if VectorDistance(spawn:GetOrigin(), player_pos) >= SPAWN_RANGE then
            usable_spawns[#usable_spawns+1] = spawn
        end
    end
    print(#usable_spawns.." spawns far enough away from player")
    if #usable_spawns > 0 then
        local final_spawn = usable_spawns[RandomInt(1, #usable_spawns)]
        print("Chose spawn at "..tostring(final_spawn:GetOrigin()), "distance: "..VectorDistance(final_spawn:GetOrigin(),player_pos))
        thisEntity:SetRenderAlpha(255)
        thisEntity:SetOrigin(final_spawn:GetOrigin())
        thisEntity:SetForwardVector(final_spawn:GetForwardVector())
        GetProxy():SetOrigin(final_spawn:GetOrigin())
        DoEntFireByInstanceHandle(thisEntity, "DisableRandomLookAts", "", 0, nil, nil)
        DoEntFireByInstanceHandle(thisEntity, "LookAtIgnoreHands", "", 0, nil, nil)
        DoEntFireByInstanceHandle(thisEntity, "EnableLookAt", "", 0, nil, nil)
        DoEntFireByInstanceHandle(thisEntity, "ForceLookAtTarget", "!player", 0, nil, nil)
        DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, nil, nil)
    else
        print("No spawn point far enough away from player")
        Disappear()
    end
end

function Disappear()
    print("Wife disappearing")
    CannotMoveCount = 0
    thisEntity:SetRenderAlpha(0)
    thisEntity:SetOrigin(Vector(999,999,999))
    GetProxy():SetOrigin(Vector(999,999,999))
    --ScreenShake(Vector(0,0,0), 0, 0, 0, 0, 1, false)
    thisEntity:StopThink("ChaseThink")
    DoEntFire(thisEntity:GetName().."_sched_move_to_player", "StopSchedule", "", 0, nil, nil)
    DoEntFireByInstanceHandle(thisEntity, "FireUser2", "", 0, nil, nil)
end

function ChasePlayer()
    print("Wife chasing player")
    LastChaseTime = Time()
    DoEntFireByInstanceHandle(thisEntity, "ForceLookAtTarget", thisEntity:GetName().."_head_twitch_target", 0, nil, nil)
    --local player_pos = Entities:GetLocalPlayer():GetOrigin()
    --local amount = RemapValClamped(512 - VectorDistance(thisEntity:GetOrigin(), player_pos), 512, 0, 0, 10)
    --ScreenShake(player_pos, amount, 15, 999, 64, 0, false)
    thisEntity:SetThink(ChaseThink, "ChaseThink", ChaseTime)
    DoEntFire(thisEntity:GetName().."_sched_move_to_player", "StartSchedule", "", 0, nil, nil)
end

function EnableAggro()
    print("Wife aggro")
    ChaseTime = CHASE_TIME_AGGRO
end
function DisableAggro()
    print("Wife not aggro")
    ChaseTime = CHASE_TIME_NORMAL
end

function GetProxy()
    return Entities:FindByName(nil, thisEntity:GetName().."_movement_proxy")
end

function TraceToPlayer()
    local traceTable = {
        startpos = thisEntity:GetAttachmentOrigin(thisEntity:ScriptLookupAttachment("head")),
        endpos = Entities:GetLocalPlayer():EyePosition(),
        ignore = thisEntity,
    }
    TraceLine(traceTable)
    if traceTable.hit then
        return traceTable.enthit
    else
        return nil
    end
end

function ChaseThink()
    local player = Entities:GetLocalPlayer()

    -- play breathing sound here

    --kill player
    if VectorDistance(thisEntity:GetOrigin(), player:GetOrigin()) < KillDistance then
        DoEntFire("relay_kill_player", "Trigger", "", 0, nil, nil)
        return
    end

    if Time() - LastChaseTime >= ChaseTime  then
        -- disappear when between door
        local trace = TraceToPlayer()
        if trace and trace:GetClassname() == "prop_door_rotating_physics" then
            return Disappear()
        end
        -- Move towards player
        -- this delay was used for the prefab fade effect that's no longer used
        --thisEntity:SetContextThink("move", function()
        --    Move()
        --    thisEntity:EmitSound("his_mercy.gore.movement")
        --end, 0.1)
        local outcome = Move()
        if outcome == 1 then
            thisEntity:EmitSound("his_mercy.gore.movement")
            DoEntFireByInstanceHandle(thisEntity, "FireUser3", "", 0, nil, nil)
        elseif outcome == 2 then
            -- Player dead
            DoEntFireByInstanceHandle(thisEntity, "FireUser4", "", 0, nil, nil)
        end
        -- update chase time
        LastChaseTime = Time()
        -- update entity to look at target, if not using this line stops looking at target after moving
        DoEntFireByInstanceHandle(thisEntity, "ForceLookAtTarget", thisEntity:GetName().."_head_twitch_target", 0.11, nil, nil)
    end

    -- disappear if far away
    if VectorDistance(player:GetOrigin(), thisEntity:GetOrigin()) >= CHASE_DISAPPEAR_DISTANCE then
        local trace = TraceToPlayer()
        if trace and trace:GetClassname() ~= "player" then
            return Disappear()
        end
    end

    local head_twitch_target = Entities:FindByName(nil, thisEntity:GetName().."_head_twitch_target")
    if head_twitch_target then
        --head_twitch_target:SetLocalOrigin(thisEntity:EyePosition() + GetRandomNormal() * 16)
        head_twitch_target:SetOrigin( thisEntity:GetAttachmentOrigin(thisEntity:ScriptLookupAttachment("head")) + GetRandomNormal() * 16 )
        --debugoverlay:Sphere(head_twitch_target:GetOrigin(), 1, 255, 0, 0, 255, false, 0.05)
    end

    return THINK_INTERVAL
end

function Move()
    local proxy = GetProxy()
    if proxy and VectorDistance(proxy:GetOrigin(), thisEntity:GetOrigin()) > 1 then
        print("wife moving to proxy")
        thisEntity:SetOrigin(proxy:GetOrigin())
        thisEntity:SetForwardVector(proxy:GetForwardVector())
        return 1
    else
        CannotMoveCount = CannotMoveCount + 1
        if CannotMoveCount > 6 then
            Disappear()
        end
        print("proxy not found or too close to proxy")
        return 0
    end
end

--[[ function Move()
    local start_pos = thisEntity:GetOrigin()
    local player_pos = Entities:GetLocalPlayer():GetOrigin()
    -- Movement direction is towards player
    local move_direction = (player_pos - start_pos):Normalized()
    if VectorDistance(start_pos, player_pos) <= 64 then
        --player dead
        print("too close to player to move")
        return 2
    end
    local move_distance = 32
    local new_pos = start_pos + move_direction * ((move_distance / 2) + 1)
    local nearest_move_target = Entities:FindByNameNearest("@wife_move_target", new_pos, 2048)
    if nearest_move_target and CurrentMoveTarget ~= nearest_move_target then
        CurrentMoveTarget = nearest_move_target
        local distance_to_player = VectorDistance(new_pos, player_pos)
        local distance_to_target = VectorDistance(new_pos, nearest_move_target:GetOrigin())
        if distance_to_target <= distance_to_player then
            thisEntity:SetOrigin(nearest_move_target:GetOrigin())
        end
        thisEntity:SetForwardVector(Vector(move_direction.x, move_direction.y, 0))
        return 1
    else
        print("couldn't find move target or found current move target")
    end
    -- New direction could be facing player or towards target
    --if start_pos ~= new_pos then
    --    local new_direction = (thisEntity:GetOrigin() - start_pos):Normalized()
    --    thisEntity:SetForwardVector(new_direction)
    --end
    return 0
end ]]
