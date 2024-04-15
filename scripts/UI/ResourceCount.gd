extends Label
class_name ResourceCount

@export var resource: UI.ResourceEnum;

var quantity: int = 0:
	set(new_quantity):
		quantity = new_quantity;
		text = str(quantity);

var capped_resource: int = 0:
	set(new_quantity):
		capped_resource = new_quantity
		text = str(capped_resource) + "/" + str(GameManager.unit_cap)

func _ready():
	UI.register_resource_count(self);
