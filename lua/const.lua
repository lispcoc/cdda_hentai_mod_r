--[[定数]]--


--[[文字のハイライト色パターン]]--
H_COLOR = {
	BLACK		= "black",
	WHITE		= "white",
	LIGHT_GRAY	= "light_gray",
	DARK_GRAY	= "dark_gray",
	RED			= "red",
	GREEN		= "green",
	BLUE		= "blue",
	CYAN		= "cyan",
	MAGENTA		= "magenta",
	BROWN		= "brown",
	LIGHT_RED	= "light_red",
	LIGHT_GREEN	= "light_green",
	LIGHT_BLUE	= "light_blue",
	LIGHT_CYAN	= "light_cyan",
	PINK		= "pink",
	YELLOW		= "yellow"
}

--[[*気持ちいいこと*中に表示されるテキスト]]--
MOVINGDOING_TEXTS = {
	"*Lewd Sounds*",
	"\"Haa, haa♥\"",
	"*Snu-Snu in progress*",
	"\"La di da♪\"",
	"\"Ufufu♪\"",
	"\"WooHoo♪\""
}
--todo: perhaps move these dialog lines out of const into json so we could randomize words and add gender-specific and etc checks?
--another problem is that you can still hear this even when deaf
--[[レイダー的な敵キャラ会話のテキスト]]--
VULGAR_SPEECH_TEXTS = {
	--ターゲットを発見した時
	TARGET_ACQUIRE = {
		--[[露骨なパロディネタはいちおう自粛。
			"\"地獄だ、やあ！\"",
		]]--
		"\"Bah!\"",
		"\"Aa-haaa!\"",
		"\"Gotcha loser!\"",
		"\"What the--?!\"",
		"\"Hey, it's the enemy!\"",
		"\"We have contact!\"",
		"\"Hostiles!\"",
		"\"Ha! I see ya!\"",
		"\"Hyahaaa!\"",
		"\"I'm gonna twist your head off and make it my toy!\"",
		"\"Hyahaaa! Fresh toy!\"",
		"\"Hyahaaa! Fresh meat!\"",
		"\"We're gonna feast on human flesh today!\"",
		"\"It's raaaape tiiiiiime!\"",
		"(Insane laughter)",
		"\"HELL YEAH!\"",
		"\"Give 'em hell!\""
		--"\"地獄だ、イェア！\""
	},
	--ターゲットと交戦中
	TARGET_ENGAGE = {
		--[[露骨なパロディネタはいちおう自粛。
			"\"殺しは初めてじゃないんだよ、新米！\"",
			"\"何百回とやってきた！そうすれば変わるだろう！？\"",
			"\"自分を制して、悪に徹しろ！\"",
		]]--
		"\"Hyahaaa!\"",
		"\"Scared, huh?!\"",
		"\"Come at me, bitch!\"",
		"\"Blood! Blood! Blooooooooood!!!\"",
		"\"Bleed for meeee!\"",
		"\"You're nothiiiiiiiiiiiiiiiiiiiin'!\"",
		"\"You got nothin' on me!\"",
		"\"Rape and then kill? Or kill and then rape?  ...Both sound reaaaaaaaally nice!\"",
		"\"I'll rape you, then kill you, and then rape you again!\"",
		"\"Murder death kill!\"",
		"\"I don't mind helpin' you out, you know?  ...After I'm done toyin' with ya, that is!\"",
		"(Insane laughter)",
		"(Roars)",
		"(Howls)",
		"(Growls)",
		"\"Dieeeeeeeeeeeee!\"",
		"\"Imma fuck you up!\"",
		"\"I just want to play! You don't mind it, right?!\"",
		"\"You little shit...\"",
		"\"How are you still not dead?!\"",
		"\"Why can't you just die?!\"",
		"\"This ain't my first time killin', ya rookie!\"",
		"\"If I can't live as a Human, then Demon life it is!\"",
		"\"When you get to hell, tell 'em I sent ya!\"",
		"\"When I kill you, I'll rape your corpse! Don't worry, I'll be gentle!\"",
		"\"You're gonna be really fuckin' sorry!\""
	},
	--ターゲットを見失った時
	TARGET_LOST = {
		"(Clicks tongue)",
		"\"That fellow sure runs fast...\"",
		"\"That moron is hella fast, damn!\"",
		"\"Come out, come out, wherever you are! I'm gonna end ya quick!\"",
		"\"Stop hidin' and come out already!\"",
		"\"Careful, that fellow is still hidin' nearby...\"",
		"\"Stop runnin'!\"",
		"\"Damn, where the fuck did he go?!\"",
		"\"I see ya! No I don't... Yes I do! No I don't... Fuck!\"",
		"\"Chicken, chicken, chicken... Chicken!\""
	}
}

--[[profession"一人と一匹"スタート時のペット選択リストまとめ]]--
PROF_PET_LIST = {
	TITLE = "Your pet is...",
	LIST_ITEM = {
		{
			ENTRY = "A dog!",
			PET_ID = "mon_dog",
			BONUS_ITEM = {"pet_carrier", "dog_whistle"}
		},
		{
			ENTRY = "A cat!",
			PET_ID = "mon_cat",
			BONUS_ITEM = {"pet_carrier", "can_tuna"}
		},
		{
			ENTRY = "A bear!",
			PET_ID = "mon_bear_cub",
			BONUS_ITEM = {}
		},
		{
			ENTRY = "A succubus!",
			PET_ID = "mon_succubi",
			BONUS_ITEM = {"holy_choker"}
		}
	}
}

--[[アークCUBIのmonster_idリスト。主に上位敵の召喚用に使う。]]--
MON_ARCH_CUBI_LIST = {
	"mon_succubi_sadist",
	"mon_succubi_somnophilia",
	"mon_succubi_exhibitionism",
	"mon_succubi_lactophilia",
	"mon_incubi_sthenolagnia",
	"mon_incubi_phalloplas",
	"mon_incubi_hoplophilia"
}


SEX_MORALE_TYPE		= morale_type("morale_sex_good")	--*気持ちいいこと*の意欲タイプ
SEX_BASE_TURN		= 100		--行為1wait当たりに掛かる基準ターン数(1ターン = 約6秒)。100=10分。
SEX_MAX_TURN		= 1800		--行為全体に掛かる最大ターン数。1800=3時間。
SEX_FUN_DURATION	= 600		--行為による意欲がどの程度長続きするかのtime_duration。
SEX_FUN_DECAY_START	= 150		--行為による意欲が冷め始めるまでのtime_duration。

D_GOM_BREAK_CHANCE	= 50		--あぶない方の避妊具が使用時に破損する確率(%)。

PREG_CHANCE = 10				--基礎妊娠確立(%)。
DEFAULT_PREG_SPEED_RATIO = 1	--孕んだ子供の成長スピード比率。


DEFAULT_NPC_NAME = "Tom"		--NPC新規生成時のデフォルト名。みんな大好きトム。


EFF_SPELL_CHARGE_INT_FACTOR = 30	--モンスター攻撃の魔法詠唱にかかるint_dur_factor。


--[[set_valueの値設定に使う名称]]--
EVENT_GOATHEAD_DEMON = "event_goathead_demon"				--モンスター"mon_goathead_demon"との会話イベントを発生させたかどうか
EVENT_DEMONBEING_SCHOOLGIRL = "event_demonbeing_schoolgirl"	--npc"demonbeing_schoolgirl"を発生させたかどうか
CREAMPIE_SEED_TYPE = "creampie_seed_type"					--注がれた種の種族を保持する。あなたがパパになるんですよ？
