function onEvent(name, value1, value2)
	if name == 'Stage-TVS' then
        if value1 == 'normal' then
            setProperty('tvsNormal.alpha', 1)
            setProperty('tvsGlitched.alpha', 0)
        end
        if value1 == 'glitched' then
            setProperty('tvsNormal.alpha', 0)
            setProperty('tvsGlitched.alpha', 1)
        end
    end
end