function onCreate()
	addCharacterToList('bf-copy', 'boyfriend');
	
	makeLuaSprite('ScreenThing', nil, -700, -500);
	makeGraphic('ScreenThing', screenWidth * 2, screenHeight * 2, 'FFFFFF');
	setScrollFactor('ScreenThing', 0, 0);
	addLuaSprite('ScreenThing', true);
	setProperty('ScreenThing.alpha', 0.0000001);
	setProperty('ScreenThing.color', getColorFromHex('000000'));
	
	--makeAnimationList();
	--makeOffsets();
	--playAnimSilhouette(0, true);
end

function onEvent(name, value1, value2)
	if name == 'Boyfriend Silhouette' then
		if value1 == '1' then
			triggerEvent('Change Character', 'bf', 'bf-copy')
			setProperty('boyfriend.color', getColorFromHex('000000'));
			setProperty('boyfriend.alpha', 0.000001);
			setObjectOrder('boyfriendGroup', getObjectOrder('ScreenThing') + 1);
			doTweenAlpha('bfSilhouetteTween', 'boyfriend', 1, (crochet * 2) / 1000, 'linear');
		elseif value1 == '2' then
			doTweenAlpha('bfSilhouetteTween', 'boyfriend', 0, (crochet * 4) / 1000, 'linear');
		else
			setProperty('ScreenThing.color', getColorFromHex('FFFFFF'));
			doTweenAlpha('ScreenThingTween', 'ScreenThing', 1, (crochet * 4) / 1000, 'linear');
			if flashingLights then
				setBlendMode('ScreenThing', 'add');
			end
		end
	end
end