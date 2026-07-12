function onEvent(name,v1,v2)
    if name == 'TerminationIntro' then
        cameraShake('game',0.002,1)
        cameraShake('hud',0.002,1)
        local note = tonumber(v1)
        local alpha = 1
        if note == nil then
            note = 0
        end
        --note = note % 4
        local character = string.lower(v2)
        if character == 'player' then
            note = note + 4
        else
            if middlescroll then
                alpha = 0.35
            end
        end
        noteTweenAlpha('TerminationNoteAlpha'..note,note,alpha,1.22,'cubeOut')
        local noteY = 25
        if downscroll then
            noteY = noteY *-1
        end
        noteTweenY('TerminationNoteY'..note,note,getPropertyFromGroup('strumLineNotes',note,'y') - noteY,1.22,'cubeOut')
    end
end