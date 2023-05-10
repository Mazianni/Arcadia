tool
extends TileSet

const LEFT_TRANSITION = 45
const RIGHT_TRANSITION = 37
const CLIFFTOP = 34
const CLIFFBASE = 39

var binds = {
	CLIFFTOP: [LEFT_TRANSITION, RIGHT_TRANSITION, CLIFFBASE],
	CLIFFBASE: [LEFT_TRANSITION, RIGHT_TRANSITION, CLIFFTOP]
}

func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in binds:
		return neighbor_id in binds[drawn_id]
	return false
