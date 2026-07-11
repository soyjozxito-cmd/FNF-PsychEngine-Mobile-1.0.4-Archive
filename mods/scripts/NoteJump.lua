local defaultY = {}
function onCreatePost()
    table.insert(defaultY,defaultOpponentStrumY0)
    table.insert(defaultY,defaultOpponentStrumY1)
    table.insert(defaultY,defaultOpponentStrumY2)
    table.insert(defaultY,defaultOpponentStrumY3)
end
function opponentNoteHit(id,dir,type,sus)
    if string.sub(getProperty('dad.curCharacter'),0,2) == 'kb' and not sus then
        local y = 22
        if downscroll then
            y = -22
        end
        setPropertyFromGroup('strumLineNotes',dir,'y',defaultY[dir + 1] - y)
        noteTweenY('KbNote'..dir,dir,defaultY[dir + 1], 0.126,'cubeOut')
    end
end