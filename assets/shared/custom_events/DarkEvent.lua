function onCreate()
    doTweenAlpha('sawTween', 'saw', 0, 0.4, 'sineOut');
    doTweenAlpha('saw1Tween', 'saw1', 0, 0.4, 'sineOut');
    doTweenAlpha('saw2Tween', 'saw2', 0, 0.4, 'sineOut');
    doTweenAlpha('saw3Tween', 'saw3', 0, 0.4, 'sineOut');
    doTweenAlpha('saw4Tween', 'saw4', 0, 0.4, 'sineOut');
    doTweenAlpha('saw-darkTween', 'saw-dark', 0, 0.4, 'sineOut');
    doTweenAlpha('saw-dark1Tween', 'saw-dark1', 0, 0.4, 'sineOut');
    doTweenAlpha('saw-dark2Tween', 'saw-dark2', 0, 0.4, 'sineOut');
    doTweenAlpha('saw-dark3Tween', 'saw-dark3', 0, 0.4, 'sineOut');
    doTweenAlpha('saw-dark4Tween', 'saw-dark4', 0, 0.4, 'sineOut');
    doTweenAlpha('pincerTween', 'pincer', 0, 0.4, 'sineOut');
    doTweenAlpha('pincer1Tween', 'pincer1', 0, 0.4, 'sineOut');
    doTweenAlpha('pincer2Tween', 'pincer2', 0, 0.4, 'sineOut');
    doTweenAlpha('pincer-darkTween', 'pincer-dark', 0, 0.4, 'sineOut');
    doTweenAlpha('pincer-dark1Tween', 'pincer-dark1', 0, 0.4, 'sineOut');
    doTweenAlpha('pincer-dark2Tween', 'pincer-dark2', 0, 0.4, 'sineOut');
end

function onEvent(name, value1, value2)
	if name == 'DarkEvent' then
        if value1 == 'dark-v1' then
            doTweenAlpha('darkStreetBGTween', 'darkStreetBG', 0.5, 0.1, 'sineOut');
            setBlendMode('darkStreetBG', 'normal');
            -- dark:
            doTweenAlpha('floor-darkTween', 'floor-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('speaker-darkTween', 'speaker-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('tvs-darkTween', 'tvs-dark', 0.5, 0.1, 'sineOut');
            -- players:
            doTweenColor('bfColorTween', 'boyfriend', '0xFF7F0000', 0.1, 'quadInOut')
            doTweenColor('dadColorTween', 'dad', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('bfTween', 'bf', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xFF7F0000', 0.1, 'quadInOut')
            -- bg stuff
            doTweenColor('floorTween', 'floor', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('speakerTween', 'speaker', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('tvsTween', 'tvs', '0xFFFF0000', 0.1, 'quadInOut')

        elseif value1 == 'dark-v2' then
            doTweenAlpha('darkStreetBGTween', 'darkStreetBG', 0.5, 0.1, 'sineOut');
            setBlendMode('darkStreetBG', 'normal');
            doTweenAlpha('sawTween', 'saw', 1, 0.1, 'sineOut');
            doTweenAlpha('saw1Tween', 'saw1', 1, 0.1, 'sineOut');
            doTweenAlpha('saw2Tween', 'saw2', 1, 0.1, 'sineOut');
            doTweenAlpha('saw3Tween', 'saw3', 1, 0.1, 'sineOut');
            doTweenAlpha('saw4Tween', 'saw4', 1, 0.1, 'sineOut');
            doTweenAlpha('pincerTween', 'pincer', 1, 0.1, 'sineOut');
            doTweenAlpha('pincer1Tween', 'pincer1', 1, 0.1, 'sineOut');
            doTweenAlpha('pincer2Tween', 'pincer2', 1, 0.1, 'sineOut');
            -- dark:
            doTweenAlpha('floor-darkTween', 'floor-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('speaker-darkTween', 'speaker-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('tvs-darkTween', 'tvs-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('saw-darkTween', 'saw-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('saw-dark1Tween', 'saw-dark1', 0.5, 0.1, 'sineOut');
            doTweenAlpha('saw-dark2Tween', 'saw-dark2', 0.5, 0.1, 'sineOut');
            doTweenAlpha('saw-dark3Tween', 'saw-dark3', 0.5, 0.1, 'sineOut');
            doTweenAlpha('saw-dark4Tween', 'saw-dark4', 0.5, 0.1, 'sineOut');
            doTweenAlpha('pincer-darkTween', 'pincer-dark', 0.5, 0.1, 'sineOut');
            doTweenAlpha('pincer-dark1Tween', 'pincer-dark1', 0.5, 0.1, 'sineOut');
            doTweenAlpha('pincer-dark2Tween', 'pincer-dark2', 0.5, 0.1, 'sineOut');
            -- players:
            doTweenColor('bfColorTween', 'boyfriend', '0xFF7F0000', 0.1, 'quadInOut')
            doTweenColor('dadColorTween', 'dad', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('bfTween', 'bf', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xFF7F0000', 0.1, 'quadInOut')
            doTweenColor('sawTween', 'saw', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('saw1Tween', 'saw1', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('saw2Tween', 'saw2', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('saw3Tween', 'saw3', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('saw4Tween', 'saw4', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('pincerTween', 'pincer', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('pincer1Tween', 'pincer1', '0xFFFF0000', 0.1, 'quadInOut');
            doTweenColor('pincer2Tween', 'pincer2', '0xFFFF0000', 0.1, 'quadInOut');
            -- bg stuff
            doTweenColor('floorTween', 'floor', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('speakerTween', 'speaker', '0xFFFF0000', 0.1, 'quadInOut')
            doTweenColor('tvsTween', 'tvs', '0xFFFF0000', 0.1, 'quadInOut')

		elseif value1 == 'normal-v1' then
			doTweenAlpha('darkStreetBGTween', 'darkStreetBG', 1, 1.5, 'sineOut');
			setBlendMode('darkStreetBG', 'normal');
            -- dark:
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('speaker-darkTween', 'speaker-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('tvs-darkTween', 'tvs-dark', 0, 1.5, 'sineOut');
            -- players:
            doTweenColor('bfColorTween', 'boyfriend', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('dadColorTween', 'dad', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('bfTween', 'bf', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xff666666', 0.1, 'quadInOut')
            -- bg stuff
            doTweenColor('floorTween', 'floor', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('speakerTween', 'speaker', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('tvsTween', 'tvs', '0xffffffff', 1.5, 'quadInOut')

        elseif value1 == 'normal-v2' then
			doTweenAlpha('darkStreetBGTween', 'darkStreetBG', 1, 1.5, 'sineOut');
			setBlendMode('darkStreetBG', 'normal');
            -- dark:
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('speaker-darkTween', 'speaker-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('tvs-darkTween', 'tvs-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('saw-darkTween', 'saw-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('saw-dark1Tween', 'saw-dark1', 0, 1.5, 'sineOut');
            doTweenAlpha('saw-dark2Tween', 'saw-dark2', 0, 1.5, 'sineOut');
            doTweenAlpha('saw-dark3Tween', 'saw-dark3', 0, 1.5, 'sineOut');
            doTweenAlpha('saw-dark4Tween', 'saw-dark4', 0, 1.5, 'sineOut');
            doTweenAlpha('pincer-darkTween', 'pincer-dark', 0, 1.5, 'sineOut');
            doTweenAlpha('pincer-dark1Tween', 'pincer-dark1', 0, 1.5, 'sineOut');
            doTweenAlpha('pincer-dark2Tween', 'pincer-dark2', 0, 1.5, 'sineOut');
            -- players:
            doTweenColor('bfColorTween', 'boyfriend', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('dadColorTween', 'dad', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('bfTween', 'bf', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xff666666', 0.1, 'quadInOut')
            -- bg stuff
            doTweenColor('floorTween', 'floor', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('speakerTween', 'speaker', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('tvsTween', 'tvs', '0xffffffff', 1.5, 'quadInOut')
            doTweenColor('sawTween', 'saw', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('saw1Tween', 'saw1', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('saw2Tween', 'saw2', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('saw3Tween', 'saw3', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('saw4Tween', 'saw4', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('pincerTween', 'pincer', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('pincer1Tween', 'pincer1', '0xffffffff', 1.5, 'quadInOut');
            doTweenColor('pincer2Tween', 'pincer2', '0xffffffff', 1.5, 'quadInOut');

        elseif value1 == 'end-v' then
            doTweenAlpha('darkStreetBGTween', 'darkStreetBG', 0.5, 0.1, 'sineOut');
            setBlendMode('darkStreetBG', 'normal');
            -- dark:
            doTweenAlpha('floor-darkTween', 'floor-dark', 0.95, 0.1, 'sineOut');
            doTweenAlpha('speaker-darkTween', 'speaker-dark', 0.95, 0.1, 'sineOut');
            doTweenAlpha('tvs-darkTween', 'tvs-dark', 0.95, 0.1, 'sineOut');
            doTweenColor('bfTween', 'bf', '0xFF000000', 0.1, 'quadInOut')
            doTweenColor('kb_attack_sawTween', 'kb_attack_saw', '0xFF050505', 0.1, 'quadInOut')
            doTweenAlpha('saw-darkTween', 'saw-dark', 0.95, 0.1, 'sineOut');
            doTweenAlpha('saw-dark1Tween', 'saw-dark1', 0.95, 0.1, 'sineOut');
            doTweenAlpha('saw-dark2Tween', 'saw-dark2', 0.95, 0.1, 'sineOut');
            doTweenAlpha('saw-dark3Tween', 'saw-dark3', 0.95, 0.1, 'sineOut');
            doTweenAlpha('saw-dark4Tween', 'saw-dark4', 0.95, 0.1, 'sineOut');
            doTweenAlpha('pincer-darkTween', 'pincer-dark', 0.95, 0.1, 'sineOut');
            doTweenAlpha('pincer-dark1Tween', 'pincer-dark1', 0.95, 0.1, 'sineOut');
            doTweenAlpha('pincer-dark2Tween', 'pincer-dark2', 0.95, 0.1, 'sineOut');
        end
    end
end