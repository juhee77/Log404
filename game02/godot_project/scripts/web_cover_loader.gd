class_name WebCoverLoader
extends Node

# Simple utility to load images from user:// or web url and create ImageTexture
static func load_texture_from_file(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var img = Image.load_from_file(path)
	if img != null:
		return ImageTexture.create_from_image(img)
	return null

static func create_placeholder_texture(color: Color, width: int = 120, height: int = 180) -> Texture2D:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
