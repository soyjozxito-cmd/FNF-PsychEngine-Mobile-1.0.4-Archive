-- script made and modified by arctic fox
function onCreatePost()
        -- changes color
        setProperty('scoreTxt.color', getColorFromHex("A0A0A0")) -- changes color of score text
        setProperty('botplayTxt.color', getColorFromHex("004B69")) -- changes color of bot text
        setProperty('timeBar.color', getColorFromHex("004B69")) -- changes color of time bar
        setProperty('timeTxt.color', getColorFromHex("00B4CC")) -- changes color of time text
        setProperty('JukeBoxText.color', getColorFromHex("FFFFFF")) -- changes color of jukebox text
        setProperty('JukeBoxSubText.color', getColorFromHex("808080")) -- changes color jukebox subtext
        setProperty('JukeDifBoxText.color', getColorFromHex("FFFFFF")) -- changes color of jukebox text
        setProperty('JukeDifBoxSubText.color', getColorFromHex("202020")) -- changes color jukebox subtext

        -- font
        setTextFont("botplayTxt", "pixelfont.ttf");
        setTextFont("scoreTxt", "pixelfont.ttf");
        setTextFont("timeTxt", "pixelfont.ttf");
        setTextFont("JukeBoxText", "pixelfont.ttf");
        setTextFont("JukeBoxSubText", "pixelfont.ttf");
        setTextFont("JukeDifBoxText", "pixelfont.ttf");
        setTextFont("JukeDifBoxSubText", "pixelfont.ttf");
        setTextFont("WarningBoxText", "pixelfont.ttf");
        setTextFont("WarningBoxSubText", "pixelfont.ttf");

        -- size
        setTextSize("botplayTxt", 36);
        setTextSize("scoreTxt", 24);
        setTextSize("timeTxt", 33);
end

