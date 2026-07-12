-- script made by Ed and modified by acrtic fox
function onCreate()
    -- Number "3"
    makeLuaSprite('3', '3,2,1,go/3', 0,0)
    setObjectCamera('3', 'HUD')
    addLuaSprite('3', true)
    setProperty('3.alpha', 0)
    -- Number "2"
    makeLuaSprite('2', '3,2,1,go/2', 0,0)
    setObjectCamera('2', 'HUD')
    addLuaSprite('2', true)
    setProperty('2.alpha', 0)
    -- Number "1"
    makeLuaSprite('1', '3,2,1,go/1', 0,0)
    setObjectCamera('1', 'HUD')
    addLuaSprite('1', true)
    setProperty('1.alpha', 0)
    -- Text "GO!"
    makeLuaSprite('go', '3,2,1,go/go', 0,0)
    setObjectCamera('go', 'HUD')
    addLuaSprite('go', true)
    setProperty('go.alpha', 0)
end

function onCountdownTick(counter)
    if counter == 0 then
        setProperty('3.alpha', 1)
        doTweenAlpha('bye', '3', 0, 0.4, 'easeOut')
        playSound('3,2,1,go!/3', 1)
        end
    if counter == 1 then
        setProperty('2.alpha', 1)
        doTweenAlpha('bye', '2', 0, 0.4, 'easeOut')
        playSound('3,2,1,go!/2', 1)

         doTweenAlpha('bye1', '3', 0, 0.1, 'easeOut') -- if didnt delete
    end
    if counter == 2 then
        setProperty('1.alpha', 1)
        doTweenAlpha('bye', '1', 0, 0.4, 'easeOut')
        playSound('3,2,1,go!/1', 1)

        doTweenAlpha('bye1', '2', 0, 0.1, 'easeOut') -- if didnt delete
    end
    if counter == 3 then
        setProperty('go.alpha', 1)
        doTweenAlpha('bye', 'go', 0, 0.4, 'easeOut')
        playSound('3,2,1,go!/GO', 1)

        doTweenAlpha('bye1', '1', 0, 0.1, 'easeOut') -- if didnt delete
    end
    if counter == 4 then
        doTweenAlpha('bye', 'go', 0, 0.1, 'easeOut') -- if didnt delete
        doTweenAlpha('bye1', '3', 0, 0.1, 'easeOut') -- if didnt delete^2
        doTweenAlpha('bye2', '2', 0, 0.1, 'easeOut') -- if didnt delete^3
        doTweenAlpha('bye3', '1', 0, 0.1, 'easeOut') -- if didnt delete^4
    end
end

-- Explanation:
    -- counter = 0 -> "3".
    -- counter = 1 -> "2".
    -- counter = 2 -> "1".
    -- counter = 3 -> "Go!".
    -- counter = 4 -> Nothing, but its being +-triggered at the same time as onSongStart.