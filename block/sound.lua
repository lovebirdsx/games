sound = {}

local SOUND_CFG = {
	gameover = 'sound/gameover.mp3',
	highscore = 'sound/highscore.mp3',
	menu = 'sound/menu.mp3',
	music = 'sound/music.mp3',
	pickup = 'sound/pickup.mp3',
	place = 'sound/place.mp3',
	placewrong = 'sound/placewrong.mp3',
	row1 = 'sound/row1.mp3',
	row2 = 'sound/row2.mp3',
	row3 = 'sound/row3.mp3',
	row4 = 'sound/row4.mp3',
	row5 = 'sound/row5.mp3',
	row6 = 'sound/row6.mp3',
	row7 = 'sound/row7.mp3',
	row8 = 'sound/row8.mp3',
	row9 = 'sound/row9.mp3',
	row10 = 'sound/row10.mp3',
	success1 = 'sound/success1.mp3',
	success2 = 'sound/success2.mp3',
	success3 = 'sound/success3.mp3',
	success4 = 'sound/success4.mp3',
	success5 = 'sound/success5.mp3',
	success6 = 'sound/success6.mp3',
	swipe = 'sound/swipe.mp3',
	voice_tier1 = 'sound/voice_tier1.mp3',
	voice_tier2 = 'sound/voice_tier2.mp3',
	voice_tier3 = 'sound/voice_tier3.mp3',
	voice_tier4 = 'sound/voice_tier4.mp3',
	voice_tier5 = 'sound/voice_tier5.mp3',
	voice_tier6 = 'sound/voice_tier6.mp3',
	voice_tier7 = 'sound/voice_tier7.mp3'
}

local _sounds = {}

function sound.init()
	for type, path in pairs(SOUND_CFG) do
		_sounds[type] = love.audio.newSource(path)
	end
	_sounds['music']:setLooping(true)
end

function sound.play_tier(id)
	if id > 7 then id = 7 end
	_sounds['voice_tier' .. id]:play()
end

function sound.play(type)
	local s = _sounds[type]
	if s then 
		s:play()
	else
		print('play sound failed:' .. type)
	end
end

function sound.stop(type)
	_sounds[type]:stop()
end