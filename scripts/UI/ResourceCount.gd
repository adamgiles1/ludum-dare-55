extends Label
class_name ResourceCount

@export var resource : UI.ResourceEnum;

var quantity: int = 0:
	set(new_quantity):
		quantity = new_quantity;
		text = str(quantity);

func _ready():
	UI.register_resource_count(self);
