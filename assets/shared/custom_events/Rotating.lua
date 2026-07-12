local enable = true
local noteAngle = 0
local angleStyle = 0
function onEvent(name,v1)
    if name == 'Rotating' then
        angleStyle = tonumber(v1)
        if angleStyle == 0 then
            for strumNotes = 0,7 do
                noteTweenAngle('NoteBackAngle'..strumNotes,strumNotes,-360,0.8,'quadInOut')
            end
        end
    end
end
function setNoteAngle()
    noteAngle = (noteAngle + 22.5)%360
    for strumLineNotes = 0,7 do
        setPropertyFromGroup('strumLineNotes',strumLineNotes,'angle',noteAngle)
    end
end
function onStepHit()
    if enable then
        if angleStyle == 1 then
            if curStep % 2 == 0 then
                setNoteAngle()
            end
        elseif angleStyle == 2 then
            setNoteAngle()
        end
    end
end