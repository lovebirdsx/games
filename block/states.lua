require('mode_select')
require('endless_play')
require('state_manager')
require('chapter_select')
require('play_stage')
require('stage_select')
require('editor')
require('stage_filter')

states = {}

function states.init()
	local sm = StateManager:instance()
	sm:reg('ModeSelect', ModeSelect)
	sm:reg('EndlessPlay', EndlessPlay)
	sm:reg('ChapterSelect', ChapterSelect)
	sm:reg('StageSelect', StageSelect)
	sm:reg('PlayStage', PlayStage)
	sm:reg('Editor', Editor)
	sm:reg('StageFilter', StageFilter)
end
