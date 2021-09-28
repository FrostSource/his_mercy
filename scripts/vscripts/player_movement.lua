
PlayerPreviousPosition = PlayerPreviousPosition or Vector(0,0,0)
CREAK_DISTANCE = CREAK_DISTANCE or 15
CREAK_TIME = CREAK_TIME or 15
LastCreakTime = LastCreakTime or 0
FootstepProxy = FootstepProxy or nil

function EnableCreak()
    thisEntity:Attribute_SetIntValue("CreakEnabled", 1)
    print("Enable creak")
end
function DisableCreak()
    print("Disable creak")
    thisEntity:Attribute_SetIntValue("CreakEnabled", 0)
end
function CreakIsEnabled()
    return thisEntity:Attribute_GetIntValue("CreakEnabled", 0) == 1
end

function Activate()
    thisEntity:SetContextThink("update",function()
        local player = Entities:GetLocalPlayer()
        FootstepProxy = Entities:FindByName(nil, "@player_footstep_proxy")
        if not FootstepProxy then
            FootstepProxy = SpawnEntityFromTableSynchronous("info_target", {
                targetname = "@player_footstep_proxy"
            })
            FootstepProxy:SetParent(player, "")
            FootstepProxy:SetLocalOrigin(Vector(0,0,0))
        end
        PlayerPreviousPosition = player:GetOrigin()
    end, 0.01)
    thisEntity:SetThink(MovementThink, "MovementThink", 0.1)
end

function MovementThink()
    local player = Entities:GetLocalPlayer()
    if  CreakIsEnabled()
    and Time() - LastCreakTime > CREAK_TIME
    and VectorDistance(PlayerPreviousPosition, player:GetOrigin()) >= CREAK_DISTANCE
    then
        --player:EmitSound("ScriptedSeq.Distillery_Wood_Beam_Creak")
        --StartSoundEventFromPosition("ScriptedSeq.Distillery_Wood_Beam_Creak", player:GetOrigin())
        --StartSoundEventFromPosition("choreo_a1_intro_window_footsteps", player:GetOrigin())
        print("Creaking", CreakIsEnabled())
        FootstepProxy:EmitSoundParams("ScriptedSeq.Distillery_Wood_Beam_Creak", 0, 0.4, 0)
        LastCreakTime = Time()
        --print("Creaking")
    end
    PlayerPreviousPosition = player:GetOrigin()
    return 0.35
end
