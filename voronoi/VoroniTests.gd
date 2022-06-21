extends Spatial

const VORONOI_SHAPE = preload("res://voronoi/VoronoiShape.tscn")

# The minimum size of a Voronoi Square, in world units.
const SQUARE_GENERATE_STEP = 1

const XMIN = -7.5
const XMAX =  7.5
const ZMIN = -7.5
const ZMAX =  7.5

var voronoi_shapes = []
var spawn_started = false
var yield_proc = null

# Called when the node enters the scene tree for the first time.
func _ready():
    $Timer.start()

func spawn_process():
    var voro
    var x
    var z
    
    for old_shape in voronoi_shapes:
        self.remove_child(old_shape)
        old_shape.queue_free()
    
    $SpawnBar.visible = true
    $SpawnBar.global_transform.origin.x = XMIN
    while $SpawnBar.global_transform.origin.x <= XMAX:
        x = $SpawnBar.global_transform.origin.x
        z = ZMIN
        while z <= ZMAX:
            voro = VORONOI_SHAPE.instance()
            voro.global_transform.origin = Vector3(x, 0, z)
            self.add_child(voro)
            voronoi_shapes.append(voro)
            z += SQUARE_GENERATE_STEP
        $SpawnBar.global_transform.origin.x += SQUARE_GENERATE_STEP
        yield()
    
    $SpawnBar.visible = false
    
    return null


func _on_Timer_timeout():
    if not spawn_started:
        yield_proc = spawn_process()
        spawn_started = true
        $Timer.start()
    elif not yield_proc == null:
        yield_proc = yield_proc.resume()
        $Timer.start()
