function onCreate()
	-- eyes thing (thanks Ed for textures)
	makeAnimatedLuaSprite('eye', 'reignite/eye', 200, 800)
	addAnimationByPrefix('eye', 'Animated', 'eye', 36, false)
	setProperty('eye.angle', 31)
	scaleObject('eye', 2, 2)
	
	makeAnimatedLuaSprite('eye1', 'reignite/eye', 1000, 750)
	addAnimationByPrefix('eye1', 'Animated', 'eye', 36, false)
	setProperty('eye1.angle', 11)
	scaleObject('eye1', 1.3, 1.3)
	
	makeAnimatedLuaSprite('eye2', 'reignite/eye', 700, 650)
	addAnimationByPrefix('eye2', 'Animated', 'eye', 36, false)
	setProperty('eye2.angle', -21)
	scaleObject('eye2', 1.5, 1.5)
		
	makeAnimatedLuaSprite('eye3', 'reignite/eye', 1300, 800)
	addAnimationByPrefix('eye3', 'Animated', 'eye', 36, false)
	setProperty('eye3.angle', -40)
	scaleObject('eye3', 1.25, 1.25)

	makeAnimatedLuaSprite('eye4', 'reignite/eye', 400, 700)
	addAnimationByPrefix('eye4', 'Animated', 'eye', 36, false)
	setProperty('eye4.angle', 11)
	scaleObject('eye4', 1.1, 1.1)

	makeAnimatedLuaSprite('eye5', 'reignite/eye', 1100, 600)
	addAnimationByPrefix('eye5', 'Animated', 'eye', 36, false)
	setProperty('eye5.angle', 31)
	scaleObject('eye5', 1.1, 1.1)

	doTweenAlpha('eyeTween', 'eye', 0, 0.4, 'sineOut');
	doTweenAlpha('eye1Tween', 'eye1', 0, 0.4, 'sineOut');
	doTweenAlpha('eye2Tween', 'eye2', 0, 0.4, 'sineOut');
	doTweenAlpha('eye3Tween', 'eye3', 0, 0.4, 'sineOut');
	doTweenAlpha('eye4Tween', 'eye4', 0, 0.4, 'sineOut');
	doTweenAlpha('eye5Tween', 'eye5', 0, 0.4, 'sineOut');
end

function onSongStart() -- eyes thing^2
	addLuaSprite('eye', true)
	addLuaSprite('eye1', true)
	addLuaSprite('eye2', true)
	addLuaSprite('eye3', true)
	addLuaSprite('eye4', true)
	addLuaSprite('eye5', true)
end

function onBeatHit() -- will start the eye animation - its random
	if curBeat % 2 == 0 then
		objectPlayAnimation('eye', 'Animated', true)
	end
	if curBeat % 3 == 0 then
		objectPlayAnimation('eye2', 'Animated', true)
	end
	if curBeat % 6 == 0 then
		objectPlayAnimation('eye1', 'Animated', true)
	end
	if curBeat % 5 == 0 then
		objectPlayAnimation('eye3', 'Animated', true)
	end
	if curBeat % 4 == 0 then
		objectPlayAnimation('eye4', 'Animated', true)
	end
	if curBeat % 7 == 0 then
		objectPlayAnimation('eye5', 'Animated', true)
	end
end

function onEvent(name, value1, value2)
	if name == 'MassacreEffect' then
		-- for Reignite
		if value1 == 'dark-v' then
			doTweenAlpha('bgTween', 'bg', 0.5, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 0.4, 'sineOut');
			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');

		elseif value1 == 'darker-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 0.4, 'sineOut');
			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');

		elseif value1 == 'normal-v' then
			doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');
			doTweenAlpha('kbTween', 'kb', 1, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');
	
		elseif value1 == 'end-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');
			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');
		end
		if value1 == 'termi-v1' then
			doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');
			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-normalTween', 'bg-normal', 1, 0.4, 'sineOut');
			setBlendMode('bg-normal', 'normal');
			doTweenAlpha('tvs-pTween', 'tvs-p', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-normalTween', 'kb-normal', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-normal-darkTween', 'kb-normal-dark', 0, 0.4, 'sineOut');
	
		elseif value1 == 'termi-end-v1' then
			doTweenAlpha('bg-normalTween', 'bg-normal', 0.5, 0.4, 'sineOut');
			doTweenAlpha('tvs-pTween', 'tvs-p', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-normalTween', 'kb-normal', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-normal-darkTween', 'kb-normal-dark', 1, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0.5, 0.4, 'sineOut');
	
		elseif value1 == 'termi-v2' then
			doTweenAlpha('bg-normalTween', 'bg-normal', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-normalTween', 'kb-normal', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-normal-darkTween', 'kb-normal-dark', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 1, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');
	
		elseif value1 == 'termi-end-v2' then
			doTweenAlpha('bg-normalTween', 'bg-normal', 0, 0.4, 'sineOut');
			setBlendMode('bg-normal', 'normal');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-normalTween', 'kb-normal', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-normal-darkTween', 'kb-normal-dark', 0, 0.4, 'sineOut');
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 1, 0.4, 'sineOut');
			setBlendMode('bg', 'normal');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 1,6, 'sineOut');
		end
		if value2 == 'eyes-on' then
			doTweenAlpha('eyeTween', 'eye', 0.4, 0.2, 'sineOut');
			doTweenAlpha('eye1Tween', 'eye1', 0.5, 0.2, 'sineOut');
			doTweenAlpha('eye2Tween', 'eye2', 0.6, 0.2, 'sineOut');
			doTweenAlpha('eye3Tween', 'eye3', 0.3, 0.2, 'sineOut');
			doTweenAlpha('eye4Tween', 'eye4', 0.5, 0.2, 'sineOut');
			doTweenAlpha('eye5Tween', 'eye5', 0.3, 0.2, 'sineOut');
		elseif value2 == 'eyes-off' then
			doTweenAlpha('eyeTween', 'eye', 0, 0.2, 'sineOut');
			doTweenAlpha('eye1Tween', 'eye1', 0, 0.2, 'sineOut');
			doTweenAlpha('eye2Tween', 'eye2', 0, 0.2, 'sineOut');
			doTweenAlpha('eye3Tween', 'eye3', 0, 0.2, 'sineOut');
			doTweenAlpha('eye4Tween', 'eye4', 0, 0.2, 'sineOut');
			doTweenAlpha('eye5Tween', 'eye5', 0, 0.2, 'sineOut');
		end
	end
end