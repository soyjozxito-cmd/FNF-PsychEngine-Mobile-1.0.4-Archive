local dialogue = false
local song;
local dialogueEnd = false
local dialogueFile = ''
function onCreate()
    song = string.lower(songName)
    if isStoryMode then
        if song == 'careless' or song == 'carefree' or song == 'terminate' or song == 'cessation' then
            dialogueFile = song..'/dialogue'
        
        end
    end
end
function onStartCountdown()
    if not dialogue and isStoryMode and dialogueFile ~= '' then
        runTimer('QTDialogue',0.8)
        return Function_Stop;
    end
end
function onTimerCompleted(tag)
    if tag == 'QTDialogue' then
        if song == 'carefree' then
            startDialogue('dialogue','carefree-dialogue-loop')
        else
            startDialogue('dialogue')
        end
        dialogue = true
    elseif tag == 'QTEndDialogue' then
        startDialogue('dialogueEND','')
        dialogueEnd = true
    end
end
function onEndSong()
    if not dialogueEnd then
        if isStoryMode and (song == 'careless' or song == 'terminate') or song == 'cessation' then
            runTimer('QTEndDialogue',0.8)
            return Function_Stop;
        end
    end
end