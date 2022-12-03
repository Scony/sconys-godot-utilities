extends Timer


func _ready():
	yield(self, "timeout")
	queue_free()
