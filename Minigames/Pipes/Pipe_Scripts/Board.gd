extends Node2D

const GRID_SIZE := Vector2i(8, 8)
const CELL_SIZE := 32

@export var pipe_tiles: PackedScene
@export var enemy_scene: PackedScene
@export var start_end: PackedScene

@onready var straight_button = $"../CanvasLayer/HBoxContainer/Straight"
@onready var corner_button = $"../CanvasLayer/HBoxContainer/Corner"
@onready var tee_button = $"../CanvasLayer/HBoxContainer/Tee"
@onready var cross_button = $"../CanvasLayer/HBoxContainer/Cross"
@onready var build_timer: Timer = $"../CanvasLayer/BuildTimer"
@onready var time_label: Label = $"../CanvasLayer/TimeLabel"


var start_pos: Vector2i
var end_pos: Vector2i
var obsta: Array[Vector2i] = []

var solution_path: Array[Vector2i] = []
var water_path: Array[Vector2i] = []
var water_running := false
var tiles_watered: Array[Vector2i] = []

var start_tile
var end_tile

var selected_pipe_type := "straight"
var placed_pipes := {}

var pipe_inventory := {
	"straight": 0,
	"corner": 0,
	"tee": 0,
	"cross": 0
}

var can_edit := true

func _ready() -> void:
	generate_start_and_end()
	gene_solutionpath()
	gene_obs(8)
	
	place_start_and_end()
	place_enemies()
	check_what_pipe()
	add_extra_pipes()
	
	build_timer.timeout.connect(start_water_phase)
	build_timer.start()
	
	update_pipe_ui()
	queue_redraw()
	

func _process(_delta: float) -> void:
	if can_edit and not water_running:
		time_label.text = str(ceil(build_timer.time_left))

func generate_start_and_end() -> void:
	start_pos = Vector2i(
		0,
		randi_range(0, GRID_SIZE.y -1)
	)
	end_pos = Vector2i(
		GRID_SIZE.x - 1,
		randi_range(0, GRID_SIZE.y - 1)
	)
	
	print("Start: ", start_pos)
	print("End: ", end_pos)

func gene_solutionpath() -> void:
	var current_pos := start_pos
	
	solution_path.append(current_pos)
	
	while current_pos != end_pos:
		var possible_moves: Array[Vector2i] = []
		#first mo e right
		if current_pos.x < end_pos.x:
				possible_moves.append(Vector2i.RIGHT)
		
		#the move verticalle towadrs the end
		if current_pos.y < end_pos.y:
			possible_moves.append(Vector2i.DOWN)
		elif current_pos.y > end_pos.y:
			possible_moves.append(Vector2i.UP)
			
		var move: Vector2i = possible_moves.pick_random()
		current_pos += move
		
		solution_path.append(current_pos)
		
#		print("Solution path: ", solution_path)	

func gene_obs(amount: int) -> void:
	obsta.clear()
	
	while obsta.size() < amount:
		var random_pos := Vector2i(
			randi_range(0, GRID_SIZE.x - 1),
			randi_range(0, GRID_SIZE.y - 1)
		)
		if random_pos in solution_path:
			continue
		if random_pos in obsta:
			continue
		obsta.append(random_pos)


#PIPE STUFF!

func update_pipe_ui() -> void:
	straight_button.text = "x" + str(pipe_inventory["straight"])
	corner_button.text = "x" + str(pipe_inventory["corner"])
	tee_button.text = "x" + str(pipe_inventory["tee"])
	cross_button.text = "x" + str(pipe_inventory["cross"])
	
	straight_button.disabled = pipe_inventory["straight"] <= 0
	corner_button.disabled = pipe_inventory["corner"] <= 0
	tee_button.disabled = pipe_inventory["tee"] <= 0
	cross_button.disabled = pipe_inventory["cross"] <= 0
		
func check_what_pipe() -> void:
	#NULL THE INVI BEFORE NEW COUNT!
	pipe_inventory = {
		"straight": 0,
		"corner": 0,
		"tee": 0,
		"cross": 0
	}
	for i in range(1, solution_path.size() - 1):
		var previous := solution_path[i - 1]
		var current := solution_path[i]
		var next := solution_path[i + 1]

		var dir_in := previous - current
		var dir_out := next - current

		var directions := [dir_in, dir_out]

		if (
			Vector2i.LEFT in directions
			and Vector2i.RIGHT in directions
		):
			pipe_inventory["straight"] += 1

		elif (
			Vector2i.UP in directions
			and Vector2i.DOWN in directions
		):
			pipe_inventory["straight"] += 1

		else:
			pipe_inventory["corner"] += 1

func add_extra_pipes() -> void:
	pipe_inventory["straight"] += randi_range(1, 3)
	pipe_inventory["corner"] += randi_range(1, 3)
	
	
	if randf() < 0.5:
		pipe_inventory["tee"] += 1

	if randf() < 0.2:
		pipe_inventory["cross"] += 1

func _draw() -> void:
	#DRAW GRID
	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			var cell_pos := Vector2(
				x * CELL_SIZE,
				y * CELL_SIZE
			)
			
			draw_rect(
				Rect2(cell_pos, Vector2(CELL_SIZE, CELL_SIZE)),
				Color.WHITE,
				false,
				
			)
	#DRAW SOLUTION
	#for cell in solution_path:
	#	var cell_pos := Vector2(
	#		cell.x * CELL_SIZE,
	#		cell.y * CELL_SIZE
	#	)
		
	#	draw_rect(
	#		Rect2(cell_pos, Vector2(CELL_SIZE, CELL_SIZE)),
	#		Color(0.348, 0.746, 0.739, 1.0),
	#		true
	#	)

func try_place_pipe(grid_pos: Vector2i) -> void:
	#print("CLICK: ", grid_pos)
	if grid_pos in tiles_watered:
		return
	if not is_inside_grid(grid_pos):
		return
	if grid_pos in obsta:
		return
#	if grid_pos == start_pos or grid_pos == end_pos:
#		return
	if grid_pos == start_pos:
		start_tile.set_rotation_step((start_tile.rotation_step + 1) % 4)
		return

	if grid_pos == end_pos:
		end_tile.set_rotation_step((end_tile.rotation_step + 1) % 4)
		return
	if placed_pipes.has(grid_pos):
		var pipe = placed_pipes[grid_pos]
		pipe.rotate_pipe()
		return
	
	if pipe_inventory[selected_pipe_type] <= 0:
		print("No ", selected_pipe_type, " pipes left!")
		return
	place_pipe(selected_pipe_type, grid_pos)
		
#HELPER FOR PIPE_PLACEMENT
func is_inside_grid(grid_pos: Vector2i) -> bool:
	return (
		grid_pos.x >= 0
		and grid_pos.x < GRID_SIZE.x
		and grid_pos.y >= 0
		and grid_pos.y < GRID_SIZE.y
	)
	
func select_pipe(type_name: String) -> void:
	selected_pipe_type = type_name
	print("Selected pipe: ", selected_pipe_type)
	

func place_pipe(type_name: String, grid_pos: Vector2i) -> void:
	var pipe = pipe_tiles.instantiate()
	add_child(pipe)

	match type_name:
		"straight":
			pipe.setup(pipe.PipeType.STRAIGHT, grid_pos)
			
		"corner":
			pipe.setup(pipe.PipeType.CORNER, grid_pos)

		"tee":
			pipe.setup(pipe.PipeType.TEE, grid_pos)

		"cross":
			pipe.setup(pipe.PipeType.CROSS, grid_pos)

	placed_pipes[grid_pos] = pipe
	pipe_inventory[type_name] -= 1

	update_pipe_ui()
#	print("Placed ", type_name, " at ", grid_pos)
#	print("Remaining pipes: ", pipe_inventory)
	
func try_remove_pipe(grid_pos: Vector2i) -> void:
	if grid_pos in tiles_watered:
		return
	if not placed_pipes.has(grid_pos):
		return
	var pipe = placed_pipes[grid_pos]
	
	match pipe.pipe_type:
		pipe.PipeType.STRAIGHT:
			pipe_inventory["straight"] += 1

		pipe.PipeType.CORNER:
			pipe_inventory["corner"] += 1

		pipe.PipeType.TEE:
			pipe_inventory["tee"] += 1

		pipe.PipeType.CROSS:
			pipe_inventory["cross"] += 1

	placed_pipes.erase(grid_pos)
	pipe.queue_free()
	update_pipe_ui()

#START AND END 

func place_start_and_end() -> void:
	start_tile = start_end.instantiate()
	add_child(start_tile)
	start_tile.pipe_type = start_tile.PipeType.START
	start_tile.grid_pos = start_pos
	start_tile.position = Vector2(
		start_pos.x * CELL_SIZE,
		start_pos.y * CELL_SIZE
	)
	start_tile.update_sprite()
	#var start_direction: Vector2i = solution_path[1] - start_pos
	#start_tile.set_direction(start_direction)	
	#DEBUG
	#print("START desired dir: ", start_direction)
	#print("START rotation step: ", start_tile.rotation_step)
	#print("START actual connections: ", start_tile.get_connections())
	
	
	end_tile = start_end.instantiate()
	add_child(end_tile)
	end_tile.pipe_type = end_tile.PipeType.END1
	end_tile.grid_pos = end_pos
	end_tile.position = Vector2(
		end_pos.x * CELL_SIZE,
		end_pos.y * CELL_SIZE
	)
	end_tile.update_sprite()	
	#var before_end: Vector2i = solution_path[solution_path.size() - 2]
	#var end_direction: Vector2i = before_end - end_pos

	#end_tile.set_direction(end_direction)

	
#WATERFLOW

func check_water_path() -> bool:
	
#	print("START connections: ", start_tile.get_connections())
#	print("END connections: ", end_tile.get_connections())
	water_path.clear()
	
	var visited: Array[Vector2i] = []
	var to_check: Array[Vector2i] = [start_pos]

	while not to_check.is_empty():
		var current: Vector2i = to_check.pop_front()
		
		if current in visited:
			continue
			
		visited.append(current)
		water_path.append(current)
		
		if current == end_pos:
			print("Water reached the end!")
			return true
		
		for dir in get_cell_directions(current):
			var next_pos := current + dir
			
			if can_flow(current, next_pos, dir):
				to_check.append(next_pos)
				
	print("WATER IS LEAKING!!")
	return false
				
func get_cell_directions(grid_pos: Vector2i) -> Array[Vector2i]:
	if grid_pos == start_pos:
		return start_tile.get_connections()

	if grid_pos == end_pos:
		return end_tile.get_connections()

	if placed_pipes.has(grid_pos):
		return placed_pipes[grid_pos].get_connections()

	return []
		
func can_flow(current_pos: Vector2i, next_pos: Vector2i, dir: Vector2i) -> bool:
	if next_pos == end_pos:
		return -dir in end_tile.get_connections()
		
	if not placed_pipes.has(next_pos):
		return false
	
	var next_pipe = placed_pipes[next_pos]
	
	return -dir in next_pipe.get_connections()

#ENEMIES
func place_enemies() -> void:
	for obsta_pos in obsta:
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.setup_enemies(obsta_pos)
	
	
#WATERMOVES!!
func flow_water() -> void:
	var frontwa: Array[Vector2i] = [start_pos]
	var visited_tiles: Array[Vector2i] = []
	
	while not frontwa.is_empty():
		var next_fw: Array[Vector2i] = []
		
		for current in frontwa:
			if current in visited_tiles:
				continue
			
			visited_tiles.append(current)
			tiles_watered.append(current)
			
			var tile: Node2D = null
			
			if current == start_pos:
				tile = start_tile
			elif current == end_pos:
				tile = end_tile
			elif placed_pipes.has(current):
				tile = placed_pipes[current]
			
			if tile == null:
				end_game(false)
				return
				
			var tween := create_tween()
			tween.tween_property(tile, "modulate", Color(0.3, 0.8, 1.0), 0.4)
			await tween.finished
		
			if current == end_pos:
				end_game(true)
				return
			for dir in get_cell_directions(current):
				var next_pos := current + dir
				if next_pos in visited_tiles:
					continue
				
				if not is_inside_grid(next_pos):
					end_game(false)
					return
				if not can_flow(current, next_pos, dir):
					end_game(false)
					return
				if next_pos not in visited_tiles:
					next_fw.append(next_pos)
		frontwa = next_fw
		await get_tree().create_timer(0.35).timeout
	end_game(false)

#ENDGAME!

func end_game(success: bool) -> void:
	water_running = false
	can_edit = false
	
	GameResult.success = success

	if success:
		time_label.text = "SUCCESS!"
		print("WON!")
	else:
		time_label.text = "FLOOD!"
		print("GAME OVER!")
	
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
	
	
func start_water_phase() -> void:
	water_running = true
	time_label.text = "WATER!"
	await flow_water()
		
func animate_water() -> void:
	for grid_pos in water_path:
		var tile: Node2D = null
		
		if grid_pos == start_pos:
			tile = start_tile
		elif  grid_pos == end_pos:
			tile = end_tile
		elif placed_pipes.has(grid_pos):
			tile = placed_pipes[grid_pos]
		
		if tile != null:
			var letsgo := create_tween()
			letsgo.tween_property(tile, "modulate", Color(0.3, 0.8, 1.0), 0.2)
			await letsgo.finished
		
		await get_tree().create_timer(0.15).timeout

#INPUT!
func _unhandled_input(event: InputEvent) -> void:
	if not can_edit:
		return 
	if event is InputEventMouseButton and event.pressed:
		var local_mouse := to_local(event.position)

		var grid_pos := Vector2i(
			int(local_mouse.x / CELL_SIZE),
			int(local_mouse.y / CELL_SIZE)
		)

		if event.button_index == MOUSE_BUTTON_LEFT:
			try_place_pipe(grid_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			try_remove_pipe(grid_pos)


func _on_straight_pressed() -> void:
	select_pipe("straight")

func _on_corner_pressed() -> void:
	select_pipe("corner")
	
func _on_tee_pressed() -> void:
	select_pipe("tee")

func _on_cross_pressed() -> void:
	select_pipe("cross")


#TEMP TEST!!
#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_accept"):
#		var success := check_water_path()
#		await animate_water()		
#		if success:
#			print("WON")
#		else:
#			print("FLOOD")
		#check_water_path()
