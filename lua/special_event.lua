--[[山羊頭の悪魔のイベント]]--
function event_goathead_demon(monster)
	local someone = monster:attack_target()

	--相手がいなければ何もしない。
	if (someone == nil) then
		return
	end
	--姿がプレイヤーに見えていなければ何もしない。相手に姿を見せてから名乗りをあげないとただの変な奴だし。
	if not(player:sees(monster:pos())) then
		return
	end

	--イベント発生用の特殊攻撃を無効化する。
	monster:disable_special("EVENT_GOATHEAD_DEMON")

	--TALK
	if (player:get_value(EVENT_GOATHEAD_DEMON)  == "met") then
		--会ったフラグがある場合のセリフ。激おこ。
		--the last part of the sentence would be something like: "your death alone will not satisfy me, I will have you burned/tortured in the deepest parts of hell forever!"
		--but I used the more concise variant, which is also a reference
		game.popup("\"...The despicable one! How long do you plan to stand in our way before you're satisfied?!\r\nMy patience with you is wearing thin... I will never forgive you!\r\nDeath will not be your end, your soul will burn in hell forever!\"")
	else
		--会ったフラグが無い場合のセリフ。
		game.popup("\"Would you look at that... I knew there was something going on, but to think it's just some irrelevant human snooping around.\r\nA would-be hero or just someone led by the curiosity? In either case, it doesn't change the fact of your foolishness.\"")
		game.popup("\"This Sabbath is an important event for us, Demons, as we take over the earth.\r\nI don't know who you are nor I care. But I can't have you disturb us.\r\nYou will meet your end here by my hand.\"")

		if (player.male) then
			game.popup("\"But don't worry. After I take your soul, I will reincarnate you as my Demon underling!\r\nHaaa-ha-ha-ha!\"")
		else
			game.popup("\"But now that I take a closer look, you appear to be a fine, able-bodied woman.\r\nVery well, once I take your soul, I will offer you as a sacrifice for my Sabbath as much as I please!\r\nHaaa-ha-ha-ha!\"")
		end

		--会ったフラグを立てる。
		player:set_value(EVENT_GOATHEAD_DEMON, "met")
	end

	--周囲にある魔法陣を起動する。
	local locs = get_around_locs(monster:pos(), 0, 10)
	for key, value in pairs(locs) do
		--DEBUG.add_msg("point.x:"..value.x)
		--DEBUG.add_msg("point.y:"..value.y)

		magic_circle_fire(value, 3, 30)
		magic_circle_summon(value, MON_ARCH_CUBI_LIST)
	end

	monster:mod_moves(-100)

end

--[[NPC"demonbeing_schoolgirl"を呼び出すイベント]]--
--[[
	NOTE:NPCを配置する場合、そのNPCにユニーク名称を付けなければ性別を固定することができない。
	しかしそうすると同一人物が複数存在する事になってしまう...そのため、\"その人物に会った事があるかあるかどうか\"をフラグとして管理し、
	会っていない場合はNPCを生成、既に会っている場合はモンスターを生成する仕様にする。
]]--
function event_demonbeing_schoolgirl(monster)

	--イベント発火地点を保持しておく。(ダミーモンスターを消すとnil参照で落ちるため)
	local tripoint = monster:pos()

	--なんかよくわからないけど、プレイヤーとの距離が離れすぎているとアボートするっぽい？ので、プレイヤーが近くにいない場合は処理を抜ける。
	local dist = game.distance(tripoint.x, tripoint.y, player:posx(), player:posy())		--line.cppを参照。
	if (dist > 10) then
		--DEBUG.add_msg("Out of range.")
		return
	end

	--ダミーモンスターは消す。
	g:remove_zombie(monster)

	if (player:get_value(EVENT_DEMONBEING_SCHOOLGIRL)  == "met") then
		--既に会ってる場合はモンスターを生成。
		local mon = game.create_monster(mtype_id("mon_corrupted_schoolgirl"), tripoint)

	else
		--まだ会ってない場合はNPCを生成。
		local npc_id = map:place_npc(tripoint.x, tripoint.y, npc_template_id("demonbeing_schoolgirl"))

		--会ったフラグを立てる。
		player:set_value(EVENT_DEMONBEING_SCHOOLGIRL, "met")
	end

end
