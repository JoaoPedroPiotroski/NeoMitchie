extends Resource
class_name DialogueEvent

enum Types {
	DIALOGUE
}
@export_storage var type : Types = Types.DIALOGUE

# DIALOGUE vars
@export_storage var dialogue_line : String
