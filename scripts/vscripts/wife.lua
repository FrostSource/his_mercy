
---@param activateType "0"|"1"|"2"
function Activate(activateType)
    thisEntity:SetThink(Thinker, "Thinker", 0.01)

end

function Thinker()
    thisEntity:SetGraphParameterFloat("head_twitch", RandomFloat(0,180))
    --thisEntity:SetGraphParameterVector("sdfg", Vector(RandomInt(-9, 9),RandomInt(-30,30),RandomInt(-10,10)))
    local eye = thisEntity:EyePosition()
    local d = 512
    --thisEntity:SetGraphParameterVector("head_twitch_pos", eye+Vector( RandomInt(-d, d) , RandomInt(-d,d) , eye.z ))
    --thisEntity:SetGraphParameterVector("head_twitch_pos", eye+Vector( RandomInt(-d, d) , RandomInt(-256,-) , eye.z ))

    --print('active', thisEntity:GetGraphParameter("head_twitch"))
    return 0.2
end
