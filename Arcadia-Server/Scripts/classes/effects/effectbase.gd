class_name EffectBase extends Resource

@export var name : String
@export var description : String
@export var texture : String
@export var max_stacks : int = 100
@export var current_stacks : int
@export var effect_length : int
@export var expires_on : float #unix time, used for non-ephemeral effects.
@export var can_stack : bool = true
@export var ephemeral : bool = true #effect is not serialized.
@export var refresh_on_stack : bool = true
@export var tick_on_stack_falloff : bool = false
@export var unique_per_stack : bool = false #if true, each new stack is handled as it's own entity.
	
func OnApplication(character:ActiveCharacter):
	return
	
func OnExpiration(character:ActiveCharacter):
	return
	
func TickEffect(character:ActiveCharacter):
	return
	
func HandleAddAuxData(character:ActiveCharacter, stack_aux:Dictionary, input_aux:Dictionary):
	return
	
func HandleRemoveAuxData(character:ActiveCharacter, stack_aux:Dictionary, input_aux:Dictionary):
	return
