
local MOD = {
	id = "Hentai_mod"
}
mods[MOD.id] = MOD

--[[新規プレイスタート時]]--
function MOD.on_new_player_created()

	DEBUG.add_msg("on_new_player_created-->")

	flagitem = get_item_by_id(player, "fake_prof_pet")

	--profession"一人と一匹"開始時（というか判定用ダミーアイテムを所持していた場合）の処理。
	if (player:has_item(flagitem)) then
		DEBUG.add_msg("man_with_a_pet-->TRUE")
		--DEBUG.add_msg("flagitem:"..flagitem:display_name())
		player:i_rem(flagitem)		--ダミーアイテムはもちろん没収。

		--ペット選択メニューを表示。
		local menu = game.create_uimenu()
		local choice = -1
		menu.title = PROF_PET_LIST.TITLE

		for key, value in pairs(PROF_PET_LIST.LIST_ITEM) do
			menu:addentry(value.ENTRY)
		end

		menu:query(true)
		choice = menu.selected
		DEBUG.add_msg("choice:"..choice)

		--選択したリストに対応するペットとボーナスアイテムをそれぞれ配布。
		local locate_list = get_around_empty_locs(player:pos())
		if (#locate_list == 0) then
			--万が一ペットがスポーンする場所が無い場合はプレイヤーの位置に配置する。そんな事そうそう無いと思うが...
			table.insert(locate_list, player:pos())
		end

		DEBUG.add_msg("pet_id:"..PROF_PET_LIST.LIST_ITEM[choice+1].PET_ID)
		local pet = game.create_monster(mtype_id(PROF_PET_LIST.LIST_ITEM[choice+1].PET_ID), locate_list[math.random(#locate_list)])
		--local pet = game.create_monster(mtype_id("mon_dog"), locate_list[math.random(#locate_list)])
		pet.friendly = -1
		pet:add_effect(efftype_id("pet"), game.get_time_duration(1), "num_bp", true)

		--ペットがサキュバスの場合は特殊攻撃"WIFE_U"を無効化しておく。処理が重くなるし、何よりペットが敵対NPCに寝取られるのは嫌でしょうから。（ええと、自分から仕掛けてるから寝取る？寝取りられる？）
		if (pet.type.id == mtype_id("mon_succubi")) then
			--ちなみに特殊攻撃を持っていないmonsterに対してdisable_special()を行うとランタイムエラーを起こしてCTDする。ゲームは死ぬ。
			pet:disable_special("WIFE_U")
		end

		DEBUG.add_msg("pet:"..pet:disp_name())

		for key, value in pairs(PROF_PET_LIST.LIST_ITEM[choice+1].BONUS_ITEM) do
			player:i_add(item(value, 1))
		end

		player:mod_moves(-200)

	end

	DEBUG.add_msg("-->end on_new_player_created")

end

--[[ゲーム内で日付が変わった際(真夜中！)のコールバック]]--
function MOD.on_day_passed()

	--周辺に存在するplayerをすべて取得する
	local player_list = get_players()

	for key, value in pairs(player_list) do
		preg_process(value)
	end

end

--[[ゲーム内で1時間経過した際のコールバック]]--
function MOD.on_hour_passed()

	--周辺に存在するplayerをすべて取得する
	local player_list = get_players()

	for key, value in pairs(player_list) do
		birth_process(value)

		--HACK:バグで"gotwifed"が残ったままになってしまった場合の対処としてここで消しておく。
		value:remove_effect(efftype_id("gotwifed"))
	end

end

--[[ゲーム内で1ターン経過した際のコールバック]]--
function MOD.on_turn_passed()
	if player:has_activity(activity_id("ACT_SEX")) then
		if player.activity.moves_left < 1000 then
			SEX.act_sex_finish(player.activity, player)
			player.activity:set_to_null()
		else
			SEX.act_sex_do_turn(player.activity, player)
		end
	end
	
	--in case the activity was ended prematurely
	--isn't it a bit heavy checking this every turn?
	if player:has_effect(efftype_id("movingdoing")) then
		if not(player:has_activity(activity_id("ACT_SEX"))) then
			DEBUG.add_msg("Fun effect is found but no activity! Premature fun end!")
			SEX.act_sex_finish_premature()
		end
	end
end

--[[ミッションをクリアした際のコールバック]]--
MOD.on_player_mission_finished = function(player_id, mission_id)
	DEBUG.add_msg("mission_finished-->")
	DEBUG.add_msg("mission_id:"..mission_id)
	DEBUG.add_msg("player_id:"..player_id)

end


--[[妊娠関連の処理を行う]]--
--TODO:reality bubble内にいないNPCに対して経過日数の処理が行えない。最後に計測した日を持っておいて、次回の計測時に差分をまとめて計上する？
function preg_process(mother)
	DEBUG.add_msg("---preg_process---")
	DEBUG.add_msg("mother:"..mother:get_name())

	--カレンダーを基準に経過日数を求める
	local cldr = game.get_calendar_turn()
	local elapse_day = 1 / cldr:season_ratio()				--ゲーム内1季節の長さの比率で割る事で、現実時間単位での経過日数を求めることができる

	--季節変動が無効なら経過日数はリアル日数基準にしておく（現実で季節が変わらないなんてありえないけどね！）
	if (cldr:eternal_season()) then
		elapse_day = 1
	end

	DEBUG.add_msg("elapse_day:"..elapse_day)

	--TODO:父親の種類や母親の特質などによって成長速度を変化できるようにする
	local preg_speed_ratio = DEFAULT_PREG_SPEED_RATIO
	DEBUG.add_msg("preg_speed_ratio:"..preg_speed_ratio)

	--pregnantcy状態の処理
	if (mother:has_effect(efftype_id("pregnantcy"))) then
		DEBUG.add_msg("Process pregnantcy ->")

		mother:add_effect(efftype_id("pregnantcy"), game.get_time_duration(elapse_day), "num_bp", true)

	--impregnated状態の処理
	elseif (mother:has_effect(efftype_id("impregnated"))) then
		DEBUG.add_msg("Process impregnated ->")

		local timecount
		timecount = mother:get_effect_dur(efftype_id("impregnated"))
		--DEBUG.add_msg("timecount:"..timecount:get_turns())
		--NOTE:timecount:get_turns()はLUA拡張版DDA独自の記述であって、本家DDAには実装されていない...

		--NOTE:が、timecountは__eqエントリーを持っているのでオブジェクト同士での比較が可能。
		--if (timecount:get_turns() < 70) then
		if not(timecount == game.get_time_duration(70)) then
			mother:add_effect(efftype_id("impregnated"), game.get_time_duration(elapse_day), "num_bp", true)

		else
			--impregnated状態が最大値に届いているならpregnantcy状態に移行する
			game.popup("Something feels different about "..mother:get_name().."...")
			game.popup("It seems that "..mother:get_name().." got pregnant!")

			mother:remove_effect(efftype_id("impregnated"))
			mother:add_effect(efftype_id("pregnantcy"), game.get_time_duration(elapse_day), "num_bp", true)
		end

	--creampie状態なら妊娠チェック。
	elseif (mother:has_effect(efftype_id("creampie"))) then
		DEBUG.add_msg("Process creampie ->")

		--判定に成功すれば孕む。
		if (math.random(100) <= preg_roll(mother)) then
			DEBUG.add_msg("impregnated.")
			mother:remove_effect(efftype_id("creampie"))
			mother:add_effect(efftype_id("impregnated"), game.get_time_duration(1), "num_bp", true)
		end

	else
		DEBUG.add_msg("Process other ->")
		--妊娠してない場合
		--TODO:ここに発情や抱卵の処理を追加する

		--calendarから現在の季節を取得する方法が無いので（見逃してるだけかもしれないけど）、ゲーム内1季節の長さをデフォルトの季節の長さとの比率で割ることで相対的に求める。
		local day_by_default = cldr:day_of_year() / cldr:season_from_default_ratio()
		DEBUG.add_msg("day_by_default:"..day_by_default)

		--狼は冬の終わりごろから2～3週間にかけて発情期となる。（リアル世界の話です）
		if (mother:has_trait(trait_id("ESTRUS_LUPINE"))) then
			DEBUG.add_msg("Lupine estrus ->")

			--TODO:判定がガバい。ゲーム内日数で判断したい
			if (day_by_default >= 0 and day_by_default <= 11) then
				add_msg(ActorName(mother, "are", "is").." having a breeding period and "..YouWord(mother, "are", "is").." now In Heat!", H_COLOR.PINK)
				mother:add_effect(efftype_id("estrus"), game.get_time_duration(14400))
			end
		end

		--猫は春先から秋の終わりにかけ、2週間おきに4～7日間の発情期となる。（リアル世界の話です）
		if (mother:has_trait(trait_id("ESTRUS_FELINE"))) then
			DEBUG.add_msg("Feline estrus ->")

			--TODO:判定がガバい。ゲーム内日数で判断したい
			if ((day_by_default >= 3 and day_by_default <= 7) or (day_by_default >= 17 and day_by_default <= 21) or (day_by_default >= 31 and day_by_default <= 35)) then
				add_msg(ActorName(mother, "are", "is").." having a breeding period and "..YouWord(mother, "are", "is").." now In Heat!", H_COLOR.PINK)
				mother:add_effect(efftype_id("estrus"), game.get_time_duration(14400))
			end
		end

	end

end

--[[出産処理を行う]]--
function birth_process(mother)
	DEBUG.add_msg("---birth_process---")


	--pregnantcy状態の処理
	if (mother:has_effect(efftype_id("pregnantcy"))) then
		local timecount

		timecount = mother:get_effect_dur(efftype_id("pregnantcy"))
		--DEBUG.add_msg("timecount:"..timecount:get_turns())

		--pregnantcy状態が最大値に届いているなら確率で生まれる。
		--if (timecount:get_turns() >= 210) then
		if (timecount == game.get_time_duration(210)) then

			--一日に3回程度、つまり3/24の確率で出産チェックを通過する。確率は適当。
			if (math.random(100) > 12) then
				mother:mod_pain(25)
				add_msg(ActorName(mother, "have", "has").." went into labor!", H_COLOR.RED)
				return
			end

			--周囲にスポーンする場所がなければ処理を抜ける。
			local locate_list = get_around_empty_locs(mother:pos())
			if (#locate_list == 0) then
				return
			end

			local locate = locate_list[math.random(#locate_list)]

			game.popup(mother:get_name().." has given birth to a baby!")
			mother:remove_effect(efftype_id("pregnantcy"))
			
			--childbirth count, method from Kawaii maid mod
			local pregcount = tonumber(mother:get_value("hentai_pregcount"))
			
			if pregcount == nil then
				pregcount = 0
			end
			
			pregcount = pregcount + 1
			
			mother:set_value("hentai_pregcount", tostring(pregcount))
			--

			--TODO: define child's genetics, set ethnicity and appearance depending on child's parents, etc
			local child_id = map:place_npc(locate.x, locate.y, npc_template_id("darkdays_children"))
			--game.create_monster(mtype_id("debug_mon"), locate_list[math.random(#locate_list)])
			DEBUG.add_msg("child_id:"..child_id)

			game.popup("Then something strange has occurred and the baby grew up in an instant!")
			--どうすりゃいいのさ、その...ゲームシステムというか仕様を...
			--リアルタイム換算で成長させようとすると数年単位かかって超めんどくさいし、monster化するとlua制御が無理だし、かといって時間経過で変化するアイテムで代用するのはちょっと...

			--TODO:本当はこの場でNPCの名前を変更したりしたいんだけど無理なので名前の巻物を与えてお茶をにごす
			local scroll = item("scroll_of_naming", 1)
			map:add_item(player:pos(), scroll)
			add_msg("Something has rolled at your feet.", H_COLOR.GREEN)




			----TODO:生成したNPCに対してこのタイミングで取得・操作する方法を考える。
			----NOTE:map:place_npc()で生成したNPCは一度overmapのbufferに追加されてから次ターンにキャラとして生成されるため、単純にplace_npc()で指定したlocateを元にこのタイミングで取得しようとしてもまだ"生まれていない"。先行して発番されたidを元にNPCを取得しようとしても無理。
			--local assign_id = g:assign_npc_id()
			--DEBUG.add_msg("assign_id:"..assign_id)
            --
			--local childname = game.string_input_popup("子供の名前を入力してください。", 0, "")
			--if (childname == "") then
			--	childname = DEFAULT_NPC_NAME
			--end
			--DEBUG.add_msg("childname:"..childname)
            --
			----local child = g:npc_at(locate)
			--local temp = g:critter_by_id(child_id)
			--DEBUG.add_msg("temp:"..temp:disp_name())
            --
			--local child = g:npc_at(temp:pos())
			--DEBUG.add_msg("child:"..child:disp_name())
            --
			--child.name = childname
			--DEBUG.add_msg("child:"..child:disp_name())
            --
			----男で"貧乳"や"巨乳"を持ってたら取り除く。
			--if (child.male) then
			--	if (child:has_trait(trait_id("SMALL_BREAST"))) then
			--		child:unset_mutation(trait_id("SMALL_BREAST"))
			--	end
			--	if (child:has_trait(trait_id("BIG_BREAST"))) then
			--		child:unset_mutation(trait_id("BIG_BREAST"))
			--	end
			--end

			mother:mod_moves(-100)

		end

	end

end