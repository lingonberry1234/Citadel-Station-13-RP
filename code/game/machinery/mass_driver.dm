
/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	anchored = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 2
	active_power_usage = 50
	circuit = /obj/item/circuitboard/mass_driver

	var/power = 1
	var/code = 1
	var/id = 1
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.

/obj/machinery/mass_driver/Initialize(mapload, newdir)
	. = ..()
	default_apply_parts()

/obj/machinery/mass_driver/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, I))
		return
	if(default_deconstruction_crowbar(user, I))
		return

	if(istype(I, /obj/item/multitool))
		if(panel_open)
			var/input = sanitize(input(usr, "What id would you like to give this conveyor?", "Multitool-Conveyor interface", id))
			if(!input)
				to_chat(usr, SPAN_WARNING("No input found please hang up and try your call again."))
				return
			id = input
			return
	return

/obj/machinery/mass_driver/proc/drive(amount)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	use_power(500)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored||istype(O, /obj/mecha))//Mechs need their launch platforms.
			O_limit++
			if(O_limit >= 20)
				for(var/mob/M in hearers(src, null))
					to_chat(M, SPAN_NOTICE("The mass driver lets out a screech, it mustn't be able to handle any more items."))
				break
			use_power(500)
			spawn(0)
				O.throw_at(target, drive_range * power, power)
	flick("mass_driver1", src)
	return

/obj/machinery/mass_driver/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	drive()
	..(severity)
