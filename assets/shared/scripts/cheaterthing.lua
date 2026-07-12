function onCreate() -- its just makes cheater bg, its not the anti-cheat itself
    -- cheat bg
    makeLuaSprite('cheatercheatercheater', 'hazard/inhuman-port/cheat-bg', -100, -75)
	setObjectCamera('cheatercheatercheater', 'other')
    setGraphicSize('cheatercheatercheater', 1600, 900)
    -- cheater text
    makeLuaSprite('cheater', 'hazard/inhuman-port/cheat', 375, 100)
	setObjectCamera('cheater', 'other')
end