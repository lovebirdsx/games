require('mode_select')
require('endless_play')
require('state_manager')
require('chapter_select')
require('stage_play')
require('stage_select')

states = {}

function states.init()
	local sm = StateManager:instance()
	sm:reg('ModeSelect', ModeSelect)
	sm:reg('EndlessPlay', EndlessPlay)
	sm:reg('ChapterSelect', ChapterSelect)
	sm:reg('StageSelect', StageSelect)
	sm:reg('StagePlay', StagePlay)
end
