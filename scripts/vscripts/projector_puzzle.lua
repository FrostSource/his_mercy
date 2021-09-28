
function CheckAngle(data)
    local angle = data.activator:GetForwardVector():Dot(Vector(1,0,0))
    if angle > 0.9 or angle < -0.9 then
        DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, nil, nil)
    end
end
