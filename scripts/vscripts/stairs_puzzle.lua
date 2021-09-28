
--0 = down, 1 = up
Sequence = Sequence or {0,0,0,1,1}

function Spawn()
    thisEntity:Attribute_SetIntValue("SequenceIndex", 1)
end

function Downstairs()
    print("Stairs puzzle downstairs", thisEntity:Attribute_GetIntValue("SequenceIndex", 1))
    Advance(0)
end

function Upstairs()
    print("Stairs puzzle upstairs", thisEntity:Attribute_GetIntValue("SequenceIndex", 1))
    Advance(1)
end

function Advance(num)
    local index = thisEntity:Attribute_GetIntValue("SequenceIndex", 1)
    if Sequence[index] == num then
        thisEntity:Attribute_SetIntValue("SequenceIndex", index + 1)
        if (index + 1) > #Sequence then
            print("Stairs puzzle complete")
            DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, nil, nil)
        end
    else
        thisEntity:Attribute_SetIntValue("SequenceIndex", 1)
        -- if player reset puzzle by going downstairs at wrong time
        -- then automatically advance the sequence after resetting
        if num == 0 then
            Advance(0)
        end
        -- user 2 means puzzle was reset
        print("Stairs puzzle reset")
        DoEntFireByInstanceHandle(thisEntity, "FireUser2", "", 0, nil, nil)
    end
end
