function onCreate()
	makeLuaSprite('darkeningEffect', nil, -700, -500);
	makeGraphic('darkeningEffect', screenWidth * 2, screenHeight * 2, 'FFFFFF');
	setScrollFactor('darkeningEffect', 0, 0);
	addLuaSprite('darkeningEffect', true);
	setProperty('darkeningEffect.alpha', 0.0000001);
	setProperty('darkeningEffect.color', getColorFromHex('000000'));
end

function onEvent(name, value1, value2)
	if name == 'Darkening effect' then
		if value1 == '1' then
			doTweenAlpha('darkeningEffectTween', 'darkeningEffect', 0, 0.6, 'sineOut');
			setProperty('darkeningEffect.color', getColorFromHex('FFFFFF'));
			doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xffffffff', 0.1, 'quadInOut')
			if flashingLights then
				setBlendMode('darkeningEffect', 'add');
			end
		else
			doTweenAlpha('darkeningEffectTween', 'darkeningEffect', 1, 0.4, 'sineOut');
			setProperty('darkeningEffect.color', getColorFromHex('000000'));
			setBlendMode('darkeningEffect', 'normal');
			doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xFF000000', 0.4, 'quadInOut')
		end
	end
end
