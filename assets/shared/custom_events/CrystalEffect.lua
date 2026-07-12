function onEvent(name, value1, value2)
	if name == 'CrystalEffect' then
        -- for beginning and the end
        if value1 == 'start' then
            doTweenAlpha('bgTween', 'bg', 1, 5, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 0, 5, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 1, 5, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 5, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 5, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 5, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 5, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 5, 'sineOut');
        end
        if value1 == 'end' then
            doTweenAlpha('bg-susTween', 'bg-sus', 1, 0.4, 'sineOut');
        end

        -- just usual bg changes
        if value1 == 'normal' then
            doTweenAlpha('bgTween', 'bg', 1, 0.4, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 1, 0.4, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.4, 'sineOut');
        end
        if value1 == 'darker' then
            doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.4, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 1, 0.4, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.4, 'sineOut');
        end
        if value1 == 'black' then
            doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.4, 'sineOut');
        end
        if value1 == 'darker-fast' then
            doTweenAlpha('bgTween', 'bg', 0, 0.2, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.2, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 1, 0.2, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.2, 'sineOut');
        end
        if value1 == 'black-fast' then
            doTweenAlpha('bgTween', 'bg', 0, 0.2, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 0, 0.2, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.2, 'sineOut');
        end

        -- bg color thing
        -- normal color change
        if value1 == 'purple' then
            doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.4, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 1, 0.4, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 1, 0.4, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.4, 'sineOut');
        end
        if value1 == 'pink' then
            doTweenAlpha('bgTween', 'bg', 0, 0.4, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.4, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.4, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 1, 0.4, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.4, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 1, 0.4, 'sineOut');
        end
        -- fast color change
        if value1 == 'purple-fast' then
            doTweenAlpha('bgTween', 'bg', 0, 0.2, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.2, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 1, 0.2, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 1, 0.2, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 0, 0.2, 'sineOut');
        end
        if value1 == 'pink-fast' then
            doTweenAlpha('bgTween', 'bg', 0, 0.2, 'sineOut');
            doTweenAlpha('bg-darkTween', 'bg-dark', 1, 0.2, 'sineOut');
            doTweenAlpha('floorTween', 'floor', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-darkTween', 'floor-dark', 0, 0.2, 'sineOut');
            doTweenAlpha('floor-pinkTween', 'floor-pink', 1, 0.2, 'sineOut');
            doTweenAlpha('floor-purpleTween', 'floor-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-purpleTween', 'window-purple', 0, 0.2, 'sineOut');
            doTweenAlpha('window-pinkTween', 'window-pink', 1, 0.2, 'sineOut');
        end
    end
end
        