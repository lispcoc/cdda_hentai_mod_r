--[[translation-related functions]]--

--[[test/debug]]--
function testPro()
	local selected_point = pointAt()
	
	if (selected_point == nil) then
		return
	end
	
	local obj = g:critter_at(selected_point)
	if (obj:is_monster()) then
		obj = game.get_monster_at(selected_point)
	end
	
	print(ActorName(obj, "'s"))
	print(ActorName(obj, "break", "breaks"))
	print(YouWord(obj, "your", "their"))
	print(pro(obj, "he"))
	print(pro(obj, "his"))
	print(pro(obj, "him"))
	print(pro(obj, "hers"))
	print(pro(obj, "himself"))

	add_msg(ActorName(obj, "'s"), H_COLOR.PINK)
	add_msg(YouWord(obj, "your", "their"), H_COLOR.PINK)
	add_msg(ActorName(obj, "break", "breaks"), H_COLOR.PINK)
	add_msg(pro(obj, "he"), H_COLOR.PINK)
	add_msg(pro(obj, "his"), H_COLOR.PINK)
	add_msg(pro(obj, "him"), H_COLOR.PINK)
	add_msg(pro(obj, "hers"), H_COLOR.PINK)
	add_msg(pro(obj, "himself"), H_COLOR.PINK)
end

--[[
function t()
	center = player:pos()
	for i=-1,1 do
		for j=-1,1 do
			target = tripoint(center.x + i, center.y + j, center.z)
			m = game.get_monster_at(target)
			if m ~= nil then
				print(m:disp_name())
				mtype = m.type
				print(mtype.hp)
				print(mtype:nname())
				if (mtype:in_species(species_id("FEMALE"))) then
					print("f")
				else
					print("m")
				end

				if (mtype:has_flag("MF_DOGFOOD")) then
					print("doggo")
				end
				if (mtype:has_flag("MF_CATFOOD")) then
					print("catto")
				end
			end
		end
	end
end
]]--

-- pronoun system because english --
function pro(obj, pronoun)
	local objPlayer = obj:is_player()
	local objMale = getGender(obj) --custom function because monsters are also subjected to this
	
    if (pronoun == "he") then
		if (objPlayer) then
			return "you"
		else
			return (objMale and pronoun or "she")
		end
    end
	if (pronoun == "his") then
		if (objPlayer) then
			return "your"
		else
			return (objMale and pronoun or "her")
		end
    end
	if (pronoun == "him") then
		if (objPlayer) then
			return "you"
		else
			return (objMale and pronoun or "her")
		end
    end
	if (pronoun == "hers") then
		if (objPlayer) then
			return "yours"
		else
			return (objMale and "his" or pronoun)
		end
    end
	if (pronoun == "himself") then
		if (objPlayer) then
			return "yourself"
		else
			return (objMale and pronoun or "herself")
		end
    end
	
	return add_msg("*Pronoun error!*", H_COLOR.RED)
end

--(you)
function ActorName(obj, youWord, themWord)
	if (themWord == nil) then --in case second args is skipped to not cause an exception
		themWord = youWord
	end
	
	local out = obj:disp_name() --set actor name
	local word = YouWord(obj, youWord, themWord) --set action word for actor
	
	if (youWord == "'s") then --special case
		if (obj:is_player()) then
			out = "your"
			word = nil
		else
			return out..word
		end
	end
	
	if word then
		return out.." "..word
	else
		return out
	end
end

function YouWord(obj, youWord, themWord)
	return (obj:is_player() and youWord or themWord)
end

--create speech lines during super fun time
--DOESN'T WORK WITH MONSTERS REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
function ActorSay(topic, partner)
	--with this function and say instruction we can use json snippets here, fuck yeah
	if topic == "<fun_stuff_accept>" or topic == "<fun_stuff_shy>" then -- exceptions
		if partner:has_trait(trait_id("VIRGIN")) then --special cases for chaste ones
			if getGender(partner) then --use function just in case if it's gonna be a monster at some point
				topic = "<fun_stuff_partner_mvirgin>"
			else
				topic = "<fun_stuff_partner_fvirgin>"
			end
		elseif player:has_trait(trait_id("VIRGIN")) then
			if player.male then
				topic = "<fun_stuff_player_mvirgin>"
			else
				topic = "<fun_stuff_player_fvirgin>"
			end
		end
	end
	
	--return add_msg(partner:disp_name()..": "..speech_texts[math.random(#speech_texts)])
	--woohoo I can make the character actually say things wowie!
	--log.message(partner:disp_name()..":say, topic:"..topic)
	return partner:say(topic)
end

function getGender(obj) -- return true if male, false if female
	obj = getInfo(obj)
	if (obj:is_monster()) then --special case for monsters because fuck you apparently, they don't have gender attributes
		
		local mtype = obj.type
		DEBUG.add_msg("pro mtype:"..mtype:nname())

		if (mtype:in_species(species_id("FEMALE"))) then
			return false

		elseif (mtype:in_species(species_id("MALE"))) then
			return true
			
		elseif (mtype:in_species(species_id("HERM"))) then
			return false --count herms/futas as females for now
			
		else
			return true --other monsters are males by default
			
		end
	else
		return obj.male
	end
end

function sameSex(first, second, sex)
	if sex == "FEMALE" then
		return ( getGender(first) == false and getGender(second) == false )
	else
		return ( getGender(first) == getGender(second) )
	end
end