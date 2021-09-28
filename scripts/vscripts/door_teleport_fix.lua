
--[[ function Activate()
    local index = 1
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            local origin = child:GetLocalOrigin()
            thisEntity:Attribute_SetFloatValue("originx"..index, origin.x)
            thisEntity:Attribute_SetFloatValue("originy"..index, origin.y)
            thisEntity:Attribute_SetFloatValue("originz"..index, origin.z)
            local angles = child:GetLocalAngles()
            thisEntity:Attribute_SetFloatValue("anglesx"..index, angles.x)
            thisEntity:Attribute_SetFloatValue("anglesy"..index, angles.y)
            thisEntity:Attribute_SetFloatValue("anglesz"..index, angles.z)
            index = index + 1
        end
    end
end

function Fix()
    print(thisEntity:GetName())
    local index = 1
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            child:SetLocalOrigin(values[index].origin)
            child:SetLocalAngles(values[index].angles.x,values[index].angles.y,values[index].angles.z)
            index = index + 1
        end
    end
end ]]

function Activate()
    if thisEntity:GetClassname() == "phys_hinge" then return end

    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetModelName() == "models/interaction/anim_interact/doorhandle/doorhandle.vmdl" then
            child:Kill()
            local handle = Entities:FindByName(nil, thisEntity:GetName().."_handle1")
            --if handle == nil then debugoverlay:Sphere(thisEntity:GetOrigin(),64,255,0,0,255,true,100) end
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

function Fix()
    print(thisEntity:GetName())
    local values = {
        {
            origin = Vector(-0.031250, 0.000086, 0.000056),
            angles = QAngle(89.996803, 89.995049, 0.000000)
        },
        {
            origin = Vector(0.000000, 0.000086, 0.000000),
            angles = QAngle(89.990486, 90.004936, 0.000000)
        }
    }
    local index = 1
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            child:SetLocalOrigin(values[index].origin)
            child:SetLocalAngles(values[index].angles.x,values[index].angles.y,values[index].angles.z)
            index = index + 1
        end
    end
end

function WiggleHandles()
    for _, child in ipairs(thisEntity:GetChildren()) do
        if child:GetClassname() == "prop_animinteractable" then
            DoEntFireByInstanceHandle(child, "PlayAnimation", "doorhandle_locked_anim", 0, nil, nil)
        end
    end
end

