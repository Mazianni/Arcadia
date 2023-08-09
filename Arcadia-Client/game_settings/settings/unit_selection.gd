@tool
extends ggsSetting

var measurement_unit: int : set = set_unit_measurement

func _init():
	super()
	name = "Unit Selection"
	desc = "Select a measurement system."
	default = 0
	
	value_type = TYPE_INT
	
func apply(value):
	match value:
		0:
			Globals.measurement_units = "Imperial"
		1:
			Globals.measurement_units = "Metric"
	set_unit_measurement(value)

func set_unit_measurement(value):

	measurement_unit = value
	match value:
		0:
			Globals.measurement_units = "Imperial"
		1:
			Globals.measurement_units = "Metric"
	if is_added():
		save_plugin_data()
	

