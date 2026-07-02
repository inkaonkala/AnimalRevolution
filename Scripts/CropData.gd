extends Resource
class_name CropData

@export var seed_id: String
@export var crop_id: String

@export var seed_tex: Texture2D
@export var watered_tex: Texture2D
@export var ready_tex: Texture2D

@export var growth_texs: Array[Texture2D]
@export var wet_growth_texs: Array[Texture2D]

@export var harvest_amount := 1
@export var seed_return_amount := 1
