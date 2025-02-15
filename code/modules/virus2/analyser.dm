/obj/machinery/disease2/diseaseanalyser
	name = "disease analyser"
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1

	var/scanning = 0
	var/pause = 0

	var/obj/item/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/O as obj, var/mob/user as mob)
	if(default_unfasten_wrench(user, O, 20))
		return

	else if(!istype(O,/obj/item/virusdish)) return

	if(dish)
		to_chat(user, "\The [src] is already loaded.")
		return

	dish = O
	user.drop_item()
	O.loc = src

	user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")

/obj/machinery/disease2/diseaseanalyser/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			if (dish.virus2.addToDB())
				ping("\The [src] pings, \"New pathogen added to data bank.\"")

			var/obj/item/paper/P = new /obj/item/paper(src.loc)
			var/info = dish.virus2.get_info()
			P.name = "paper - [dish.virus2.name()]"
			P.info = "[virology_letterhead("Post-Analysis Memo")]<br>[info]<hr><u>Additional Notes:</u><br>"
			dish.basic_info = dish.virus2.get_basic_info()
			dish.info = info
			dish.name = "[initial(dish.name)] ([dish.virus2.name()])"
			dish.analysed = 1
			dish.loc = src.loc
			dish = null

			icon_state = "analyser"
			src.state("\The [src] prints a sheet of paper.")

	else if(dish && !scanning && !pause)
		if(dish.virus2 && dish.growth > 50)
			dish.growth -= 10
			scanning = 5
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.loc = src.loc
				dish = null

				src.state("\The [src] buzzes, \"Insufficient growth density to complete analysis.\"")
				pause = 0
