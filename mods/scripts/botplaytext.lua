-- script made and modified by arctic fox
function onCreate() -- Function, which will choose random number for using the text -> each text has number.
        num = getRandomInt(0,9)
end

-- Special songs, which use special text (aka inhumans and hitmans).
function onCreatePost()
        if songName == 'Tutorial' then
                num = getRandomInt(50450,50450)
        end
        if songName == 'Interlope' then
                num = getRandomInt(10,14)
        elseif songName == 'Reignite' then
                num = getRandomInt(10,14)
        elseif songName == 'Unregulated' then
                num = getRandomInt(10,14)
        end
        if songName == 'IceBeat' then
                num = getRandomInt(20,24)
        end
        if songName == 'Forgotten' then
                num = getRandomInt(30,34)
        end
        if songName == 'Crystallized' then
                num = getRandomInt(40,44)
        elseif songName == 'Disgraced' then
                num = getRandomInt(40,44)
        end
        if songName == 'KB-Classic' then -- Do not ask what is this.
                num = getRandomInt(101,101)
        end
end

function onUpdate()
                -- Text for usual songs.
		if num == 0 then
                        setTextString("botplayTxt", "!BOTPLAY!\nPlaying the song")
		elseif num == 1 then
			setTextString("botplayTxt", "!BOTPLAY!\nMade by Arctic Fox")
		elseif num == 2 then
                        setTextString("botplayTxt", "!BOTPLAY!\nAre you corrupted?") 
                elseif num == 3 then
                        setTextString("botplayTxt", "!BOTPLAY!\nAlert, Alert, KB!")
                elseif num == 4 then
                        setTextString("botplayTxt", "!BOTPLAY!\nawuaawueeee")
		elseif num == 5 then
			setTextString("botplayTxt", "!BOTPLAY!\nWhat is this timeline?")
                elseif num == 6 then
			setTextString("botplayTxt", "!BOTPLAY!\nStop using BOTPLAY!")
                elseif num == 7 then
			setTextString("botplayTxt", "!BOTPLAY!\nTry to search deeper!")
                elseif num == 8 then
			setTextString("botplayTxt", "!BOTPLAY!\nDude, are you AFK?")
                elseif num == 9 then
			setTextString("botplayTxt", "!BOTPLAY!\nMassacre is soon!")
                end

                -- Text for inhumans songs.
                if num == 10 then
                        setTextString("botplayTxt", "!BOTPLAY!\nSearched deeper?")
                elseif num == 11 then
                        setTextString("botplayTxt", "!BOTPLAY!\n<Inhumans ~= Massacre>")
                elseif num == 12 then
                        setTextString("botplayTxt", "!BOTPLAY!\nThey won't be happy")
                elseif num == 13 then
                        setTextString("botplayTxt", "!BOTPLAY!\nKB, where are you!")
                elseif num == 14 then
                        setTextString("botplayTxt", "!BOTPLAY!\nDisable BOTPLAY!")
                end
                
                -- Text for hitmans songs.
                if num == 20 then
                        setTextString("botplayTxt", "!BOTPLAY!\nY0U'R3 N01 R34DY!")  
                elseif num == 21 then
                        setTextString("botplayTxt", "!BOTPLAY!\n<Hitmans ~= D4NG3R0US>")
                elseif num == 22 then
                        setTextString("botplayTxt", "!BOTPLAY!\nThey will kill you")
                elseif num == 23 then
                        setTextString("botplayTxt", "!BOTPLAY!\nWhen this will end?")
                elseif num == 24 then
                        setTextString("botplayTxt", "!BOTPLAY!\nDisable BOTPLAY!")
                end

                -- Don't forget about it.
                if num == 30 then
                        setTextString("botplayTxt", "!BOTPLAY!\nYou don't know me")
                elseif num == 31 then
                        setTextString("botplayTxt", "!BOTPLAY!\nThey forgot me")
                elseif num == 32 then
                        setTextString("botplayTxt", "!BOTPLAY!\nNobody will help you")
                elseif num == 33 then
                        setTextString("botplayTxt", "!BOTPLAY!\nIs this the end?")
                elseif num == 34 then
                        setTextString("botplayTxt", "!BOTPLAY!\n#%>C0RRUP13D<%#")
                end

                -- Yotty, I think you want to kill player.
                if num == 40 then
                        setTextString("botplayTxt", "!BOTPLAY!\nDo you feel safe?...")
                elseif num == 41 then
                        setTextString("botplayTxt", "!BOTPLAY!\nSonorous crystals...")
                elseif num == 42 then
                        setTextString("botplayTxt", "!BOTPLAY!\nWhy are you using Botplay?")
                elseif num == 43 then
                        setTextString("botplayTxt", "!BOTPLAY!\nDisable BOTPLAY!")
                elseif num == 44 then
                        setTextString("botplayTxt", "!BOTPLAY!\nYou will die...")
                end

                -- Dumb text for tutorial lmao.
                if num == 50450 then
                        setTextString("botplayTxt", "!BOTPLAY!\nBRUH IT'S A TUTORIAL")
                end

                -- I said do not ask what is this.
                if num == 101 then
                        setTextString("botplayTxt", "!BOTPLAY!\nHow did you get here?")
                end
end