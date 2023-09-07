--[[アクティビティ系]]--

--[[*気持ちいいこと*アクティビティ]]--
SEX = {
	sex_fun_bonus,		--行為による意欲ボーナス値
	sex_partner,		--行為の相手。いなければnil。
	pseudo_device,		--行為に使う道具。なければnil。
	is_love_sex			--愛のある行為かどうか
}

SEX.init = function(fun_bonus, ptnr, dvc, love_sex)
	DEBUG.add_msg("SEX.init--")

	--DEBUG.add_msg("fun_bonus:"..fun_bonus)
	--DEBUG.add_msg("ptnr:"..ptnr:disp_name())
	--DEBUG.add_msg("dvc:"..dvc:display_name())

	SEX.sex_fun_bonus = math.round(fun_bonus, 0)
	if not(ptnr == nil) then
		SEX.sex_partner = ptnr
	else
		SEX.sex_partner = nil
	end
	if not(dvc == nil) then
		SEX.pseudo_device = dvc
	else
		SEX.pseudo_device = nil
	end
	if not(love_sex == nil) then
		SEX.is_love_sex = love_sex
	else
		SEX.is_love_sex = false
	end
end

--[[*気持ちいいこと*アクティビティ中処理]]--
SEX.act_sex_do_turn = function(act, p)
	local turn = game.get_calendar_turn():get_turn()

	--SEX_BASE_TURNターンに1度意欲を上昇させ、メッセージを流す
	if (turn % SEX_BASE_TURN == 0) then
		--DEBUG.add_msg("sex_fun_bonus:"..SEX.sex_fun_bonus)
		--DEBUG.add_msg("SEX_FUN_DURATION:"..SEX_FUN_DURATION)
		--DEBUG.add_msg("SEX_FUN_DECAY_START:"..SEX_FUN_DECAY_START)
		game.add_msg(MOVINGDOING_TEXTS[math.random(#MOVINGDOING_TEXTS)])
		player:add_morale(SEX_MORALE_TYPE, SEX.sex_fun_bonus, 0, game.get_time_duration(SEX_FUN_DURATION), game.get_time_duration(SEX_FUN_DECAY_START))

		player:add_effect(efftype_id("movingdoing"), game.get_time_duration(SEX_BASE_TURN))
		if not(SEX.sex_partner == nil) then
			SEX.sex_partner:add_effect(efftype_id("movingdoing"), game.get_time_duration(SEX_BASE_TURN))
			
			if SEX.is_love_sex then
				SEX.sex_partner:add_morale(SEX_MORALE_TYPE, SEX.sex_fun_bonus, 0, game.get_time_duration(SEX_FUN_DURATION), game.get_time_duration(SEX_FUN_DECAY_START))
			end
		end

	end
end

--[[*気持ちいいこと*アクティビティ終了処理]]--
SEX.act_sex_finish = function(act, p)
	--activityにして途中でキャンセルできるようになったのはいいが、そのせいで変数管理がちょー面倒だぜ！
	--TODO:あまりにもスパゲティすぎて自分でも見返すと意味がわからない。整理する

	game.add_msg("*Fun things* are now over.")
	act:set_to_null()

	player:remove_effect(efftype_id("lust"))
	player:remove_effect(efftype_id("movingdoing"))

	DEBUG.add_msg("Reset lust")

	--ここはDEBUG用
	if (SEX.sex_partner == nil) then
		DEBUG.add_msg("SEX.sex_partner is nil.")
	else
		DEBUG.add_msg("SEX.sex_partner:"..SEX.sex_partner:disp_name())
	end
	if (SEX.pseudo_device == nil) then
		DEBUG.add_msg("SEX.pseudo_device is nil.")
	else
		--DEBUG.add_msg("type(SEX.pseudo_device):"..type(SEX.pseudo_device))
		if (SEX.pseudo_device:is_null()) then
			DEBUG.add_msg("ERROR:SEX.pseudo_device *IS* null.")
		else
			DEBUG.add_msg("SEX.pseudo_device:"..SEX.pseudo_device:display_name())
		end
	end

	--行為の*完了時点で*プレイヤーのインベントリに存在する実際のdeviceのitemオブジェクトをここで取得する。
	local device
	if not(SEX.pseudo_device == nil) then
		device = get_item_by_id(player, SEX.pseudo_device:typeId())
		DEBUG.add_msg("device:"..device:display_name())
	end

	if not(SEX.sex_partner == nil) then
		--DEBUG.add_msg("SEX.sex_partner:"..SEX.sex_partner:disp_name())
		SEX.sex_partner:remove_effect(efftype_id("lust"))
		SEX.sex_partner:remove_effect(efftype_id("movingdoing"))

		--パートナーがいれば印象度を変動させる。
		local opinion = SEX.sex_partner.op_of_u
		DEBUG.add_msg("opinion:"..opinion.value)

		--変動値は超適当
		if (SEX.is_love_sex) then
			DEBUG.add_msg("is love sex.")
			opinion.trust = opinion.trust + 2
			opinion.value = opinion.value + 2
			opinion.fear = opinion.fear - 1
			opinion.anger = opinion.anger - 1
		else
			DEBUG.add_msg("is NOT love sex.")
			opinion.fear = opinion.fear + 5
			opinion.anger = opinion.anger + 1
			opinion.trust = opinion.trust - 2
			opinion.owed = opinion.owed - 1
		end
		SEX.sex_partner.op_of_u = opinion
		
		--after sex pillow talk
		if SEX.is_love_sex then
			if (SEX.sex_partner:is_following() or SEX.sex_partner:is_friend()) then -- flavor
				ActorSay("<fun_stuff_love>", SEX.sex_partner)
			else
				ActorSay("<fun_stuff_bye>", SEX.sex_partner)
			end
		else
			ActorSay("<fun_stuff_bye_fear>", SEX.sex_partner) --currently only case of non-love sex is fear
		end
	end

	DEBUG.add_msg("device check ->")
	--危ないやつを使ってた場合は確率で壊れる。
	if not(device == nil) then
		DEBUG.add_msg("device:typeId():"..device:typeId())
		if (device:typeId() == "condom_danger") then
			DEBUG.add_msg("wooga booga, it's danger! break check!")
			if(math.random(100) <= D_GOM_BREAK_CHANCE) then
				add_msg("The condom has broke!", H_COLOR.RED)
				player:i_rem(device)
				device = nil
			end
		end
	end

	DEBUG.add_msg("production check ->")
	--生産物の処理
	local liquid_of_u = item("h_semen", 1)
	liquid_of_u:set_relative_rot(0)		--そのままだとbirthdayがゲーム開始時のままなので、ここで新鮮にする

	if not(device == nil) then
		DEBUG.add_msg("device is "..device:display_name())

		if (player:has_item(device)) then
			DEBUG.add_msg("player have device.")

			--使用した道具を取り除き、(使用済み)のアイテムをプレイヤーの所持品に追加する。
			player:i_rem(device)
			local container = item("used_condom", 1)
			
			if (SEX.sex_partner == nil) or sameSex(player, SEX.sex_partner, "FEMALE")  then --in case both are female or player is masturbating
				game.popup("You discard the used condom.")
			else
				--modded finish message
				local finisher = ((player.male) and player or SEX.sex_partner)
				
				game.popup(ActorName(finisher, "finish", "finishes").." inside the condom!")
			end

			--(使用済み)のアイテムに液体を追加する。
			container:fill_with(liquid_of_u)
			player:i_add(container)
		end
	else

		map:add_item(player:pos(), liquid_of_u)

		if not(SEX.sex_partner == nil) then
			--プレイヤーとパートナー、両方に妊娠チェック
			SEX.check_preg(player, SEX.sex_partner)
			SEX.check_preg(SEX.sex_partner, player)
		end
	end

	DEBUG.add_msg("--end act_sex_finish()--")

end

--[[Modded: premature finish when the action was interrupted somehow, remove the effect, but no ejaculation/opinion changes/orgasms, etc]]--
--TODO: perhaps add emotional frustration or something? but that could be annoying in case of emergency
--the condom stays intact after this, is that alright? it would be annoying to waste it though
SEX.act_sex_finish_premature = function()
	game.add_msg("*Fun things* were ended prematurely!")

	--player:remove_effect(efftype_id("lust"))
	player:remove_effect(efftype_id("movingdoing"))

	DEBUG.add_msg("Remove effect")
	
	if not(SEX.sex_partner == nil) then
		--DEBUG.add_msg("SEX.sex_partner:"..SEX.sex_partner:disp_name())
		--SEX.sex_partner:remove_effect(efftype_id("lust"))
		SEX.sex_partner:remove_effect(efftype_id("movingdoing"))
		SEX.sex_partner:set_moves(0) --unstuck the partner

		--after sex pillow talk
		if SEX.is_love_sex then
			ActorSay("<fun_stuff_interrupt>", SEX.sex_partner)
		else
			ActorSay("<fun_stuff_bye_fear>", SEX.sex_partner) --currently only case of non-love sex is fear
		end
	end
	
	DEBUG.add_msg("--end act_sex_finish_premature()--")
end

--[[対象の妊娠判定を行う。]]--
SEX.check_preg = function(mother, father)
	DEBUG.add_msg("--check_preg--")

	--motherが母親、fatherが父親の想定。それ以外なら処理を抜ける
	if (mother == nil or father == nil) then
		return
	end

	DEBUG.add_msg("mother:"..mother:disp_name())
	DEBUG.add_msg("father:"..father:disp_name())

	if (mother.male) then
		return
	end
	if not(father.male) then
		return
	end
	
	--modded finish message
	game.popup(ActorName(father, "finish", "finishes").." inside of "..mother:disp_name().."!")

	mother:set_value(CREAMPIE_SEED_TYPE, "HUMAN")

	--判定に成功すれば孕む。失敗しても5日くらい溜まったままにする。
	if (preg_roll(mother)) then
		DEBUG.add_msg("impregnated.")
		mother:add_effect(efftype_id("impregnated"), game.get_time_duration(1), "num_bp", true)
	else
		DEBUG.add_msg("not impregnate.")
		mother:add_effect(efftype_id("creampie"), game.get_time_duration(72000))
	end

end

