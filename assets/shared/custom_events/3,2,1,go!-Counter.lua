-- based on Ed's script, but ill make this event to be used everywhere
function onEvent(name, value1, value2)
	if name == '3,2,1,go!-Counter' then
        if value1 == '3' then
            setProperty('3.alpha', 1)
            doTweenAlpha('bye3', '3', 0, 0.4, 'easeOut')
            if value2 == '+sound' then
                playSound('3,2,1,go!/3', 1)
            end
        end
        if value1 == '2' then
            setProperty('2.alpha', 1)
            doTweenAlpha('bye2', '2', 0, 0.4, 'easeOut')
            if value2 == '+sound' then
                playSound('3,2,1,go!/2', 1)
            end
        end
        if value1 == '1' then
            setProperty('1.alpha', 1)
            doTweenAlpha('bye1', '1', 0, 0.4, 'easeOut')
            if value2 == '+sound' then
                playSound('3,2,1,go!/1', 1)
            end
        end
        if value1 == 'go' then
            setProperty('go.alpha', 1)
            doTweenAlpha('bye0', 'go', 0, 0.4, 'easeOut')
            if value2 == '+sound' then
                playSound('3,2,1,go!/GO', 1)
            end
        end
    end
end
-- I'm tired a little, cause its December. Okay, it doesnt make any sence, but know I'm tired.