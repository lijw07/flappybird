class_name HighScoreStore

const SAVE_PATH := "user://high_score.cfg"
const SECTION := "score"
const KEY := "best"


static func load_best() -> int:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	return config.get_value(SECTION, KEY, 0)


static func record(score: int) -> int:
	var best := maxi(score, load_best())
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY, best)
	config.save(SAVE_PATH)
	return best
