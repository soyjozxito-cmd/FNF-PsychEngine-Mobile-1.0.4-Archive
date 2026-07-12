local founded = false
local dodging = false
local maxHP = 0
local instaKill = false
local sawGameOver = false
local sawBlackCreated = false
local dodgeDuration = 0.22
local forceInstaKill = false
function onCreatePost()
    for events = 0,getProperty('eventNotes.length')-1 do
        local eventName = getPropertyFromGroup('eventNotes',events,'event')
        if stringStartsWith(eventName,'KB_') then
            founded = true
            break
        end
    end
    if founded then
        if songName == 'Termination-Classic' then
            instaKill = true
        end
        makeLuaSprite('healthKB','healthBar-KB')
        loadGraphic('healthKB','healthBar-KB',1,19)
        setProperty('healthKB.angle',180)
        setObjectCamera('healthKB','hud')
        if version <= '0.6.3' then
            setObjectOrder('healthKB',getObjectOrder('healthBar') + 1)
            addLuaSprite('healthKB',true)
        else
            runHaxeCode(
                [[
                    game.uiGroup.insert(game.uiGroup.members.indexOf(game.healthBar)+1,game.getLuaObject('healthKB'));
                    return;
                ]]
            )
        end



        makeAnimatedLuaSprite('KBAlert','hazard/qt-port/attack_alert_NEW',screenWidth - 770,205)
        scaleObject('KBAlert',1.5,1.5)
        setObjectCamera('KBAlert','hud')
        addAnimationByPrefix('KBAlert','alert','kb_attack_animation_alert-single',24,false)
        addAnimationByPrefix('KBAlert','alertDOUBLE','kb_attack_animation_alert-double',24,false)
        addAnimationByPrefix('KBAlert','alertTRIPLE','kb_attack_animation_alert-triple',24,false)
        addAnimationByPrefix('KBAlert','alertQUAD','kb_attack_animation_alert-quad',24,false)
        setProperty('KBAlert.alpha',0.001)
        addLuaSprite('KBAlert',true)
    
        makeAnimatedLuaSprite('KBSaw','hazard/qt-port/attackv6',-860,630)
        scaleObject('KBSaw',1.15,1.15)
        addAnimationByPrefix('KBSaw','fire','kb_attack_animation_fire',24,false)
        addAnimationByPrefix('KBSaw','prepare','kb_attack_animation_prepare',24,false)
        setProperty('KBSaw.alpha',0.001)
        addLuaSprite('KBSaw',true)
        if flashingLights then
            makeLuaSprite('KBAlertVignette','hazard/inhuman-port/alert-vignette',0,0)
            setObjectCamera('KBAlertVignette','other')
            setProperty('KBAlertVignette.alpha',0.001)
            addLuaSprite('KBAlertVignette',true)
        end
    end
end
function reduzeHP()
    maxHP = math.min(2,maxHP + 0.51125)
    loadGraphic('healthKB','healthBar-KB',601*(maxHP/2),19)
end
function bfKBDodge()
    disableNotes(true,true)
    characterPlayAnim('boyfriend','dodge',true)
    setProperty('boyfriend.specialAnim',true)
    dodging = true
    runTimer('stopBFDodge',dodgeDuration)
end
function disableNotes(mustPress,disable)
    if getProperty('notes.length') > 0 then
        for notes = 0,getProperty('notes.length')-1 do
            if getPropertyFromGroup('notes',notes,'strumTime') - getSongPosition() <= dodgeDuration * 1005 and getPropertyFromGroup('notes',notes,'mustPress') == mustPress then
                setPropertyFromGroup('notes',notes,'noAnimation',disable)
            end
        end
    end
end
function onGameOver()
    if not sawBlackCreated and sawGameOver and getProperty('inGameOver') then
        makeAnimatedLuaSprite('KBSawBlack','hazard/qt-port/sawkillanimation2',-1715,500)
        addAnimationByPrefix('KBSawBlack','idle','kb_attack_animation_kill_idle',0,true)
        addAnimationByPrefix('KBSawBlack','moving','kb_attack_animation_kill_moving',24,true)
        addLuaSprite('KBSawBlack',true)
        sawBlackCreated = true
    end
end
function onUpdate(el)
    if founded then
        if keyboardJustPressed('SPACE') and not dodging then
            bfKBDodge()
        end
        if luaSpriteExists('KBAlertVignette') and getProperty('KBAlertVignette.alpha') > 0 then
            setProperty('KBAlertVignette.alpha',0,getProperty('KBAlertVignette.alpha') - (1.2*el))
        end
    end
    if version <= '0.6.3' then 
        setProperty('healthKB.x',getProperty('healthBarBG.x') + (601 -(601 * (maxHP/2))))
        setProperty('healthKB.y',getProperty('healthBarBG.y'))
    else
        setProperty('healthKB.x',getProperty('healthBar.x') + (601 -(601 * (maxHP/2))))
        setProperty('healthKB.y',getProperty('healthBar.y'))
    end
    if getHealth() < maxHP then
        setHealth(-1)
    end
end
function onTimerCompleted(tag)
    if tag == 'stopBFDodge' then
        characterPlayAnim('boyfriend','idle')
        dodging = false
    elseif tag == 'KBDodged' then
        local wasForceInstaKill = forceInstaKill
        forceInstaKill = false
        if not dodging then
            characterPlayAnim('boyfriend','hurt',true)
            setProperty('boyfriend.specialAnim',true)
            if instaKill or wasForceInstaKill then
                setProperty('boyfriend.stunned',true)
                setProperty('health',-0.045)
            else
                setProperty('health',getProperty('health')-0.265)
                reduzeHP()
            end
            if getProperty('health') >= maxHP then
                playSound('bonk')
            else
                sawGameOver = true
            end
        end
    end
end
function sawAnim(anim)
    setProperty('KBSaw.alpha',1)
    local offsetX = 0
    local offsetY = 0
    if anim == 'fire' then
        offsetX = 1600
    elseif anim == 'prepare' then
        offsetX = -333
    end
    setProperty('KBSaw.offset.x',offsetX)
    setProperty('KBSaw.offset.y',offsetY)
    playAnim('KBSaw',anim,true)
end
function onEvent(name,v1,v2)
    if name == 'KB_Alert' then
        local alertType = 1
        if v1 ~= '' then
            alertType = tonumber(v1)
        end
        if alertType == nil then
            alertType = 1
        end
        kbAlert(alertType,true)
    elseif name == 'KB_AlertDouble' then
        kbAlert(2,true)
    elseif name == 'KB_AttackPrepare' then
        if v1 ~= '0' then
            kbAlert(1,true)
        end
        sawAnim('prepare')
    elseif name == 'KB_AttackFire' then
        local type = 1
        if v1 ~= '' then
            type = tonumber(v1)
        end
        if type == nil then
            type = 1
        end
        forceInstaKill = (v2 ~= '' and v2 ~= nil)
        kbAttack(type,true)
    elseif name == 'KB_AttackFireDOUBLE' and v1 == '' then
        kbAttack(2,true)
    end
end
function kbAttack(attackType,sound)
    cameraShake('game',0.001675,0.5)
    cameraShake('hud',0.001675,0.5)
    if sound then
        local songPlay = 'hazard/attack'
        if attackType == 2 then
            songPlay = 'hazard/attack-double'
        elseif attackType == 3 then
            songPlay = 'hazard/attack-triple'
        elseif attackType == 4 then
            songPlay = 'hazard/attack-quadruple'
        end
        playSound(songPlay,0.765)
    end
    sawAnim('fire')
    runTimer('KBDodged',0.1)
    if botPlay then
        bfKBDodge()
    end
end
function alertAnim(anim)
    cancelTween('AlertKBBye')
    local flashAlpha = 0.5
    local offsetX = 0
    local offsetY = 0

    setProperty('KBAlert.alpha',1)

    if anim == 'alertQUAD' then
        offsetX = 152
        offsetY = 38
        flashAlpha = 0.6
    elseif anim == 'alertTRIPLE' then
        offsetX = 150
        offsetY = 56
        flashAlpha = 0.5875
    elseif anim == 'alertDOUBLE' then
        offsetX = 70
        offsetY = 5
    end
    setProperty('KBAlert.offset.x',offsetX)
    setProperty('KBAlert.offset.y',offsetY)
    playAnim('KBAlert',anim,true)
    
    if flashingLights then
        setProperty('KBAlertVignette.alpha',flashAlpha)
    end
end
function kbAlert(type,enableSong)
    if enableSong then
        local song = 'hazard/alert'
        if type == 2 then
            song = 'hazard/alertDouble'
        elseif type == 3 then
            song = 'hazard/alertTriple'
        elseif type == 4 then
            song = 'hazard/alertQuadruple'
        end
        playSound(song)
    end
    local anims = {'alert','alertDOUBLE','alertTRIPLE','alertQUAD'}
    alertAnim(anims[type])
end
