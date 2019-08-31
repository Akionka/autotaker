script_name('AutoTaker')
script_author('akionka')
script_version('1.4.0')
script_version_number(6)
script_moonloader(27)

require 'deps' {
  'fyp:samp-lua',
  'fyp:moon-imgui',
}

local sampev           = require 'lib.samp.events'
local encoding         = require 'encoding'
local imgui            = require 'imgui'


local updatesAvaliable = false

encoding.default       = 'cp1251'
local u8               = encoding.UTF8

local prefix           = 'Autotaker'
local close_next = false
local orderList      = {}
local locked     = false
encoding.default = 'cp1251'
u8 = encoding.UTF8

local data = {
  settings = {
    typescriptwork         = 0, --[[
      0 - PD,
      1 - FBI,
      2 - Army
    ]]
    active                 = false,
    alwaysAutoCheckUpdates = false,
  },
  police_items = {
    armor     = false, -- Бронежилет
    nvdevice  = false, -- Прибор ночного видения
    shield    = false, -- Полицейский щит
    torch     = false, -- Фонарик
    bhelmet   = false, -- Чёрный шлем SWAT
    whelmet   = false, -- Белый шлем SWAT
    mask      = false, -- Вязаная маска
    bglasses  = false, -- Очки «Police Black»
    rglasses  = false, -- Очки «Police Red»
    blglasses = false, -- Очки «Police Blue»
    gmask     = false, -- Противогаз
    ccap      = false, -- Парадная фуражка
    ocap      = false, -- Офицерская фуражка
    bhh       = false, -- Черная полицейская каска
    blhh      = false, -- Синяя полицейская каска
    helmet    = false, -- Шлем патрульного
    pcap      = false, -- Полицейская кепка
    baton     = false, -- Жезл регулировщика
    vest      = false, -- Оранжевый жилет
    brhat     = false, -- Черная шляпа шерифа
    bhat      = false, -- Коричневая шляпа шерифа
  },
  fbi_items = {
    armor     = false, -- Бронежилет
    nvdevice  = false, -- Прибор ночного видения
    shield    = false, -- Полицейский щит
    torch     = false, -- Фонарик
    bhelmet   = false, -- Чёрный шлем SWAT
    whelmet   = false, -- Белый шлем SWAT
    mask      = false, -- Вязаная маска
    bglasses  = false, -- Очки «Police Black»
    rglasses  = false, -- Очки «Police Red»
    blglasses = false, -- Очки «Police Blue»
    gmask     = false, -- Противогаз
  },
  army_items = {
    armor       = false, -- Бронежилет
    nvdevice    = false, -- Прибор ночного видения
    ls          = false, -- Громкоговоритель
    beretarmy   = false, -- Берет «Army»
    beretkrap   = false, -- Берет «Krap»
    beretdesant = false, -- Берет «Desant»
  },
  police_guns = {
    m4      = false,
    stick   = false,
    mp5     = false,
    deagle  = false,
    rifle   = false,
    shotgun = false,
  },
  fbi_guns = {
    stick   = false,
    m4      = false,
    mp5     = false,
    deagle  = false,
    rifle   = false,
    shotgun = false,
    srifle  = false,
    sawed   = false,
    grens   = false
  },
  army_guns = {
    m4      = false,
    mp5     = false,
    deagle  = false,
    rifle   = false,
    shotgun = false,
  },
}

local mainWindowState = imgui.ImBool(false)
local active          = imgui.ImBool(false)
local typescriptwork  = imgui.ImInt(0)

local police_items = {
  armor     = imgui.ImBool(false),
  nvdevice  = imgui.ImBool(false),
  shield    = imgui.ImBool(false),
  torch     = imgui.ImBool(false),
  bhelmet   = imgui.ImBool(false),
  whelmet   = imgui.ImBool(false),
  mask      = imgui.ImBool(false),
  bglasses  = imgui.ImBool(false),
  rglasses  = imgui.ImBool(false),
  blglasses = imgui.ImBool(false),
  gmask     = imgui.ImBool(false),
  ccap      = imgui.ImBool(false),
  ocap      = imgui.ImBool(false),
  bhh       = imgui.ImBool(false),
  blhh      = imgui.ImBool(false),
  helmet    = imgui.ImBool(false),
  pcap      = imgui.ImBool(false),
  baton     = imgui.ImBool(false),
  vest      = imgui.ImBool(false),
  brhat     = imgui.ImBool(false),
  bhat      = imgui.ImBool(false),
}

local fbi_items = {
  armor     = imgui.ImBool(false),
  nvdevice  = imgui.ImBool(false),
  shield    = imgui.ImBool(false),
  torch     = imgui.ImBool(false),
  bhelmet   = imgui.ImBool(false),
  whelmet   = imgui.ImBool(false),
  mask      = imgui.ImBool(false),
  bglasses  = imgui.ImBool(false),
  rglasses  = imgui.ImBool(false),
  blglasses = imgui.ImBool(false),
  gmask     = imgui.ImBool(false),
}

local army_items = {
  armor       = imgui.ImBool(false),
  nvdevice    = imgui.ImBool(false),
  ls          = imgui.ImBool(false),
  beretarmy   = imgui.ImBool(false),
  beretkrap   = imgui.ImBool(false),
  beretdesant = imgui.ImBool(false),
}

local police_guns = {
  stick   = imgui.ImBool(false),
  m4      = imgui.ImBool(false),
  mp5     = imgui.ImBool(false),
  deagle  = imgui.ImBool(false),
  rifle   = imgui.ImBool(false),
  shotgun = imgui.ImBool(false),
}

local fbi_guns = {
  stick   = imgui.ImBool(false),
  m4      = imgui.ImBool(false),
  mp5     = imgui.ImBool(false),
  deagle  = imgui.ImBool(false),
  rifle   = imgui.ImBool(false),
  shotgun = imgui.ImBool(false),
  srifle  = imgui.ImBool(false),
  sawed   = imgui.ImBool(false),
  grens   = imgui.ImBool(false),
}

local army_guns = {
  m4      = imgui.ImBool(false),
  mp5     = imgui.ImBool(false),
  deagle  = imgui.ImBool(false),
  rifle   = imgui.ImBool(false),
  shotgun = imgui.ImBool(false),
}

local names = {
  items = {
    armor       = 'Бронежилет',
    shield      = 'Полицейский щит',
    torch       = 'Фонарик',
    bhelmet     = 'Чёрный шлем SWAT',
    whelmet     = 'Белый шлем SWAT',
    mask        = 'Вязаная маска',
    bglasses    = 'Очки «Police Black»',
    rglasses    = 'Очки «Police Red»',
    blglasses   = 'Очки «Police Blue»',
    gmask       = 'Противогаз',
    ccap        = 'Парадная фуражка',
    ocap        = 'Офицерская фуражка',
    bhh         = 'Черная полицейская каска',
    blhh        = 'Синяя полицейская каска',
    helmet      = 'Шлем патрульного',
    pcap        = 'Полицейская кепка',
    baton       = 'Жезл регулировщика',
    vest        = 'Оранжевый жилет',
    brhat       = 'Черная шляпа шерифа',
    bhat        = 'Коричневая шляпа шерифа',
    nvdevice    = 'Прибор НВ',
    ls          = 'Громкоговоритель',
    beretarmy   = 'Берет «Army»',
    beretkrap   = 'Берет «Krap»',
    beretdesant = 'Берет «Desant»',
  },

  guns = {
    stick   = 'Тайзер',
    m4      = 'M4',
    mp5     = 'MP5',
    shotgun = 'Дробовик',
    rifle   = 'Винтовка',
    deagle  = 'Desert Eagle',
    srifle  = 'Снайперская винтовка',
    sawed   = 'Обрез',
    grens   = 'Гранаты',
  },
}

local ids = {
  police_items = {
    armor     = 1, -- Бронежилет
    nvdevice  = 2, -- Прибор ночного видения
    shield    = 3, -- Полицейский щит
    torch     = 4, -- Фонарик
    bhelmet   = 5, -- Чёрный шлем SWAT
    whelmet   = 6, -- Белый шлем SWAT
    mask      = 7, -- Вязаная маска
    bglasses  = 8, -- Очки «Police Black»
    rglasses  = 9, -- Очки «Police Red»
    blglasses = 10, -- Очки «Police Blue»
    gmask     = 11, -- Противогаз
    ccap      = 12, -- Парадная фуражка
    ocap      = 13, -- Офицерская фуражка
    bhh       = 14, -- Черная полицейская каска
    blhh      = 15, -- Синяя полицейская каска
    helmet    = 16, -- Шлем патрульного
    pcap      = 17, -- Полицейская кепка
    baton     = 18, -- Жезл регулировщика
    vest      = 19, -- Оранжевый жилет
    brhat     = 20, -- Черная шляпа шерифа
    bhat      = 21, -- Коричневая шляпа шерифа
  },

  fbi_items = {
    armor     = 1, -- Бронежилет
    nvdevice  = 2, -- Прибор ночного видения
    shield    = 3, -- Полицейский щит
    torch     = 4, -- Фонарик
    bhelmet   = 5, -- Чёрный шлем SWAT
    whelmet   = 6, -- Белый шлем SWAT
    mask      = 7, -- Вязаная маска
    bglasses  = 8, -- Очки «Police Black»
    rglasses  = 9, -- Очки «Police Red»
    blglasses = 10, -- Очки «Police Blue»
    gmask     = 11, -- Противогаз
  },

  army_items = {
    armor       = 0, -- Бронежилет
    nvdevice    = 1, -- Прибор ночного видения
    ls          = 2, -- Громкоговоритель
    beretarmy   = 3, -- Берет «Army»
    beretkrap   = 4, -- Берет «Krap»
    beretdesant = 5, -- Берет «Desant»
  },

  police_guns = {
    stick   = 0, -- Tazer
    m4      = 1, -- M4
    mp5     = 2, -- MP5
    deagle  = 5, -- Desert Eagle
    rifle   = 4, -- Rifle
    shotgun = 3, -- Shotgun
  },

  fbi_guns = {
    stick   = 0, -- Tazer
    m4      = 1, -- M4
    mp5     = 2, -- MP5
    shotgun = 3, -- Shotgun
    rifle   = 4, -- Rifle
    deagle  = 5, -- Desert Eagle
    srifle  = 6, -- Sniper Rifle
    sawed   = 7, -- Sawed-off shotgun
    grens   = 8, -- Grenades
  },

  army_guns = {
    m4      = 0, -- M4
    mp5     = 1, -- MP5
    deagle  = 2, -- Desert Eagle
    rifle   = 3, -- Rifle
    shotgun = 4, -- Shotgun
  }
}

function imgui.OnDrawFrame()
  if mainWindowState.v then
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(576, 350), 2)
    imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/2), 2, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Autotaker v'..thisScript()['version'], mainWindowState, imgui.WindowFlags.NoResize)
    if imgui.CollapsingHeader('Тип работы скрипта') then
      if imgui.ListBox('', typescriptwork, {'Police', 'FBI', 'Army'}, imgui.ImInt(3)) then
        data['settings']['typescriptwork'] = typescriptwork.v
        saveData()
      end
      imgui.Separator()
    end
    if imgui.CollapsingHeader('Список предметов') then

      if typescriptwork.v == 0 then
        for k, v in pairs(police_items) do
          if imgui.Checkbox(names['items'][k], v) then
            data['police_items'][k] = police_items[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 1 then
        for k, v in pairs(fbi_items) do
          if imgui.Checkbox(names['items'][k], v) then
            data['fbi_items'][k] = fbi_items[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 2 then
        for k, v in pairs(army_items) do
          if imgui.Checkbox(names['items'][k], v) then
            data['army_items'][k] = army_items[k].v
            saveData()
          end
        end
      end

      imgui.Separator()
    end
    if imgui.CollapsingHeader('Список оружия') then

      if typescriptwork.v == 0 then
        for k, v in pairs(police_guns) do
          if imgui.Checkbox(names['guns'][k], v) then
            data['police_guns'][k] = police_guns[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 1 then
        for k, v in pairs(fbi_guns) do
          if imgui.Checkbox(names['guns'][k], v) then
            data['fbi_guns'][k] = fbi_guns[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 2 then
        for k, v in pairs(army_guns) do
          if imgui.Checkbox(names['guns'][k], v) then
            data['army_guns'][k] = army_guns[k].v
            saveData()
          end
        end
      end

      imgui.Separator()
    end
    if imgui.Checkbox('Активно?', active) then
      data['settings']['active'] = active.v
      saveData()
    end
    if updatesAvaliable and imgui.Button('Скачать обновление', imgui.ImVec2(150, 0)) then
      update('https://raw.githubusercontent.com/Akionka/autotaker/master/autotaker.lua')
      mainWindowState.v = false
    end
    if not updatesAvaliable and imgui.Button('Проверить обновления', imgui.ImVec2(150, 0)) then
      checkUpdates('https://raw.githubusercontent.com/Akionka/autotaker/master/version.json')
    end
    imgui.SameLine()
    if imgui.Button('Группа ВКонтакте', imgui.ImVec2(150, 0)) then os.execute('explorer "https://vk.com/akionkamods"') end
    if imgui.Button('Bug report [VK]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://vk.com/akionka"') end
    imgui.SameLine()
    if imgui.Button('Bug report [Telegram]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://teleg.run/akionka"') end
    imgui.End()
  end
end

function get_pickup_model(id, handle)
  return readMemory(id * 20 + 61444 + sampGetPickupPoolPtr(), 4, true)
end

function sampev.onSendPickedUpPickup(id)
  local pickup = sampGetPickupHandleBySampId(id)
  local pickuppoolPtr = sampGetPickupPoolPtr(id)


  -- Доп. снаряжение
  if get_pickup_model(id, pickup) == 1242 then
    if locked then return false end
    if #orderList == 0 then
      if data['settings']['typescriptwork'] == 0 then
        for k, v in pairs(data['police_items']) do
          if v then
            table.insert(orderList, ids['police_items'][k])
          end
        end
      end
      if data['settings']['typescriptwork'] == 1 then
        for k, v in pairs(data['fbi_items']) do
          if v then
            table.insert(orderList, ids['fbi_items'][k])
          end
        end
      end
      if data['settings']['typescriptwork'] == 2 then
        for k, v in pairs(data['army_items']) do
          if v then
            table.insert(orderList, ids['army_items'][k])
          end
        end
      end
    end
  end

  -- Оружейная
  if get_pickup_model(id, pickup) == 2061 then
    if #orderList == 0 then
      if data['settings']['typescriptwork'] == 0 then
        for k, v in pairs(data['police_guns']) do
          if v then
            table.insert(orderList, ids['police_guns'][k])
          end
        end
      end
      if data['settings']['typescriptwork'] == 1 then
        for k, v in pairs(data['fbi_guns']) do
          if v then
            table.insert(orderList, ids['fbi_guns'][k])
          end
        end
      end
      if data['settings']['typescriptwork'] == 2 then
        for k, v in pairs(data['army_guns']) do
          if v then
            table.insert(orderList, ids['army_guns'][k])
          end
        end
      end
    end
  end
end

function sampev.onShowDialog(id, stytle, title, btn1, btn2, text)
  -- alert(id..'|'..u8:encode(title))

  if (id == 81 or id == 83) and data['settings']['active'] then
    if #orderList == 0 then
      locked = true
      alert('Можете отходить от пикапа. В теченее следующих {9932cc}6 секунд{FFFFFF} он будет неактивен')
      lua_thread.create(function()
        wait(6000)
        locked = false
      end)
      sampSendDialogResponse(id, 0, 0, '')
      return false
    end
    for k, v in pairs(orderList) do
      if v then
        close_next = true
        print(orderList[1])
        sampSendDialogResponse(id, 1, orderList[1], '')
        return false
      end
    end
  end


  if (id == 82 or id == 45) and close_next then
    table.remove(orderList, 1)
    close_next = false
    sampSendDialogResponse(id, 1, 0, '')
    return false
  end

  -- Оружейная
  if (id == 76 or id == 77 or id == 78) and data['settings']['active'] then
    for k, v in pairs(orderList) do
      if v then
        sampSendDialogResponse(id, 1, orderList[1], '')
        table.remove(orderList, 1)
        return false
      end
    end
  end
end

function sampev.onSendDialogResponse(id, btn, list, text)
  print(id, btn, list, text)
end

function applyCustomStyle()
  imgui.SwitchContext()
  local style  = imgui.GetStyle()
  local colors = style.Colors
  local clr    = imgui.Col
  local ImVec4 = imgui.ImVec4

  style.WindowRounding      = 0.0
  style.WindowTitleAlign    = imgui.ImVec2(0.5, 0.5)
  style.ChildWindowRounding = 0.0
  style.FrameRounding       = 0.0
  style.ItemSpacing         = imgui.ImVec2(5.0, 5.0)
  style.ScrollbarSize       = 13.0
  style.ScrollbarRounding   = 0
  style.GrabMinSize         = 8.0
  style.GrabRounding        = 0.0

  colors[clr.FrameBg]             = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBgHovered]      = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBgActive]       = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.TitleBg]             = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.TitleBgActive]       = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.TitleBgCollapsed]    = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.CheckMark]           = ImVec4(0.60, 0.20, 0.80, 1.00)
  -- colors[clr.SliderGrab]       = ImVec4(0.60, 0.20, 0.80, 1.00)
  -- colors[clr.SliderGrabActive] = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.Button]              = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.ButtonHovered]       = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.ButtonActive]        = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.Header]              = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.HeaderHovered]       = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.HeaderActive]        = ImVec4(0.60, 0.20, 0.80, 1.00)
  colors[clr.Separator]           = colors[clr.Border]
  colors[clr.SeparatorHovered]    = ImVec4(0.75, 0.10, 0.10, 0.78)
  colors[clr.SeparatorActive]     = ImVec4(0.75, 0.10, 0.10, 1.00)
  colors[clr.ResizeGrip]          = ImVec4(0.15, 0.68, 0.38, 1.00)
  colors[clr.ResizeGripHovered]   = ImVec4(0.15, 0.68, 0.38, 1.00)
  colors[clr.ResizeGripActive]    = ImVec4(0.15, 0.68, 0.38, 0.95)
  colors[clr.TextSelectedBg]      = ImVec4(0.98, 0.26, 0.26, 0.35)
  colors[clr.Text]                = ImVec4(1.00, 1.00, 1.00, 1.00)
  colors[clr.TextDisabled]        = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg]            = ImVec4(0.13, 0.13, 0.13, 1.00)
  colors[clr.ChildWindowBg]       = ImVec4(0.13, 0.13, 0.13, 1.00)
  colors[clr.PopupBg]             = ImVec4(0.13, 0.13, 0.13, 1.00)
  colors[clr.ComboBg]             = colors[clr.PopupBg]
  colors[clr.Border]              = ImVec4(0.43, 0.43, 0.50, 0.00)
  colors[clr.BorderShadow]        = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.CloseButton]         = ImVec4(0.60, 0.20, 0.80, 0.50)
  colors[clr.CloseButtonHovered]  = ImVec4(0.60, 0.20, 0.80, 0.50)
  colors[clr.CloseButtonActive]   = ImVec4(0.60, 0.20, 0.80, 0.50)
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
  if doesDirectoryExist(getWorkingDirectory()..'\\config') then createDirectory(getWorkingDirectory()..'\\config') end

  applyCustomStyle()
  loadData()

  print(u8:decode('{FFFFFF}Скрипт успешно загружен.'))
  print(u8:decode('{FFFFFF}Версия: {9932cc}'..thisScript()['version']..'{FFFFFF}. Автор: {9932cc}Akionka{FFFFFF}.'))
  print(u8:decode('{FFFFFF}Приятного использования! :)'))

  if data['settings']['alwaysAutoCheckUpdates'] then
    checkUpdates('https://raw.githubusercontent.com/Akionka/autotaker/master/version.json')
  end

  sampRegisterChatCommand('autotaker', function()
    mainWindowState.v = not mainWindowState.v
  end)

  while true do
    wait(0)
    imgui.Process = mainWindowState.v
  end
end

function checkUpdates(json)
  local fpath = os.tmpname()
  if doesFileExist(fpath) then os.remove(fpath) end
  downloadUrlToFile(json, fpath, function(_, status, _, _)
    if status == 58 then
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'r')
        if f then
          local info = decodeJson(f: read('*a'))
          f:close()
          os.remove(fpath)
          if info['version_num'] > thisScript()['version_num'] then
            updatesAvaliable = true
            alert('Найдено объявление. Текущая версия: {9932cc}'..thisScript()['version']..'{FFFFFF}, новая версия: {9932cc}'..info['version']..'{FFFFFF}')
            return true
          else
            updatesAvaliable = false
            alert('У вас установлена самая свежая версия скрипта')
          end
        else
          updatesAvaliable = false
          alert('Что-то пошло не так, упс. Попробуйте позже')
        end
      end
    end
  end)
end

function update(url)
  downloadUrlToFile(url, thisScript().path, function(_, status, _, _)
    if status == 6 then
      alert('Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...')
      alert('... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение')
      alert('Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}')
      thisScript():reload()
    end
  end)
end

function loadData()
  if not doesFileExist(getWorkingDirectory()..'\\config\\autotaker.json') then
    local configFile = io.open(getWorkingDirectory()..'\\config\\autotaker.json', 'w+')
    configFile:write(encodeJson(data))
    configFile:close()
    return
  end

  local configFile = io.open(getWorkingDirectory()..'\\config\\autotaker.json', 'r')
  data = decodeJson(configFile:read('*a'))
  configFile:close()

  active.v          = data['settings']['active'] or false
  typescriptwork.v  = data['settings']['typescriptwork'] or 0

  for k, v in pairs(police_items) do
    police_items[k].v = data['police_items'][k] or false
  end

  for k, v in pairs(fbi_items) do
    fbi_items[k].v = data['fbi_items'][k] or false
  end

  for k, v in pairs(army_items) do
    army_items[k].v = data['army_items'][k] or false
  end

  for k, v in pairs(police_guns) do
    police_guns[k].v = data['police_guns'][k] or false
  end

  for k, v in pairs(fbi_guns) do
    fbi_guns[k].v = data['fbi_guns'][k] or false
  end

  for k, v in pairs(army_guns) do
    army_guns[k].v = data['army_guns'][k] or false
  end
end

function saveData()
  local configFile = io.open(getWorkingDirectory()..'\\config\\autotaker.json', 'w+')
  configFile:write(encodeJson(data))
  configFile:close()
end

function alert(text)
  sampAddChatMessage(u8:decode('['..prefix..']: '..text), -1)
end