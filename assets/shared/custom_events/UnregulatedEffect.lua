function onCreate()
	doTweenAlpha('saw1Tween', 'saw1', 0, 0.1, 'sineOut');
	doTweenAlpha('saw2Tween', 'saw2', 0, 0.1, 'sineOut');

	doTweenAlpha('pincer1Tween', 'pincer1', 0, 0.1, 'sineOut');
	doTweenAlpha('pincer2Tween', 'pincer2', 0, 0.1, 'sineOut');
	doTweenAlpha('pincer3Tween', 'pincer3', 0, 0.1, 'sineOut');

	doTweenAlpha('saw1-bsodTween', 'saw1-bsod', 0, 0.1, 'sineOut');
	doTweenAlpha('saw2-bsodTween', 'saw2-bsod', 0, 0.1, 'sineOut');

	doTweenAlpha('pincer1-bsodTween', 'pincer1-bsod', 0, 0.1, 'sineOut');
	doTweenAlpha('pincer2-bsodTween', 'pincer2-bsod', 0, 0.1, 'sineOut');
	doTweenAlpha('pincer3-bsodTween', 'pincer3-bsod', 0, 0.1, 'sineOut');
end

function onUpdatePost()
	-- bsod shaking
	if dadName == 'kb-unregulated-404' then
        cameraShake('hud', 0.0025, 1);
		cameraShake('game', 0.0025, 1);
    end
end

function onEvent(name, value1, value2)
	if name == 'UnregulatedEffect' then
		-- for Unregulated
        if value1 == 'normal-v1' then
			doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 1, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

		elseif value1 == 'normal-v2' then
			doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 1, 0.4, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 1, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

			doTweenAlpha('saw1Tween', 'saw1', 1, 0.1, 'sineOut');
			doTweenAlpha('saw2Tween', 'saw2', 1, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1Tween', 'pincer1', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer2Tween', 'pincer2', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer3Tween', 'pincer3', 1, 0.1, 'sineOut');

			doTweenAlpha('saw1-bsodTween', 'saw1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('saw2-bsodTween', 'saw2-bsod', 0, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1-bsodTween', 'pincer1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer2-bsodTween', 'pincer2-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer3-bsodTween', 'pincer3-bsod', 0, 0.1, 'sineOut');

		elseif value1 == 'glitch-sp-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.1, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 1, 0.1, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.1, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 1, 0.1, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.1, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.1, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 1, 0.1, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.1, 'sineOut');

			doTweenAlpha('saw1Tween', 'saw1', 1, 0.1, 'sineOut');
			doTweenAlpha('saw2Tween', 'saw2', 1, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1Tween', 'pincer1', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer2Tween', 'pincer2', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer3Tween', 'pincer3', 1, 0.1, 'sineOut');

			doTweenAlpha('saw1-bsodTween', 'saw1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('saw2-bsodTween', 'saw2-bsod', 0, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1-bsodTween', 'pincer1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer2-bsodTween', 'pincer2-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer3-bsodTween', 'pincer3-bsod', 0, 0.1, 'sineOut');

		elseif value1 == 'glitch-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.1, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 1, 0.1, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.1, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 1, 0.1, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.1, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.1, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 1, 0.1, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.1, 'sineOut');

			doTweenAlpha('saw1Tween', 'saw1', 0, 0.1, 'sineOut');
			doTweenAlpha('saw2Tween', 'saw2', 0, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1Tween', 'pincer1', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer2Tween', 'pincer2', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer3Tween', 'pincer3', 0, 0.1, 'sineOut');

			doTweenAlpha('saw1-bsodTween', 'saw1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('saw2-bsodTween', 'saw2-bsod', 0, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1-bsodTween', 'pincer1-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer2-bsodTween', 'pincer2-bsod', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer3-bsodTween', 'pincer3-bsod', 0, 0.1, 'sineOut');

		elseif value1 == 'bsod-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.1, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.1, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 1, 0.1, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 0.1, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 1, 0.1, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.1, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.1, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 1, 0.1, 'sineOut');

			doTweenAlpha('saw1Tween', 'saw1', 0, 0.1, 'sineOut');
			doTweenAlpha('saw2Tween', 'saw2', 0, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1Tween', 'pincer1', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer2Tween', 'pincer2', 0, 0.1, 'sineOut');
			doTweenAlpha('pincer3Tween', 'pincer3', 0, 0.1, 'sineOut');

			doTweenAlpha('saw1-bsodTween', 'saw1-bsod', 1, 0.1, 'sineOut');
			doTweenAlpha('saw2-bsodTween', 'saw2-bsod', 1, 0.1, 'sineOut');
		
			doTweenAlpha('pincer1-bsodTween', 'pincer1-bsod', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer2-bsodTween', 'pincer2-bsod', 1, 0.1, 'sineOut');
			doTweenAlpha('pincer3-bsodTween', 'pincer3-bsod', 1, 0.1, 'sineOut');

		elseif value1 == 'dark-v1' then
			doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

		elseif value1 == 'dark-v2' then
			doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 0.4, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

		elseif value1 == 'start-v' then
			doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 0, 0.4, 'sineOut');

			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 25, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 1, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

		elseif value1 == 'end-v' then
			doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.4, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.4, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 12, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.4, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 12, 'sineOut');

			doTweenAlpha('glitch-termiTween', 'glitch-termi', 1, 12, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 1, 0.4, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.4, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.4, 'sineOut');

		elseif value1 == 'final-end-v' then
			doTweenAlpha('bgTween', 'bg', 0, 0.2, 'sineOut');
			doTweenAlpha('bg-glitchTween', 'bg-glitch', 0, 0.2, 'sineOut');
			doTweenAlpha('bg-errorTween', 'bg-error', 0, 0.2, 'sineOut');

			doTweenAlpha('kbTween', 'kb', 0, 0.2, 'sineOut');
			doTweenAlpha('kb-404Tween', 'kb-404', 0, 0.2, 'sineOut');
			doTweenAlpha('kb-darkTween', 'kb-dark', 1, 0.2, 'sineOut');

			doTweenAlpha('glitch-termiTween', 'glitch-termi', 1, 0.2, 'sineOut');

			doTweenAlpha('tvs-pTween', 'tvs-p', 0, 0.2, 'sineOut');
			doTweenAlpha('tvs-aTween', 'tvs-a', 0, 0.2, 'sineOut');
			doTweenAlpha('tvs-gTween', 'tvs-g', 0, 0.2, 'sineOut');
			doTweenAlpha('tvs-eTween', 'tvs-e', 0, 0.2, 'sineOut');
		end
		if value2 == 'glitch' then
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0.5, 0.4, 'sineOut');
	
		elseif value2 == 'no-glitch' then
			doTweenAlpha('glitch-termiTween', 'glitch-termi', 0, 0.4, 'sineOut');
		end
	end
end