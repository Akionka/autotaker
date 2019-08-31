script_name('AutoTaker')
script_author('akionka')
script_version('1.4.2')
script_version_number(8)
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
    false, -- Бронежилет
    false, -- Прибор ночного видения
    false, -- Полицейский щит
    false, -- Фонарик
    false, -- Чёрный шлем SWAT
    false, -- Белый шлем SWAT
    false, -- Вязаная маска
    false, -- Очки «Police Black»
    false, -- Очки «Police Red»
    false, -- Очки «Police Blue»
    false, -- Противогаз
    false, -- Парадная фуражка
    false, -- Офицерская фуражка
    false, -- Черная полицейская каска
    false, -- Синяя полицейская каска
    false, -- Шлем патрульного
    false, -- Полицейская кепка
    false, -- Жезл регулировщика
    false, -- Оранжевый жилет
    false, -- Черная шляпа шерифа
    false, -- Коричневая шляпа шерифа
  },

  fbi_items = {
    false, -- Бронежилет
    false, -- Прибор ночного видения
    false, -- Полицейский щит
    false, -- Фонарик
    false, -- Чёрный шлем SWAT
    false, -- Белый шлем SWAT
    false, -- Вязаная маска
    false, -- Очки «Police Black»
    false, -- Очки «Police Red»
    false, -- Очки «Police Blue»
    false, -- Противогаз
  },

  army_items = {
    false, -- Бронежилет
    false, -- Прибор ночного видения
    false, -- Громкоговоритель
    false, -- Берет «Army»
    false, -- Берет «Krap»
    false, -- Берет «Desant»
  },

  police_guns = {
    false, -- Дубинка
    false, -- M4
    false, -- MP5
    false, -- Дробовик
    false, -- Винтовка
    false, -- Desert Eagle
    false, -- Дымовая шашка
  },
  fbi_guns = {
    false, -- Tazer
    false, -- M4
    false, -- MP5
    false, -- Desert Eagle
    false, -- Винтовка
    false, -- Дробовик
    false, -- Снайперская винтовка
    false, -- Обрез
    false, -- Дымовая шашка
  },

  army_guns = {
    false, -- M4
    false, -- MP5
    false, -- Desert Eagle
    false, -- Винтовка
    false, -- Дробовик
    false, -- Дымовая шашка
  },
}

local mainWindowState = imgui.ImBool(false)
local active          = imgui.ImBool(false)
local typescriptwork  = imgui.ImInt(0)

local police_items = {
  imgui.ImBool(false), -- Бронежилет
  imgui.ImBool(false), -- Прибор ночного видения
  imgui.ImBool(false), -- Полицейский щит
  imgui.ImBool(false), -- Фонарик
  imgui.ImBool(false), -- Чёрный шлем SWAT
  imgui.ImBool(false), -- Белый шлем SWAT
  imgui.ImBool(false), -- Вязаная маска
  imgui.ImBool(false), -- Очки «Police Black»
  imgui.ImBool(false), -- Очки «Police Red»
  imgui.ImBool(false), -- Очки «Police Blue»
  imgui.ImBool(false), -- Противогаз
  imgui.ImBool(false), -- Парадная фуражка
  imgui.ImBool(false), -- Офицерская фуражка
  imgui.ImBool(false), -- Черная полицейская каска
  imgui.ImBool(false), -- Синяя полицейская каска
  imgui.ImBool(false), -- Шлем патрульного
  imgui.ImBool(false), -- Полицейская кепка
  imgui.ImBool(false), -- Жезл регулировщика
  imgui.ImBool(false), -- Оранжевый жилет
  imgui.ImBool(false), -- Черная шляпа шерифа
  imgui.ImBool(false), -- Коричневая шляпа шерифа
}

local fbi_items = {
  imgui.ImBool(false), -- Бронежилет
  imgui.ImBool(false), -- Прибор ночного видения
  imgui.ImBool(false), -- Полицейский щит
  imgui.ImBool(false), -- Фонарик
  imgui.ImBool(false), -- Чёрный шлем SWAT
  imgui.ImBool(false), -- Белый шлем SWAT
  imgui.ImBool(false), -- Вязаная маска
  imgui.ImBool(false), -- Очки «Police Black»
  imgui.ImBool(false), -- Очки «Police Red»
  imgui.ImBool(false), -- Очки «Police Blue»
  imgui.ImBool(false), -- Противогаз
}

local army_items = {
  imgui.ImBool(false), -- Бронежилет
  imgui.ImBool(false), -- Прибор ночного видения
  imgui.ImBool(false), -- Громкоговоритель
  imgui.ImBool(false), -- Берет «Army»
  imgui.ImBool(false), -- Берет «Krap»
  imgui.ImBool(false), -- Берет «Desant»
}

local police_guns = {
  imgui.ImBool(false), -- Дубинка
  imgui.ImBool(false), -- M4
  imgui.ImBool(false), -- MP5
  imgui.ImBool(false), -- Дробовик
  imgui.ImBool(false), -- Винтовка
  imgui.ImBool(false), -- Desert Eagle
  imgui.ImBool(false), -- Дымовая шашка
}

local fbi_guns = {
  imgui.ImBool(false), -- Tazer
  imgui.ImBool(false), -- M4
  imgui.ImBool(false), -- MP5
  imgui.ImBool(false), -- Shotgun
  imgui.ImBool(false), -- Rifle
  imgui.ImBool(false), -- Desert Eagle
  imgui.ImBool(false), -- Sniper Rifle
  imgui.ImBool(false), -- Sawed-off shotgun
  imgui.ImBool(false), -- Grenades
  imgui.ImBool(false), -- Дымовая шашка
}

local army_guns = {
  imgui.ImBool(false), -- M4
  imgui.ImBool(false), -- MP5
  imgui.ImBool(false), -- Desert Eagle
  imgui.ImBool(false), -- Rifle
  imgui.ImBool(false), -- Shotgun
  imgui.ImBool(false), -- Дымовая шашка
}

local names = {
  police_items = {
    'Бронежилет',
    'Прибор ночного видения',
    'Полицейский щит',
    'Фонарик',
    'Чёрный шлем SWAT',
    'Белый шлем SWAT',
    'Вязаная маска',
    'Очки «Police Black»',
    'Очки «Police Red»',
    'Очки «Police Blue»',
    'Противогаз',
    'Парадная фуражка',
    'Офицерская фуражка',
    'Черная полицейская каска',
    'Синяя полицейская каска',
    'Шлем патрульного',
    'Полицейская кепка',
    'Жезл регулировщика',
    'Оранжевый жилет',
    'Черная шляпа шерифа',
    'Коричневая шляпа шерифа',
  },

  fbi_items = {
    'Бронежилет',
    'Прибор ночного видения',
    'Полицейский щит',
    'Фонарик',
    'Чёрный шлем SWAT',
    'Белый шлем SWAT',
    'Вязаная маска',
    'Очки «Police Black»',
    'Очки «Police Red»',
    'Очки «Police Blue»',
    'Противогаз',
  },

  army_items = {
    'Бронежилет',
    'Прибор ночного видения',
    'Громкоговоритель',
    'Берет «Army»',
    'Берет «Krap»',
    'Берет «Desant»',
  },

  police_guns = {
    'Дубинка',
    'M4',
    'MP5',
    'Shotgun',
    'Rifle',
    'Desert Eagle',
    'Дымовая шашка',
  },

  fbi_guns = {
    'Дубинка',
    'M4',
    'MP5',
    'Shotgun',
    'Rifle',
    'Desert Eagle',
    'Снайперская винтовка',
    'Обрез',
    'Гранаты',
    'Дымовая шашка',
  },

  army_guns = {
    'M4',
    'MP5',
    'Desert Eagle',
    'Rifle',
    'Shotgun',
    'Дымовая шашка',
  },
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
          if imgui.Checkbox(names['police_items'][k], v) then
            data['police_items'][k] = police_items[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 1 then
        for k, v in pairs(fbi_items) do
          if imgui.Checkbox(names['fbi_items'][k], v) then
            data['fbi_items'][k] = fbi_items[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 2 then
        for k, v in pairs(army_items) do
          if imgui.Checkbox(names['army_items'][k], v) then
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
          if imgui.Checkbox(names['police_guns'][k], v) then
            data['police_guns'][k] = police_guns[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 1 then
        for k, v in pairs(fbi_guns) do
          if imgui.Checkbox(names['fbi_guns'][k], v) then
            data['fbi_guns'][k] = fbi_guns[k].v
            saveData()
          end
        end
      end

      if typescriptwork.v == 2 then
        for k, v in pairs(army_guns) do
          if imgui.Checkbox(names['army_guns'][k], v) then
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
            table.insert(orderList, k)
            print(k)
          end
        end
      end
      if data['settings']['typescriptwork'] == 1 then
        for k, v in pairs(data['fbi_items']) do
          if v then
            table.insert(orderList, k)
          end
        end
      end
      if data['settings']['typescriptwork'] == 2 then
        for k, v in pairs(data['army_items']) do
          if v then
            table.insert(orderList, k)
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
            table.insert(orderList, k - 1)
          end
        end
      end
      if data['settings']['typescriptwork'] == 1 then
        for k, v in pairs(data['fbi_guns']) do
          if v then
            table.insert(orderList, k - 1)
          end
        end
      end
      if data['settings']['typescriptwork'] == 2 then
        for k, v in pairs(data['army_guns']) do
          if v then
            table.insert(orderList, k - 1)
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