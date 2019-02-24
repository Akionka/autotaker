script_name('AutoTaker')
script_author('akionka')
script_version('1.0')
script_version_number(1)

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local dlstatus = require 'moonloader'.download_status
local isGoUpdate = false
local close_next = false
local order = {}
local locked = false
encoding.default = 'cp1251'
u8 = encoding.UTF8

local ini = inicfg.load({
	settings = {
		typescriptwork = 0, -- 0 - PD, 1 - FBI, 2 - Army
		active = false
	},
	police_items = {
		armor = false, -- Бронежилет
		shield = false, -- Полицейский щит
		torch = false, -- Фонарик
		bhelmet = false, -- Чёрный шлем SWAT
		whelmet = false, -- Белый шлем SWAT
		mask = false, -- Вязаная маска
		bglasses = false, -- Очки «Police Black»
		rglasses = false, -- Очки «Police Red»
		blglasses = false, -- Очки «Police Blue»
		ccap = false, -- Парадная фуражка
		ocap = false, -- Офицерская фуражка
		bhh = false, -- Черная полицейская каска
		blhh = false, -- Синяя полицейская каска
		gmask = false, -- Противогаз
		helmet = false, -- Шлем патрульного
		pcap = false, -- Полицейская кепка
		baton = false, -- Жезл регулировщика
		vest = false, -- Оранжевый жилет
		brhat = false, -- Черная шляпа шерифа
		bhat = false -- Коричневая шляпа шерифа
	},
	fbi_items = {
		armor = false, -- Бронежилет
		shield = false, -- Полицейский щит
		torch = false, -- Фонарик
		bhelmet = false, -- Чёрный шлем SWAT
		whelmet = false, -- Белый шлем SWAT
		mask = false, -- Вязаная маска
		bglasses = false, -- Очки «Police Black»
		rglasses = false, -- Очки «Police Red»
		blglasses = false, -- Очки «Police Blue»
	},
	army_items = {
		armor = false,
		ls = false
	},
	police_guns = {
		stick = false,
		m4 = false,
		mp5 = false,
		deagle = false,
		rifle = false,
		shotgun = false,
	},
	fbi_guns = {
		stick = false,
		m4 = false,
		mp5 = false,
		deagle = false,
		rifle = false,
		shotgun = false,
		srifle = false,
		sawed = false,
		grens = false
	},
	army_guns = {
		m4 = false,
		mp5 = false,
		deagle = false,
		rifle = false,
		shotgun = false,
	},
}, "autotaker")

local settings_window_state = imgui.ImBool(false)
local active = imgui.ImBool(ini.settings.active)
local typescriptwork = imgui.ImInt(ini.settings.typescriptwork)
local startmsg = imgui.ImBool(ini.settings.startmsg)
local police_items = {
	armor = imgui.ImBool(ini.police_items.armor),
	shield = imgui.ImBool(ini.police_items.shield),
	torch = imgui.ImBool(ini.police_items.torch),
	bhelmet = imgui.ImBool(ini.police_items.bhelmet),
	whelmet = imgui.ImBool(ini.police_items.whelmet),
	mask = imgui.ImBool(ini.police_items.mask),
	bglasses = imgui.ImBool(ini.police_items.bglasses),
	rglasses = imgui.ImBool(ini.police_items.rglasses),
	blglasses = imgui.ImBool(ini.police_items.blglasses),
	ccap = imgui.ImBool(ini.police_items.ccap),
	ocap = imgui.ImBool(ini.police_items.ocap),
	bhh = imgui.ImBool(ini.police_items.bhh),
	blhh = imgui.ImBool(ini.police_items.blhh),
	gmask = imgui.ImBool(ini.police_items.gmask),
	helmet = imgui.ImBool(ini.police_items.helmet),
	pcap = imgui.ImBool(ini.police_items.pcap),
	baton = imgui.ImBool(ini.police_items.baton),
	vest = imgui.ImBool(ini.police_items.vest),
	brhat = imgui.ImBool(ini.police_items.brhat),
	bhat = imgui.ImBool(ini.police_items.bhat)}
local fbi_items = {
	armor = imgui.ImBool(ini.fbi_items.armor),
	shield = imgui.ImBool(ini.fbi_items.shield),
	torch = imgui.ImBool(ini.fbi_items.torch),
	bhelmet = imgui.ImBool(ini.fbi_items.bhelmet),
	whelmet = imgui.ImBool(ini.fbi_items.whelmet),
	mask = imgui.ImBool(ini.fbi_items.mask),
	bglasses = imgui.ImBool(ini.fbi_items.bglasses),
	rglasses = imgui.ImBool(ini.fbi_items.rglasses),
	blglasses = imgui.ImBool(ini.fbi_items.blglasses)}
local army_items = {
	armor = imgui.ImBool(ini.army_items.armor),
	ls = imgui.ImBool(ini.army_items.ls)}
local police_guns = {
	stick = imgui.ImBool(ini.police_guns.stick),
	m4 = imgui.ImBool(ini.police_guns.m4),
	mp5 = imgui.ImBool(ini.police_guns.mp5),
	deagle = imgui.ImBool(ini.police_guns.deagle),
	rifle = imgui.ImBool(ini.police_guns.rifle),
	shotgun = imgui.ImBool(ini.police_guns.shotgun)}
local fbi_guns = {
	stick = imgui.ImBool(ini.fbi_guns.stick),
	m4 = imgui.ImBool(ini.fbi_guns.m4),
	mp5 = imgui.ImBool(ini.fbi_guns.mp5),
	deagle = imgui.ImBool(ini.fbi_guns.deagle),
	rifle = imgui.ImBool(ini.fbi_guns.rifle),
	shotgun = imgui.ImBool(ini.fbi_guns.shotgun),
	srifle = imgui.ImBool(ini.fbi_guns.srifle),
	sawed = imgui.ImBool(ini.fbi_guns.sawed),
	grens = imgui.ImBool(ini.fbi_guns.grens)}
local army_guns = {
	m4 = imgui.ImBool(ini.army_guns.m4),
	mp5 = imgui.ImBool(ini.army_guns.mp5),
	deagle = imgui.ImBool(ini.army_guns.deagle),
	rifle = imgui.ImBool(ini.army_guns.rifle),
	shotgun = imgui.ImBool(ini.army_guns.shotgun)}
local names = {
	police_items = {
		armor = "Бронежилет", -- Бронежилет
		shield = "Полицейский щит", -- Полицейский щит
		torch = "Фонарик", -- Фонарик
		bhelmet = "Чёрный шлем SWAT", -- Чёрный шлем SWAT
		whelmet = "Белый шлем SWAT", -- Белый шлем SWAT
		mask = "Вязаная маска", -- Вязаная маска
		bglasses = "Очки «Police Black»", -- Очки «Police Black»
		rglasses = "Очки «Police Red»", -- Очки «Police Red»
		blglasses = "Очки «Police Blue»", -- Очки «Police Blue»
		ccap = "Парадная фуражка", -- Парадная фуражка
		ocap = "Офицерская фуражка", -- Офицерская фуражка
		bhh = "Черная полицейская каска", -- Черная полицейская каска
		blhh = "Синяя полицейская каска", -- Синяя полицейская каска
		gmask = "Противогаз", -- Противогаз
		helmet = "Шлем патрульного", -- Шлем патрульного
		pcap = "Полицейская кепка", -- Полицейская кепка
		baton = "Жезл регулировщика", -- Жезл регулировщика
		vest = "Оранжевый жилет", -- Оранжевый жилет
		brhat = "Черная шляпа шерифа", -- Черная шляпа шерифа
    bhat = "Коричневая шляпа шерифа" -- Коричневая шляпа шерифа
	},
	fbi_items = {
		armor = "Бронежилет", -- Бронежилет
		shield = "Полицейский щит", -- Полицейский щит
		torch = "Фонарик", -- Фонарик
		bhelmet = "Чёрный шлем SWAT", -- Чёрный шлем SWAT
		whelmet = "Белый шлем SWAT", -- Белый шлем SWAT
		mask = "Вязаная маска", -- Вязаная маска
		bglasses = "Очки «Police Black»", -- Очки «Police Black»
		rglasses = "Очки «Police Red»", -- Очки «Police Red»
		blglasses = "Очки «Police Blue»", -- Очки «Police Blue»
	},
	army_items = {
		armor = "Бронежилет", -- Бронежилет
		ls = "Громкоговоритель", -- Громкоговоритель
	},
	guns = {
		stick = 'Полицейская дубинка',
		m4 = 'M4', -- M4
		mp5 = 'MP5', -- MP5
		shotgun = 'Shotgun', -- Shotgun
		rifle = 'Rifle', -- Rifle
		deagle = 'Desert Eagle', -- Desert Eagle
		srifle = 'Снайперская винтовка', -- Sniper Rifle
		sawed = 'Обрез', -- Sawed-off shotgun
		grens = 'Гранаты', -- Grenades
	}}
local ids = {
	police_items = {
		armor = 1, -- Бронежилет
		shield = 2, -- Полицейский щит
		torch = 3, -- Фонарик
		bhelmet = 4, -- Чёрный шлем SWAT
		whelmet = 5, -- Белый шлем SWAT
		mask = 6, -- Вязаная маска
		bglasses = 7, -- Очки «Police Black»
		rglasses = 8, -- Очки «Police Red»
		blglasses = 9, -- Очки «Police Blue»
		ccap = 10, -- Парадная фуражка
		ocap = 11, -- Офицерская фуражка
		bhh = 12, -- Черная полицейская каска
		blhh = 13, -- Синяя полицейская каска
		gmask = 14, -- Противогаз
		helmet = 15, -- Шлем патрульного
		pcap = 16, -- Полицейская кепка
		baton = 17, -- Жезл регулировщика
		vest = 18, -- Оранжевый жилет
		brhat = 19, -- Черная шляпа шерифа
    bhat = 20 -- Коричневая шляпа шерифа
	},
	fbi_items = {
		armor = 1, -- Бронежилет
		shield = 2, -- Полицейский щит
		torch = 3, -- Фонарик
		bhelmet = 4, -- Чёрный шлем SWAT
		whelmet = 5, -- Белый шлем SWAT
		mask = 6, -- Вязаная маска
		bglasses = 7, -- Очки «Police Black»
		rglasses = 8, -- Очки «Police Red»
		blglasses = 9, -- Очки «Police Blue»
	},
	army_items = {
		armor = 0, -- Бронежилет
		ls = 1, -- Громкоговоритель
	},
	police_guns = {
		stick = 0,
		m4 = 1, -- M4
		mp5 = 2, -- MP5
		deagle = 5, -- Desert Eagle
		rifle = 4, -- Rifle
		shotgun = 3, -- Shotgun
	},
	fbi_guns = {
		stick = 0,
		m4 = 1, -- M4
		mp5 = 2, -- MP5
		shotgun = 3, -- Shotgun
		rifle = 4, -- Rifle
		deagle = 5, -- Desert Eagle
		srifle = 6, -- Sniper Rifle
		sawed = 7, -- Sawed-off shotgun
		grens = 8, -- Grenades
	},
	army_guns = {
		m4 = 0, -- M4
		mp5 = 1, -- MP5
		deagle = 2, -- Desert Eagle
		rifle = 3, -- Rifle
		shotgun = 4, -- Shotgun
	}}
function imgui.OnDrawFrame()
  if settings_window_state.v then
		imgui.Begin("AutoTaker", settings_window_state, 66)
		if imgui.CollapsingHeader("Тип работы скрипта") then
			if imgui.ListBox("", typescriptwork, {"Police", "FBI", "Army"}, imgui.ImInt(3)) then
				ini.settings.typescriptwork = typescriptwork.v
				inicfg.save(ini, "autotaker")
			end
			imgui.Separator()
		end
		if imgui.CollapsingHeader("Список предметов") then
			if typescriptwork.v == 0 then
					if imgui.Checkbox(names['police_items']['armor'], police_items['armor']) then
						ini.police_items.armor = police_items['armor'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['shield'], police_items['shield']) then
						ini.police_items.shield = police_items['shield'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['torch'], police_items['torch']) then
						ini.police_items.torch = police_items['torch'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['bhelmet'], police_items['bhelmet']) then
						ini.police_items.bhelmet = police_items['bhelmet'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['whelmet'], police_items['whelmet']) then
						ini.police_items.whelmet = police_items['whelmet'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['mask'], police_items['mask']) then
						ini.police_items.mask = police_items['mask'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['bglasses'], police_items['bglasses']) then
						ini.police_items.bglasses = police_items['bglasses'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['rglasses'], police_items['rglasses']) then
						ini.police_items.rglasses = police_items['rglasses'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['blglasses'], police_items['blglasses']) then
						ini.police_items.blglasses = police_items['blglasses'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['ccap'], police_items['ccap']) then
						ini.police_items.ccap = police_items['ccap'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['ocap'], police_items['ocap']) then
						ini.police_items.ocap = police_items['ocap'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['bhh'], police_items['bhh']) then
						ini.police_items.bhh = police_items['bhh'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['blhh'], police_items['blhh']) then
						ini.police_items.blhh = police_items['blhh'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['gmask'], police_items['gmask']) then
						ini.police_items.gmask = police_items['gmask'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['helmet'], police_items['helmet']) then
						ini.police_items.helmet = police_items['helmet'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['pcap'], police_items['pcap']) then
						ini.police_items.pcap = police_items['pcap'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['baton'], police_items['baton']) then
						ini.police_items.baton = police_items['baton'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['vest'], police_items['vest']) then
						ini.police_items.vest = police_items['vest'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['brhat'], police_items['brhat']) then
						ini.police_items.brhat = police_items['brhat'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['police_items']['bhat'], police_items['bhat']) then
						ini.police_items.bhat = police_items['bhat'].v
						inicfg.save(ini, "autotaker")
					end
			end
			if typescriptwork.v == 1 then
				if imgui.Checkbox(names['fbi_items']['armor'], fbi_items['armor']) then
					ini.fbi_items.armor = fbi_items['armor'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['shield'], fbi_items['shield']) then
					ini.fbi_items.shield = fbi_items['shield'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['torch'], fbi_items['torch']) then
					ini.fbi_items.torch = fbi_items['torch'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['bhelmet'], fbi_items['bhelmet']) then
					ini.fbi_items.bhelmet = fbi_items['bhelmet'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['whelmet'], fbi_items['whelmet']) then
					ini.fbi_items.whelmet = fbi_items['whelmet'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['mask'], fbi_items['mask']) then
					ini.fbi_items.mask = fbi_items['mask'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['bglasses'], fbi_items['bglasses']) then
					ini.fbi_items.bglasses = fbi_items['bglasses'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['rglasses'], fbi_items['rglasses']) then
					ini.fbi_items.rglasses = fbi_items['rglasses'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['fbi_items']['blglasses'], fbi_items['blglasses']) then
					ini.fbi_items.blglasses = fbi_items['blglasses'].v
					inicfg.save(ini, "autotaker")
				end
			end
			if typescriptwork.v == 2 then
				if imgui.Checkbox(names['army_items']['armor'], army_items['armor']) then
					ini.army_items.armor = army_items['armor'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['army_items']['ls'], army_items['ls']) then
					ini.army_items.ls = army_items['ls'].v
					inicfg.save(ini, "autotaker")
				end
			end
			imgui.Separator()
		end
		if imgui.CollapsingHeader("Список оружия") then
			if typescriptwork.v == 0 then
					if imgui.Checkbox(names['guns']['stick'], police_guns['stick']) then
						ini.police_guns.stick = police_guns['stick'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['guns']['m4'], police_guns['m4']) then
						ini.police_guns.m4 = police_guns['m4'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['guns']['mp5'], police_guns['mp5']) then
						ini.police_guns.mp5 = police_guns['mp5'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['guns']['shotgun'], police_guns['shotgun']) then
						ini.police_guns.shotgun = police_guns['shotgun'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['guns']['rifle'], police_guns['rifle']) then
						ini.police_guns.rifle = police_guns['rifle'].v
						inicfg.save(ini, "autotaker")
					end
					if imgui.Checkbox(names['guns']['deagle'], police_guns['deagle']) then
						ini.police_guns.deagle = police_guns['deagle'].v
						inicfg.save(ini, "autotaker")
					end
			end
			if typescriptwork.v == 1 then
				if imgui.Checkbox(names['guns']['stick'], fbi_guns['stick']) then
					ini.fbi_guns.stick = fbi_guns['stick'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['m4'], fbi_guns['m4']) then
					ini.fbi_guns.m4 = fbi_guns['m4'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['mp5'], fbi_guns['mp5']) then
					ini.fbi_guns.mp5 = fbi_guns['mp5'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['deagle'], fbi_guns['deagle']) then
					ini.fbi_guns.deagle = fbi_guns['deagle'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['rifle'], fbi_guns['rifle']) then
					ini.fbi_guns.rifle = fbi_guns['rifle'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['shotgun'], fbi_guns['shotgun']) then
					ini.fbi_guns.shotgun = fbi_guns['shotgun'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['srifle'], fbi_guns['srifle']) then
					ini.fbi_guns.srifle = fbi_guns['srifle'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['sawed'], fbi_guns['sawed']) then
					ini.fbi_guns.sawed = fbi_guns['sawed'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['grens'], fbi_guns['grens']) then
					ini.fbi_guns.grens = fbi_guns['grens'].v
					inicfg.save(ini, "autotaker")
				end
			end
			if typescriptwork.v == 2 then
				if imgui.Checkbox(names['guns']['m4'], army_guns['m4']) then
					ini.army_guns.m4 = army_guns['m4'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['mp5'], army_guns['mp5']) then
					ini.army_guns.mp5 = army_guns['mp5'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['deagle'], army_guns['deagle']) then
					ini.army_guns.deagle = army_guns['deagle'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['rifle'], army_guns['rifle']) then
					ini.army_guns.rifle = army_guns['rifle'].v
					inicfg.save(ini, "autotaker")
				end
				if imgui.Checkbox(names['guns']['shotgun'], army_guns['shotgun']) then
					ini.army_guns.shotgun = army_guns['shotgun'].v
					inicfg.save(ini, "autotaker")
				end
			end
			imgui.Separator()
		end
		if imgui.Checkbox("Активно?", active) then
			ini.settings.active = active.v
			inicfg.save(ini, "autotaker")
		end
		imgui.End()
  end
end

function get_pickup_model(id, handle)
  local stPickup = sampGetPickupPoolPtr()
  local handle = id * 20
  local result = handle + 61444
  local result = result + stPickup
  local modelid = readMemory(result, 4, true)
  return modelid
end

function sampev.onSendPickedUpPickup(id)
	local pickup = sampGetPickupHandleBySampId(id)
	local pickuppoolPtr = sampGetPickupPoolPtr(id)
	if get_pickup_model(id, pickup) == 1242 then
		if locked then return false end
		if #order == 0 then
			if ini.settings.typescriptwork == 0 then
				for k, v in pairs(ini.police_items) do
					if v then
						table.insert(order, ids['police_items'][k])
					end
				end
			end
			if ini.settings.typescriptwork == 1 then
				for k, v in pairs(ini.fbi_items) do
					if v then
						table.insert(order, ids['fbi_items'][k])
					end
				end
			end
			if ini.settings.typescriptwork == 2 then
				for k, v in pairs(ini.army_items) do
					if v then
						table.insert(order, ids['army_items'][k])
					end
				end
			end
		end
	end
	if get_pickup_model(id, pickup) == 2061 then
		if #order == 0 then
			if ini.settings.typescriptwork == 0 then
				for k, v in pairs(ini.police_guns) do
					if v then
						table.insert(order, ids['police_guns'][k])
					end
				end
			end
			if ini.settings.typescriptwork == 1 then
				for k, v in pairs(ini.fbi_guns) do
					if v then
						table.insert(order, ids['fbi_guns'][k])
					end
				end
			end
			if ini.settings.typescriptwork == 2 then
				for k, v in pairs(ini.army_guns) do
					if v then
						table.insert(order, ids['army_guns'][k])
					end
				end
			end
		end
	end
end

function sampev.onShowDialog(id, stytle, title, btn1, btn2, text)
	if id == 81 and ini.settings.active then
		if #order == 0 then
			locked = true
			sampAddChatMessage(u8:decode("[AutoTaker]: Можете отходить от пикапа. В теченее следующих {2980b9}6 секунд{FFFFFF} он будет неактивен."), -1)
			lua_thread.create(function()
				wait(6000)
				locked = false
			end)
			sampSendDialogResponse(id, 0, 0, "")
			return false
	 	end
		for k, v in pairs(order) do
			if v then
				close_next = true
				sampSendDialogResponse(id, 1, order[1], "")
				return false
			end
		end
	end
	if (id == 82 or id == 45) and close_next then
		table.remove(order, 1)
		close_next = false
		sampSendDialogResponse(id, 1, 0, "")
		return false
	end
	if id == 77 then
		for k, v in pairs(order) do
			if v then
				sampSendDialogResponse(id, 1, order[1], "")
				table.remove(order, 1)
				return false
			end
		end
	end
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
	sampAddChatMessage(u8:decode("[AutoTaker]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}. Автор - {2980b9}Akionka{FFFFFF}."), -1)

	update()
	while updateinprogess ~= false do wait(0) if isGoUpdate then isGoUpdate = false goupdate() end end

	sampRegisterChatCommand('autotaker', function() settings_window_state.v = not settings_window_state.v end)
	while true do
		wait(0)
		if isGoUpdate then goupdate() break end
		imgui.Process = settings_window_state.v
	end
end

function update()
	local fpath = os.getenv('TEMP') .. '\\autotaker-version.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Akionka/autotaker/master/version.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.version then
					version = info.version
					version_num = info.version_num
					if version_num > thisScript().version_num then
						sampAddChatMessage(u8:decode("[AutoTaker]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..version.."{FFFFFF}. Начинаю закачку."), -1)
						isGoUpdate = true
					else
						sampAddChatMessage(u8:decode("[AutoTaker]: У вас установлена самая свежая версия скрипта."), -1)
						updateinprogess = false
					end
				end
			end
		end
	end)
end
function goupdate()
	downloadUrlToFile("https://raw.githubusercontent.com/Akionka/autotaker/master/autotaker.lua", thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(u8:decode('[AutoTaker]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
			sampAddChatMessage(u8:decode('[AutoTaker]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
			sampAddChatMessage(u8:decode('[AutoTaker]: Скорее всего прямо сейчас у вас сломался курсор. Введите {2980b9}/autotaker{FFFFFF}.'), -1)
			sampAddChatMessage(u8:decode('[AutoTaker]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
			updateinprogess = false
		end
	end)
end
