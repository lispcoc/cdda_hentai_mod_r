--[[いろいろ]]--

DEBUG = {
	--trueにセットするとデバッグメッセージを表示する
	enabled = false
}

--[[デバッグ用ファンクション]]--
DEBUG.hello_world = function()
	game.add_msg("Hello World!")
end

DEBUG.add_msg = function(message)
	if (DEBUG.enabled) then
		game.add_msg(message)
	end
end

DEBUG.chk_calendar = function()

	local cldr = game.get_calendar_turn()

	DEBUG.add_msg("year_length:"..cldr:year_length():get_turns())		--ターン数基準
	DEBUG.add_msg("season_length:"..cldr:season_length():get_turns())	--ターン数基準
	DEBUG.add_msg("season_ratio:"..cldr:season_ratio())					--現実世界の1季節の日数(91日)に対するゲーム内の季節の長さの比率。たとえばゲーム内1季節を14日に設定した場合、14 / 91 = 約0.1538になる。
	DEBUG.add_msg("season_from_default_ratio:"..cldr:season_from_default_ratio())	--ゲーム内のデフォルトの1季節の日数(14日)に対する現在の1季節日数の比率。たとえばゲーム内1季節を28日に設定した場合 28 / 14 = 2になる。
	DEBUG.add_msg("day_of_year:"..cldr:day_of_year())
	DEBUG.add_msg("get_turn:"..cldr:get_turn())
	DEBUG.add_msg("sunlight:"..cldr:sunlight())
	DEBUG.add_msg("years:"..cldr:years())

end



--[[メッセージを指定した色で表示するだけ]]--
function add_msg(message, h_color)

	if(h_color == nil) then
		game.add_msg(message)
	else
		game.add_msg("<color_"..h_color..">"..message.."</color>")
	end

end

--[[周囲に存在するcritterのリストを取得する。]]--
function get_critters()

	local critter_list = {}

	local ids
	ids = g:num_creatures()		--reality bubble(時間が進む範囲)に存在するcreatureの最大idを取得する。（ただし既に死んだcreatureのゴミ情報を含む場合もあるらしい）

	local chara
	for i = 1, ids, 1 do
		chara = g:critter_by_id(i)	--idをキーに生きているcritterを取得する。...ただし今の所取得できるのはplayerとnpcのみらしい

		if (chara == nil) then
			DEBUG.add_msg("id"..i..":なし")
		else
			DEBUG.add_msg("id"..i..":"..chara:disp_name())
			table.insert(critter_list, chara)
		end

	end

	return critter_list
end

--[[周囲に存在するplayer（NPC含む）のリストを取得する。]]--
function get_players()

	local critter_list = {}
	local player_list = {}

	--周辺に存在するcritterをすべて取得する
	critter_list = get_critters()

	for key, value in pairs(critter_list) do
		--DEBUG.add_msg("key:"..key)
		--DEBUG.add_msg("value:"..value:disp_name())

		--対象がplayerおよびnpcであればリストに追加する		取得されるのはplayerとNPCだけなんだけど、いつ仕様変更が入るのかわからないので念のため
		if (value:is_player() or value:is_npc()) then
			--HACK:ここでplayerクラスに変換しておく。
			--table.insert(player_list, g:player_at(value:pos()))
			if value:is_player() then
				table.insert(player_list, player)
			else
				table.insert(player_list, game.get_npc_at(value:pos()))
			end
		end

	end

	return critter_list
end

--[[Characterが着用しているアイテムのリストを取得する。body_partが指定されている場合はその部分を覆うもののみ対象。]]--
function get_wears(chara, body_part)
	local item_list = {}

	local i = -2		--i_at(int)で-2以下を指定するとCharacterが着用しているitemを取得できる。ちなみに-1は装備武器、0以上が所持品。
	local item = chara:i_at(i)

	--着用itemを順次取得してリストに追加する。
	--NOTE:i_at(int)で存在しない番号を指定すると、nilではなく"なし"アイテムを返すため、本当にそのアイテムを着用しているかどうかで判断する。
	while (chara:is_worn(item)) do

		if (body_part == nil or item:covers(body_part)) then
			--DEBUG.add_msg(item:typeId())
			--DEBUG.add_msg(item:display_name())
			table.insert(item_list, item)
		end

		i = i - 1
		item = chara:i_at(i)

	end

	return item_list
end

--[[Characterが着用しているアイテムの中からランダムに1つ取得する。body_partが指定されている場合はその部分を覆うもののみ対象。]]--
function get_random_wear(chara, body_part)
	local item_list = get_wears(chara, body_part)
	if item_list then
		return item_list[math.random(#item_list)]
	else
		return nil
	end
end

--Check if target is naked, from dda lua traits
function is_naked(chara)
	for _,body_part in pairs(enums.body_part) do

	   if (chara:wearing_something_on(body_part) == true) then

		 return false

	   end

	end
	
	return true
end

--[[Characterが所持している(インベントリ内の)アイテムのリストを取得する。]]--
function get_items(chara)
	local item_list = {}

	local i = 0		--i_at(int)で0以上を指定するとCharacterが所持しているitemを取得できる。
	local item = chara:i_at(i)

	--所持itemを順次取得してリストに追加する。
	--NOTE:i_at(int)で存在しない番号を指定すると、nilではなく"なし"アイテムを返すため、本当にそのアイテムを所持しているかどうかで判断する。
	while (chara:has_item(item)) do

		--DEBUG.add_msg(item:typeId())
		--DEBUG.add_msg(item:display_name())
		--table.insert(item_list, item)
		--typeIdをキー、itemをvalueにする
		item_list[item:typeId()] = item

		i = i + 1
		item = chara:i_at(i)

	end

	return item_list
end

--[[アイテムのidをキーにCharacterが所持している(インベントリ内の)アイテムオブジェクトを取得する。]]--
function get_item_by_id(chara, str_id)
	local dummy_item = item("null", 1)

	local item_list = get_items(chara)

	if not(item_list[str_id] == nil) then
		return item_list[str_id]
	else
		return dummy_item
	end

end

--[[中心点の周囲8マスの中で誰もいないマスのリストを取得する]]--
function get_around_empty_locs(center)
	--DDA同梱のサンプルmodを流用。
	local locs = {}

	for delta_x = -1, 1 do
		for delta_y = -1, 1 do
			local point = center
			point.x = point.x + delta_x
			point.y = point.y + delta_y
			if (g:is_empty(point)) then
				--DEBUG.add_msg("x: "..point.x)
				--DEBUG.add_msg("y: "..point.y)
				table.insert(locs, point)
			end
		end
	end

	return locs

end

--[[指定した範囲内のtripointリストを取得する。]]--
function get_around_locs(center, min_radius, max_radius)

	local locs = {}

	--ひどいネストだ...
	for ix = center.x + (-1 * max_radius), center.x + max_radius do
		if (ix <= -1 * min_radius or ix >= min_radius) then
			for iy = center.y + (-1 * max_radius), center.y + max_radius do
				if (iy <= -1 * min_radius or iy >= min_radius) then
					local point = tripoint(ix, iy, center.z)
					table.insert(locs, point)
				end
			end
		end
	end

	return locs
end



function getInfo(obj)
	if obj == nil then
		log.message("obj is nil!")
	end
	
	local obj = g:critter_at(obj:pos())
	if (obj:is_monster()) then
		obj = game.get_monster_at(obj:pos())
	end
	
	return obj
end

--classesに独自function実装できないかなーと弄ってうまくいかなかった残骸
--MyPlayer = {}
--MyPlayer.new = function(creature)
--	local this = debug.setmetatable(creature, debug.getmetatable(player))
--
--	this.sayHello = function(self)
--		DEBUG.add_msg("Hello, I'm player!")
--	end
--
--	return this
--
--end
--
--function iuse_hoge(item, active)
--
--	DEBUG.add_msg("hoge")
--
--	local center = player:pos()
--	local selected_x, selected_y = game.choose_adjacent("誰に対して使用しますか？", center.x, center.y)
--	local selected_point = tripoint(selected_x, selected_y, center.z)
--
--	local someone = g:critter_at(selected_point)
--
--	DEBUG.add_msg(someone:disp_name())
--
--	local hoge = MyPlayer.new(someone)
--
--	hoge:sayHello()
--
--end
--
--
--function iuse_hoge(item, active)
--
--	DEBUG.add_msg("hoge")
--
----	local center = player:pos()
----	local selected_x, selected_y = game.choose_adjacent("誰に対して使用しますか？", center.x, center.y)
----	local selected_point = tripoint(selected_x, selected_y, center.z)
----
----	local someone = g:critter_at(selected_point)
----
----	DEBUG.add_msg(someone:disp_name())
----
----	someone.hello()
--
--end
--
--function fuga()
--
--	local center = player:pos()
--	local selected_x, selected_y = game.choose_adjacent("誰に対して使用しますか？", center.x, center.y)
--	local selected_point = tripoint(selected_x, selected_y, center.z)
--
--	local someone = g:critter_at(selected_point)
--
--	DEBUG.add_msg(someone:disp_name())
--
--	someone.hello(someone)
--end
--
--classes.Creature.hello = function(self)
--	DEBUG.add_msg("hello, I'm Creature!")
--	DEBUG.add_msg(Creature.disp_name())
--	DEBUG.add_msg(self.disp_name())
--end
--
--classes.Character.hello = function(self)
--	DEBUG.add_msg("hello, I'm Character!")
--	DEBUG.add_msg(Character.disp_name())
--	DEBUG.add_msg(self.disp_name())
--end
--
--classes.monster.hello = function(self)
--	DEBUG.add_msg("hello, I'm monster!")
--	DEBUG.add_msg(monster.disp_name())
--	DEBUG.add_msg(self.disp_name())
--end
--
--classes.player.hello = function(self)
--	DEBUG.add_msg("hello, I'm player!")
--	DEBUG.add_msg(player.disp_name())
--	DEBUG.add_msg(self.disp_name())
--end

