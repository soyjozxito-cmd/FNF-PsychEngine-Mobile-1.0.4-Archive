local modChart = 0
local modChartSpeed = 0
local curSpeed = 1
local defaultX = {}
function onCreatePost()
    makeAnimatedLuaSprite('Amelia','hazard/inhuman-port/ameliaTaunt',672,260)
    addAnimationByPrefix('Amelia','laugh1','Amelia_Chuckle',24,true)
    addAnimationByPrefix('Amelia','laugh2','Amelia_Laugh',30,true)
    setScrollFactor('Amelia',-2.4,0)
    scaleObject('Amelia',2.6,2.6)
    setProperty('Amelia.offset.x',-1200)
    setProperty('Amelia.offset.y',-550)
    setProperty('Amelia.alpha',0.001)
    addLuaSprite('Amelia',false)
    screenCenter('Amelia')
    for strumNotes = 0,7 do
        table.insert(defaultX,#defaultX + 1,getPropertyFromGroup('strumLineNotes',strumNotes,'x'))
    end
end
function onUpdate(el)
    if modChart == 4 then
        modChartSpeed = getProperty('modChartX.x')
        for strumNotes = 0,7 do
            setPropertyFromGroup('strumLineNotes',strumNotes,'x',lerp(defaultX[strumNotes + 1],defaultX[strumNotes + 1] + (math.sin((getSongPosition()/(stepCrochet*32))*math.pi) * -200),modChartSpeed))
        end
    elseif modChart == 6 then
        setProperty('songSpeed',getProperty('modChartX.x'))
    end
end
function AmeliaAnim(anim)
    local offsetX = 0
    if anim == 'laugh2' then
        offsetX = -150
    end
    playAnim('Amelia',anim,false)
    setProperty('Amelia.offset.x',offsetX)
end
function byeAmelia()
    cancelTween('HeyAmelia')
    setProperty('Amelia.alpha',0)
end
function onEvent(name,v1,v2)
    if name == 'InterlopeEffect' or name == '??????' then
        if v1 == '4' or v1 == '6' then
            makeLuaSprite('modChartX',curSpeed)
        else
            removeLuaSprite('modChartX',true)
        end
        if v1 == '' then
        --[[
            for strumNotes = 0,7 do
                noteTweenX('InterlopeTweenAlpha'..strumNotes,strumNotes,defaultX[strumNotes + 1],0.4,'quadInOut')
            end
            modChart = 0
        ]]--
        elseif v1 == '4' then
            setProperty('modChartX.x',0)
            modChartSpeed = 0
            doTweenX('InterlopeTween','modChartX',1,6,'linear')
        elseif v1 == '6' then
            curSpeed = getProperty('songSpeed')
            setProperty('modChartX.x',curSpeed)
        end
        modChart = tonumber(v1)
        if v2 == '5' then
            AmeliaAnim('laugh1')
            setProperty('Amelia.alpha',0.3)
            for strumNotes = 0,3 do
                setPropertyFromGroup('strumLineNotes',strumNotes,'color',getColorFromHex('FF808080'))
                noteTweenAlpha('InterlopeTweenAlpha'..strumNotes,strumNotes,0.325,0.55,'linear')
            end
        elseif v2 == '6' or v2 == '9' or v2 == '11' then
            byeAmelia()
        elseif v2 == '8' then
            AmeliaAnim('laugh1')
            doTweenAlpha('HeyAmelia','Amelia',0.55,0.3,'linear')
        elseif v2 == '10' then
            AmeliaAnim('laugh2')
            doTweenAlpha('HeyAmelia','Amelia',0.8,0.3,'linear')
            for strumNotes = 0,3 do
                setPropertyFromGroup('strumLineNotes',strumNotes,'color',getColorFromHex('FF808080'))
                setPropertyFromGroup('strumLineNotes',strumNotes,'x',getPropertyFromGroup('strumLineNotes',strumNotes + 4,'x'))
                noteTweenAlpha('InterlopeTweenAlpha'..strumNotes,strumNotes,0.4,0.5,'linear')
                noteTweenX('InterlopeTweenX'..strumNotes,strumNotes,getPropertyFromGroup('strumLineNotes',strumNotes + 4,'x') - 600,0.7,'quadOut')
            end
        elseif v2 == '13' then
            for strumLineNotes = 0,6 do
                noteTweenAlpha('InterlopeTweenAlpha'..strumLineNotes,strumLineNotes,0,1,'linear')
            end
        elseif v2 == '14' then
            noteTweenAlpha('notesTween7',7,0.37,1,'linear')
        elseif v2 == '15' then
            doTweenAlpha('byeHUD','camHUD',0,0.37,'linear')

        elseif v2 == '16' then
            for strumNotes = 0,7 do
                if strumNotes < 4 then
                    noteTweenAlpha('InterlopeTweenAlpha'..strumNotes,strumNotes,0,0.45,'linear')
                else
                    noteTweenX('InterlopeTweenX'..strumNotes,strumNotes,defaultX[strumNotes + 1],0.8,'quadOut')
                end
            end
        elseif v2 == '17' then
            for strumLineNotes = 0,3 do
                noteTweenX('InterlopeTweenX'..strumLineNotes,strumLineNotes,getPropertyFromGroup('strumLineNotes',strumLineNotes + 4,'x'),7,'quadInOut')
            end
        elseif v2 == '18' then
            for strumNotes = 0,3 do
                noteTweenAlpha('InterlopeTweenAlpha'..strumNotes,strumNotes,0,0.75,'linear')
                noteTweenX('InterlopeTweenX'..strumNotes,strumNotes,defaultX[strumNotes + 1],0.75,'quadInOut')
            end
        elseif v2 == '19' then
            for strumNotes = 4,7 do
                noteTweenX('InterlopeTweenX'..strumNotes,strumNotes,defaultX[strumNotes + 1],0.8,'linear')
            end
        end
    end
end
function lerp(a, b, k)
    return a * (1-k) + b * k
end
function onBeatHit()
    if modChart == 3 or modChart == 5 then
        for strumLineNotes = 0,7 do
            local x = 300
            if curBeat % 2 == 1 then
                x = -300
            end
            if strumLineNotes > 3 then
                x = x *-1
            end
            setPropertyFromGroup('strumLineNotes',strumLineNotes,'x',defaultX[(strumLineNotes%4) + 5] + x)
        end
    elseif modChart == 6 then
        setProperty('modChartX.x',1)
        doTweenX('songSpeedTween','modChartX',curSpeed,0.37,'sineOut')
    end
end