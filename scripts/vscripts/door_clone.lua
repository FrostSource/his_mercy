
function Activate()
    if thisEntity:GetClassname() == "phys_hinge" then return end
    --thisEntity:SetThink(DebugThink, "DebugThink", 0.1)

    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetModelName() == "models/interaction/anim_interact/doorhandle/doorhandle.vmdl" then
            child:Kill()
            local handle = Entities:FindByName(nil, thisEntity:GetName().."_handle1")
            print( thisEntity:GetName().."_handle1")
            handle:SetParent(thisEntity, "handle")
            handle:SetLocalOrigin(Vector(-0.031250, 0.000086, 0.000056))
            handle:SetLocalAngles(89.996803, 89.995049, 0.000000)
        elseif child:GetModelName() == "models/interaction/anim_interact/doorhandle/doorhandle_flipped.vmdl" then
            child:Kill()
            local handle = Entities:FindByName(nil, thisEntity:GetName().."_handle2")
            handle:SetParent(thisEntity, "handle")
            handle:SetLocalOrigin(Vector(0.000000, 0.000086, 0.000000))
            handle:SetLocalAngles(89.990486, 90.004936, 0.000000)
        end
    end
end

function Lock()
    --DoEntFireByInstanceHandle(thisEntity, "Lock", "", 0, nil, nil)
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            DoEntFireByInstanceHandle(child, "SetCompletionValueC", "0.01", 0, nil, nil)
        end
    end
end
function Unlock()
    --DoEntFireByInstanceHandle(thisEntity, "Unlock", "", 0, nil, nil)
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            DoEntFireByInstanceHandle(child, "SetCompletionValueC", "-1", 0, nil, nil)
        end
    end
end

function DebugThink()
    --local angle_diff = AngleDiff(starting_angle, thisEntity:GetAngles().y)
    local angle_diff = math.floor(AngleDiff(Entities:FindByName(nil, "mud2_hinge"):GetAngles().y, thisEntity:GetAngles().y))
    print(angle_diff)
    if angle_diff ~= 0 then
        DoEntFire("mud", "DisableLatch", "", 0, nil, nil)
        if angle_diff < 0 then
            --DoEntFire("mud_hinge", "SetMaxLimit", tostring(-angle_diff), 0, nil, nil)
        elseif angle_diff > 0 then
            --DoEntFire("mud_hinge", "SetMinLimit", tostring(-angle_diff), 0, nil, nil)
        end
        --DoEntFire("mud", "RetractLatch", "", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetMinLimit", "-90", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetMaxLimit", "90", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetHingeFriction", "0", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetAngularVelocity", tostring(-angle_diff * 10000), 0, nil, nil)

        local door = Entities:FindByName(nil, "mud")
        --door:ApplyLocalAngularVelocityImpulse(Vector(-angle_diff * 10000,-angle_diff * 10000,-angle_diff * 10000))
        door:ApplyAbsVelocityImpulse(Vector(0,10000,0))
        --DoEntFire("mud_hinge", "SetMinLimit", "-90", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetMaxLimit", "90", 0, nil, nil)
        --DoEntFire("mud_hinge", "SetAngularVelocity", "100", 0, nil, nil)
    end
    return 2
end

function Clone(data)
    local door_to_clone = data.caller
    print(door_to_clone:GetName(), door_to_clone:GetClassname())
    local door_to_clone_hinge = Entities:FindByName(nil, door_to_clone:GetName().."_hinge")
    print(door_to_clone, door_to_clone_hinge)
    local angle_diff = AngleDiff( door_to_clone:GetAngles().y , door_to_clone_hinge:GetAngles().y )
    local spawn_angle = QAngle(0, thisEntity:GetAngles().y+90, 0)
    print("spawn angle", "0 "..spawn_angle.y.." 0")
    print("my y", thisEntity:GetAngles().y)
    print("hinge y", door_to_clone_hinge:GetAngles().y)
    print("angle_diff", angle_diff)
    SpawnEntityFromTableSynchronous("prop_door_rotating_physics",{
        --origin = thisEntity:GetOrigin(),
        --angles = "0 "..angle_diff.." 0",
        --angles = "0 "..spawn_angle.y.." 0",
        --targetname = thisEntity:GetName(),
        targetname = "SDF",
        --vscripts = "door_clone",
        model = door_to_clone:GetModelName(),
        --spawnpos = "3",
        --ajarangle = tostring(angle_diff)
    })
    --thisEntity:Kill()
    --door_to_clone:Kill()
end
