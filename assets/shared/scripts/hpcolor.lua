-- script made and modified by arctic fox
-- Script, which will color the score bar, if HP lower/higher then <value>
function onUpdate()
    health = getProperty('health')
    if health < 0.55 then
        setProperty('scoreTxt.color', getColorFromHex("B20000"))
    elseif health > 1.75 then
        setProperty('scoreTxt.color', getColorFromHex("44E500"))
    elseif health > 0.55 and health < 1.75  then
        setProperty('scoreTxt.color', getColorFromHex("A0A0A0"))
    end
end

