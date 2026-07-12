-- Alert Pendulum Recreation
function onCreate()
	-- system-off
    makeLuaSprite('system-off', 'reignite/alert-mechanic/system-off', 903, 600)
	scaleObject('system-off', 1.4, 1.4)
	setScrollFactor('system-off', 0, 0);
    addLuaSprite('system-off', true)
	setObjectCamera('system-off', 'HUD')

	-- system-on
	makeAnimatedLuaSprite('system-on', 'reignite/alert-mechanic/system-on', 903, 600)
	addAnimationByPrefix('system-on', 'anim', 'beat', 23, false);
	scaleObject('system-on', 1.4, 1.4)
	setScrollFactor('system-on', 0, 0);
	setObjectCamera('system-on', 'HUD')

	-- Alert texture
	makeAnimatedLuaSprite('alert', 'reignite/alert-mechanic/alert-kb', 900, 315)
	addAnimationByPrefix('alert', 'anim', 'alert-kb', 24, false);
	setObjectCamera('alert', 'HUD')
	scaleObject('alert', 1.25, 1.25)
	setScrollFactor('alert', 0, 0);
    addLuaSprite('alert', true)

	-- pro tip how to dodge
	if getPropertyFromClass('ClientPrefs', 'downScroll') == true then
		makeLuaSprite('dodge-hint', 'reignite/alert-mechanic/dodge-hint', 306, 500)
		addLuaSprite('dodge-hint', true)
		setScrollFactor('dodge-hint', 0, 0);
		doTweenAlpha('dodge-hintTween', 'dodge-hint', 0, 0.1, 'sineOut');
	elseif getPropertyFromClass('ClientPrefs', 'downScroll') == false then
		makeLuaSprite('dodge-hint', 'reignite/alert-mechanic/dodge-hint', 306, 160)
		addLuaSprite('dodge-hint', true)
		setScrollFactor('dodge-hint', 0, 0);
		doTweenAlpha('dodge-hintTween', 'dodge-hint', 0, 0.1, 'sineOut');
	end

	-- hud: shows if player dodged correctly or not
	-- case: correct
	makeAnimatedLuaSprite('correct', 'reignite/alert-mechanic/alert-correct', 1125, 500)
	addAnimationByPrefix('correct', 'anim', 'correct', 24, false);
	setObjectCamera('correct', 'HUD')
	scaleObject('correct', 1.25, 1.25)
	setScrollFactor('correct', 0, 0);
    addLuaSprite('correct', true)
	-- case: wrong
	makeAnimatedLuaSprite('wrong', 'reignite/alert-mechanic/alert-wrong', 1125, 500)
	addAnimationByPrefix('wrong', 'anim', 'wrong', 24, false);
	setObjectCamera('wrong', 'HUD')
	scaleObject('wrong', 1.25, 1.25)
	setScrollFactor('wrong', 0, 0);
    addLuaSprite('wrong', true)
end

function onSongStart()
	addLuaSprite('system-on', true)
	removeLuaSprite('system-off')
end

function onBeatHit() -- will start the animation ig
	if curBeat % 4 == 0 then
		objectPlayAnimation('system-on', 'anim', true)
	end
end

function onEvent(name)
	health = getProperty('health')
	if name == 'ReigniteAlert' then
    	objectPlayAnimation('alert', 'anim', true)
		playSound('alert-kb', 0.25);
		
		if not botPlay then
			if getProperty('pendulumHit.alpha') > 0 then
				objectPlayAnimation('correct', 'anim', true)
			else
				objectPlayAnimation('wrong', 'anim', true)
			end
		end

		if botPlay then
			objectPlayAnimation('correct', 'anim', true)
		end
	end
end

function onCountdownTick(counter)
	if counter == 2 then
		doTweenAlpha('dodge-hintTween', 'dodge-hint', 1, 0.4, 'sineOut');
	end
	if counter == 4 then
	    doTweenAlpha('dodge-hintTween', 'dodge-hint', 0, 2, 'sineOut');
	end
end