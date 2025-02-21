extends StaticBody3D

signal toggle_external_inventory(external_inventory_owner)

@export var inventory_data: InventoryData


func player_interact() -> void:
	toggle_external_inventory.emit(self)
