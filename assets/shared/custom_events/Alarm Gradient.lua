function onCreate()
    for alarms = 1,2 do
        local names = {'Left','Right'}
        local obName = 'Alarm'..names[alarms]
        makeLuaSprite(obName,'hazard/inhuman-port/back-Gradient',-685,-480)
        setObjectCamera(obName,'other')
        setProperty(obName..'.color',getColorFromHex('FF0000'))
        setProperty(obName..'.alpha',0.001)
        addLuaSprite(obName,true)
        scaleObject(obName, 4.0, 4.0);
        if alarms == 2 then
            setProperty(obName..'.flipX',true)
        end
    end
end
function onEvent(name,v1,v2)
    if name == 'Alarm Gradient' then
        local obName = nil
        local target = 0
        if v2 ~= '' and v2 ~= '0' then
            target = tonumber(v2)
        end
        if string.lower(v1) == 'left' then
            obName = 'AlarmLeft'
        elseif string.lower(v1) == 'right' then
            obName = 'AlarmRight'
        end
        if obName ~= nil then
            cancelTween(obName..'GradientEnd')
            doTweenAlpha(obName..'Gradient',obName,target,0.25,'quartOut')
        else
            cancelTween('AlarmLeftGradientEnd')
            cancelTween('AlarmRightGradientEnd')
            doTweenAlpha('AlarmleftGradient','AlarmLeft',target,0.25,'quartOut')
            doTweenAlpha('AlarmrightGradient','AlarmRight',target,0.25,'quartOut')
        end
    end
end
function onTweenCompleted(tag)
    if tag == 'AlarmLeftGradient' then
        doTweenAlpha('AlarmLeftGradientEnd','AlarmLeft',0,0.25,'quartOut')
    elseif tag == 'AlarmRightGradient' then
        doTweenAlpha('AlarmRightGradientEnd','AlarmRight',0,0.25,'quartOut')
    end
end