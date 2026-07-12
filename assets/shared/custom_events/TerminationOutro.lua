function onEvent(name,v1,v2)
    if name == 'TerminationOutro' then
        local note = tonumber(v1)
        local speed = 1.45
        if v2 ~= '' then
            speed = tonumber(v2)
        end
        if speed == nil then
            speed = 1.1
        end
        if note == nil then
            note = 0
        end
        noteTweenAlpha('TerminationNoteAlpha'..note,note,0,speed,'cubeOut')
    end
end