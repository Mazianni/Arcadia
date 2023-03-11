extends Node

func metric2imperial(input):
	var cm2in = 0.39
	var inconvert = round((input*cm2in))
	var ft = 0
	while inconvert > 11:
		inconvert -= 11
		ft += 1
	return str(ft)+"'"+str(inconvert)
