function onCreate()
    if not lowQuality then
        for eventNotes = 0,getProperty('eventNotes.length')-1 do
            if getPropertyFromGroup('eventNotes',eventNotes,'event') == 'Change Character OPTIONAL' then
                local v1 = getPropertyFromGroup('eventNotes',eventNotes,'value1')
                if v1 == 'bf' or v1 == '0' or v1 == '2' then
                    v1 = 'boyfriend'
                elseif v1 == '1' then
                    v1 = 'dad'
                elseif v1 == '3' then
                    v1 = 'gf'
                end
                addCharacterToList(getPropertyFromGroup('eventNotes',eventNotes,'value2'),v1)
            end
        end
    end
end
function onEvent(name,v1,v2)
    if name == 'Change Character OPTIONAL' and not lowQuality then
        triggerEvent('Change Character',v1,v2)
    end
end