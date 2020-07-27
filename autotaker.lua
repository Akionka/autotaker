script_name('AutoTaker')
script_author('akionka')
script_version('1.6.0')
script_version_number(17)
script_moonloader(27)

require 'deps' {
  'fyp:samp-lua',
  'fyp:moon-imgui',
  'Akionka:lua-semver',
}

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local imgui = require 'imgui'
local v = require 'semver'
local inspect = require 'inspect'

local updatesAvaliable = false
local lastTagAvaliable = '1.0'

encoding.default = 'cp1251'
local u8 = encoding.UTF8

local prefixes = {'police', 'fbi', 'army'}
local close_next = false
local orderList = {}
local locked = false
encoding.default = 'cp1251'
u8 = encoding.UTF8

local defaultProfile = {
  title = 'Profile1',
  typescriptwork = 0, --[[
    0 - PD,
    1 - FBI,
    2 - Army
  ]]

  police_items = {
    armor = false,
    larmor = false,
    nightvision = false,
    holster = false,
    shield = false,
    flashlight = false,
    camera = false,
    bhelmet = false,
    whelmet = false,
    mask = false,
    blkglasses = false,
    redglasses = false,
    bluglasses = false,
    gasmask = false,
    ceremonialcap = false,
    officercap = false,
    blkphelmet = false,
    bluphelmet = false,
    phelmet = false,
    pcap = false,
    stick = false,
    vest = false,
    blkhat = false,
    brnhat = false,
  },

  fbi_items = {
    armor = false,
    larmor = false,
    nightvision = false,
    holster = false,
    shield = false,
    flashlight = false,
    camera = false,
    bhelmet = false,
    whelmet = false,
    mask = false,
    blkglasses = false,
    redglasses = false,
    bluglasses = false,
    gasmask = false,
  },

  army_items = {
    armor = false,
    larmor = false,
    nightvision = false,
    holster = false,
    loudspeaker = false,
    bereta = false,
    beretk = false,
    beretd = false,
    bshield = false,
  },

  police_guns = {
    stick = false,
    m4 = false,
    mp5 = false,
    shotgun = false,
    rifle = false,
    deagle = false,
    smkbomb = false,
  },

  fbi_guns = {
    stick = false,
    m4 = false,
    mp5 = false,
    shotgun = false,
    rifle = false,
    deagle = false,
    srifle = false,
    sawnoff = false,
    grenades = false,
    smkbomb = false,
  },

  army_guns = {
    m4 = false,
    mp5 = false,
    deagle = false,
    rifle = false,
    shotgun = false,
    smkbomb = false,
  },
}

local data = {
  settings = {
    active                 = false,
    alwaysAutoCheckUpdates = true,
    selectedProfile        = 1,
  },
  profiles = {
    defaultProfile,
  },
}

local mainWindowState = imgui.ImBool(false)
local active          = imgui.ImBool(false)
local typescriptwork  = imgui.ImInt(0)
local selectedProfile = 1
local selectedTab     = 1
local tempBuffers     = {}

-- Список названий всех возможных предметов и оружия
-- Ключ - внутрений ID предмета, значение - его название в ImGui диалоге
local names = {
  items = {
    armor = 'Бронежилет',
    larmor = 'Легкий бронежилет',
    nightvision = 'Прибор ночного видения',
    holster = 'Кобура',
    shield = 'Полицейский щит',
    flashlight ='Фонарик',
    camera = 'Фотоаппарат',
    bhelmet = 'Чёрный шлем SWAT',
    whelmet ='Белый шлем SWAT',
    mask = 'Вязаная маска',
    blkglasses = 'Очки «Police Black»',
    redglasses = 'Очки «Police Red»',
    bluglasses = 'Очки «Police Blue»',
    gasmask = 'Противогаз',
    ceremonialcap = 'Парадная фуражка',
    officercap = 'Офицерская фуражка',
    blkphelmet = 'Черная полицейская каска',
    bluphelmet = 'Синяя полицейская каска',
    phelmet = 'Шлем патрульного',
    pcap = 'Полицейская кепка',
    stick = 'Жезл регулировщика',
    vest = 'Оранжевый жилет',
    blkhat = 'Черная шляпа шерифа',
    brnhat = 'Коричневая шляпа шерифа',
    loudspeaker = 'Громкоговоритель',
    bereta = 'Берет «Army»',
    beretk = 'Берет «Krap»',
    beretd = 'Берет «Desant»',
    bshield = 'Баллистический щит',
  },

  guns = {
    stick = 'Дубинка',
    m4 = 'M4',
    mp5 = 'MP5',
    shotgun = 'Shotgun',
    rifle = 'Rifle',
    deagle = 'Desert Eagle',
    srifle = 'Снайперская винтовка',
    sawnoff = 'Обрез',
    grenades = 'Гранаты',
    smkbomb = 'Дымовая шашка',
  },
}

-- То, как предметы расставлены в серверных диалогах
-- Значение - внутрений ID предмета
local lists = {
  police_items = {
    'armor',
    'larmor',
    'nightvision',
    'holster',
    'shield',
    'flashlight',
    'camera',
    'bhelmet',
    'whelmet',
    'mask',
    'blkglasses',
    'redglasses',
    'bluglasses',
    'gasmask',
    'ceremonialcap',
    'officercap',
    'blkphelmet',
    'bluphelmet',
    'phelmet',
    'pcap',
    'stick',
    'vest',
    'blkhat',
    'brnhat',
  },

  fbi_items = {
    'armor',
    'larmor',
    'nightvision',
    'holster',
    'shield',
    'flashlight',
    'camera',
    'bhelmet',
    'whelmet',
    'mask',
    'blkglasses',
    'redglasses',
    'bluglasses',
    'gasmask',
  },

  army_items = {
    'armor',
    'larmor',
    'nightvision',
    'holster',
    'loudspeaker',
    'bereta',
    'beretk',
    'beretd',
    'bshield',
  },

  police_guns = {
    'stick',
    'm4',
    'mp5',
    'shotgun',
    'rifle',
    'deagle',
    'smkbomb',
  },

  fbi_guns = {
    'stick',
    'm4',
    'mp5',
    'shotgun',
    'rifle',
    'deagle',
    'rifle',
    'sawnoff',
    'grenades',
    'smkbomb',
  },

  army_guns = {
    'm4',
    'mp5',
    'deagle',
    'rifle',
    'shotgun',
    'smkbomb',
  },
}

function imgui.OnDrawFrame()
  if mainWindowState.v then
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(700, 400), 2)
    imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/2), 2, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Autotaker v'..thisScript()['version'], mainWindowState, imgui.WindowFlags.NoResize)
    imgui.BeginGroup()
      imgui.BeginChild('Left panel', imgui.ImVec2(100, 0), true)
        if imgui.Selectable('Профили', selectedTab == 1) then selectedTab = 1 end
        if imgui.Selectable('Настройки', selectedTab == 2) then selectedTab = 2 end
        if imgui.Selectable('Информация', selectedTab == 3) then selectedTab = 3 end
      imgui.EndChild()
    imgui.EndGroup()

    imgui.SameLine()

    if selectedTab == 1 then
      imgui.BeginGroup()
        imgui.BeginChild('Profiles', imgui.ImVec2(145, -imgui.GetItemsLineHeightWithSpacing() * 4 - imgui.GetStyle().ItemSpacing.y), true)
          for i, v in ipairs(data['profiles']) do
            if imgui.Selectable(data['profiles'][i]['title']..'##'..i, selectedProfile == i, imgui.SelectableFlags.AllowDoubleClick) then
              selectedProfile = i
              if imgui.IsMouseDoubleClicked(0) then
                tempBuffers['title'] = imgui.ImBuffer(data['profiles'][selectedProfile]['title'], 32)
                imgui.OpenPopup('Изменить настройки профиля##'..i)
              end
              data['settings']['selectedProfile'] = i
              typescriptwork.v = data['profiles'][selectedProfile]['typescriptwork']
              saveData()
            end
            if imgui.BeginPopupModal('Изменить настройки профиля##'..i, nil, 64) then
              imgui.InputText('Название', tempBuffers['title'])
              imgui.Separator()
              imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
              if imgui.Button('Готово', imgui.ImVec2(120, 0)) then
                data['profiles'][selectedProfile]          = data['profiles'][selectedProfile]
                data['profiles'][selectedProfile]['title'] = tempBuffers['title'].v
                saveData()
                imgui.CloseCurrentPopup()
              end
              imgui.SameLine()
              if imgui.Button('Отмена', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
                imgui.EndPopup()
              end
          end
        imgui.EndChild()
        if imgui.Button('Добавить', imgui.ImVec2(145/2-5, 0)) then
          tempBuffers['title'] = imgui.ImBuffer('Profile', 32)
          imgui.OpenPopup('Добавление профиля')
        end
        imgui.SameLine()
        if selectedProfile ~= 0 and imgui.Button('Удалить', imgui.ImVec2(145/2-5, 0)) then
          imgui.OpenPopup('Удаление профиля')
        end

        if imgui.BeginPopupModal('Добавление профиля', nil, 64) then
          imgui.InputText('Название', tempBuffers['title'])
          imgui.Separator()
          imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
          if imgui.Button('Готово', imgui.ImVec2(120, 0)) then
            table.insert(data['profiles'], defaultProfile)
            data['profiles'][#data['profiles']]['title'] = tempBuffers['title'].v
            saveData()
            imgui.CloseCurrentPopup()
          end
          imgui.SameLine()
          if imgui.Button('Отмена', imgui.ImVec2(120, 0)) then
            imgui.CloseCurrentPopup()
          end
          imgui.EndPopup()
        end

        if imgui.BeginPopupModal('Удаление профиля', nil, 2) then
          imgui.Text('Удаление профиля приведет к полной потере всех данных.\nЖелаете продолжить?')
          imgui.Separator()
          imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
          if imgui.Button('Да', imgui.ImVec2(120, 0)) then
            table.remove(data['profiles'], selectedProfile)
            selectedProfile = 0
            data['settings']['selectedProfile'] = 0
            saveData()
            imgui.CloseCurrentPopup()
          end
          imgui.SameLine()
          if imgui.Button('Нет', imgui.ImVec2(120, 0)) then
            imgui.CloseCurrentPopup()
          end
          imgui.EndPopup()
        end


        if selectedProfile ~= 0 then
          imgui.Text('Режим работы')
          imgui.PushItemWidth(145)
          if imgui.ListBox('', typescriptwork, {'Police', 'FBI', 'Army'}, imgui.ImInt(3)) then
            data['profiles'][selectedProfile]['typescriptwork'] = typescriptwork.v
            saveData()
          end
          imgui.PopItemWidth()
        end
      imgui.EndGroup()
      imgui.SameLine()
      imgui.BeginGroup()
        imgui.BeginChild('Weapons', imgui.ImVec2(145, 0), true)
          if selectedProfile ~= 0 then
            if typescriptwork.v == 0 then
              for k, v in pairs(lists.police_guns) do
                if imgui.Selectable(names['guns'][v], data['profiles'][selectedProfile]['police_guns'][v]) then
                  data['profiles'][selectedProfile]['police_guns'][v] = not data['profiles'][selectedProfile]['police_guns'][v]
                  saveData()
                end
              end

            elseif typescriptwork.v == 1 then
              for k, v in pairs(lists.fbi_guns) do
                if imgui.Selectable(names['guns'][v], data['profiles'][selectedProfile]['fbi_guns'][v]) then
                  data['profiles'][selectedProfile]['fbi_guns'][v] = not data['profiles'][selectedProfile]['fbi_guns'][v]
                  saveData()
                end
              end

            elseif typescriptwork.v == 2 then
              for k, v in pairs(lists.army_guns) do
                if imgui.Selectable(names['guns'][v], data['profiles'][selectedProfile]['army_guns'][v]) then
                  data['profiles'][selectedProfile]['army_guns'][v] = not data['profiles'][selectedProfile]['army_guns'][v]
                  saveData()
                end
              end
            end
          end
        imgui.EndChild()
      imgui.EndGroup()
      imgui.SameLine()
      imgui.BeginGroup()
        imgui.BeginChild('Items', imgui.ImVec2(0, 0), true)
          if selectedProfile ~= 0 then
            if typescriptwork.v == 0 then
              for k, v in pairs(lists.police_items) do
                if imgui.Selectable(names['items'][v], data['profiles'][selectedProfile]['police_items'][v]) then
                  data['profiles'][selectedProfile]['police_items'][v] = not data['profiles'][selectedProfile]['police_items'][v]
                  saveData()
                end
              end

            elseif typescriptwork.v == 1 then
              for k, v in pairs(lists.fbi_items) do
                if imgui.Selectable(names['items'][v], data['profiles'][selectedProfile]['fbi_items'][v]) then
                  data['profiles'][selectedProfile]['fbi_items'][v] = not data['profiles'][selectedProfile]['fbi_items'][v]
                  saveData()
                end
              end

            elseif typescriptwork.v == 2 then
              for k, v in pairs(lists.army_items) do
                if imgui.Selectable(names['items'][v], data['profiles'][selectedProfile]['army_items'][v]) then
                  data['profiles'][selectedProfile]['army_items'][v] = not data['profiles'][selectedProfile]['army_items'][v]
                  saveData()
                end
              end
            end
          end
        imgui.EndChild()
      imgui.EndGroup()


    elseif selectedTab == 2 then
      imgui.BeginGroup()
        imgui.BeginChild('Settings')
          if imgui.Checkbox('Всегда автоматически проверять обновления', imgui.ImBool(data['settings']['alwaysAutoCheckUpdates'])) then
            data['settings']['alwaysAutoCheckUpdates'] = not data['settings']['alwaysAutoCheckUpdates']
            saveData()
          end
          if imgui.Checkbox('Активно?', imgui.ImBool(data['settings']['active'])) then
            data['settings']['active'] = not data['settings']['active']
            saveData()
          end
        imgui.EndChild()
      imgui.EndGroup()

    elseif selectedTab == 3 then
      imgui.BeginGroup()
        imgui.BeginChild('Information')
          imgui.Text('Название: Autotaker')
          imgui.Text('Автор: Akionka')
          imgui.Text('Версия: '..thisScript()['version_num']..' ('..thisScript()['version']..')')
          imgui.Text('Команды: /autotaker')
          if updatesAvaliable and imgui.Button('Скачать обновление', imgui.ImVec2(150, 0)) then
            update()
            mainWindowState.v = false
          end
          if not updatesAvaliable and imgui.Button('Проверить обновления', imgui.ImVec2(150, 0)) then
            checkUpdates()
          end
          imgui.SameLine()
          if imgui.Button('Группа ВКонтакте', imgui.ImVec2(150, 0)) then os.execute('explorer "https://vk.com/akionkamods"') end
          if imgui.Button('Bug report [VK]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://vk.com/akionka"') end
          imgui.SameLine()
          if imgui.Button('Bug report [Telegram]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://teleg.run/akionka"') end
        imgui.EndChild()
      imgui.EndGroup()
    end

    imgui.End()
  end
end

function get_pickup_model(id, handle)
  return readMemory(id * 20 + 61444 + sampGetPickupPoolPtr(), 4, true)
end

function sampev.onSendPickedUpPickup(id)
  local pickup = sampGetPickupHandleBySampId(id)
  local pickuppoolPtr = sampGetPickupPoolPtr()

  -- Доп. снаряжение
  if get_pickup_model(id, pickup) == 1242 then
    if locked then return false end
    if #orderList ~= 0 then return end
    for k, v in pairs(data['profiles'][selectedProfile][getPrefix() .. '_items']) do
      if v then
        local i = searchForItem(lists[getPrefix() .. '_items'], k)
        table.insert(orderList, i - 1)
      end
    end
  end

  -- Оружейная
  if get_pickup_model(id, pickup) == 2061 then
    if #orderList ~= 0 then return end
    for k, v in pairs(data['profiles'][selectedProfile][getPrefix() .. '_guns']) do
      if v then
        local i = searchForItem(lists[getPrefix() .. '_guns'], k)
        table.insert(orderList, i - 1)
      end
    end
  end
end

function sampev.onShowDialog(id, stytle, title, btn1, btn2, text)
  if (id == 81 or id == 83) and data['settings']['active'] then
    if #orderList == 0 then
      locked = true
      alert('Можете отходить от пикапа. В течение следующих {9932cc}6 секунд{FFFFFF} он будет неактивен')
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
  return {id, stytle, title .. ' | ' .. id, btn1, btn2, text}
end

function applyCustomStyle()
  imgui.SwitchContext()
  local style  = imgui.GetStyle()
  local colors = style.Colors
  local clr    = imgui.Col
  local function ImVec4(color)
    local r = bit.band(bit.rshift(color, 24), 0xFF)
    local g = bit.band(bit.rshift(color, 16), 0xFF)
    local b = bit.band(bit.rshift(color, 8), 0xFF)
    local a = bit.band(color, 0xFF)
    return imgui.ImVec4(r/255, g/255, b/255, a/255)
  end

  style['WindowRounding']      = 10.0
  style['WindowTitleAlign']    = imgui.ImVec2(0.5, 0.5)
  style['ChildWindowRounding'] = 5.0
  style['FrameRounding']       = 5.0
  style['ItemSpacing']         = imgui.ImVec2(5.0, 5.0)
  style['ScrollbarSize']       = 13.0
  style['ScrollbarRounding']   = 5

  colors[clr['Text']]                 = ImVec4(0xFFFFFFFF)
  colors[clr['TextDisabled']]         = ImVec4(0x212121FF)
  colors[clr['WindowBg']]             = ImVec4(0x212121FF)
  colors[clr['ChildWindowBg']]        = ImVec4(0x21212180)
  colors[clr['PopupBg']]              = ImVec4(0x212121FF)
  colors[clr['Border']]               = ImVec4(0xFFFFFF10)
  colors[clr['BorderShadow']]         = ImVec4(0x21212100)
  colors[clr['FrameBg']]              = ImVec4(0xC3E88D90)
  colors[clr['FrameBgHovered']]       = ImVec4(0xC3E88DFF)
  colors[clr['FrameBgActive']]        = ImVec4(0x61616150)
  colors[clr['TitleBg']]              = ImVec4(0x212121FF)
  colors[clr['TitleBgActive']]        = ImVec4(0x212121FF)
  colors[clr['TitleBgCollapsed']]     = ImVec4(0x212121FF)
  colors[clr['MenuBarBg']]            = ImVec4(0x21212180)
  colors[clr['ScrollbarBg']]          = ImVec4(0x212121FF)
  colors[clr['ScrollbarGrab']]        = ImVec4(0xEEFFFF20)
  colors[clr['ScrollbarGrabHovered']] = ImVec4(0xEEFFFF10)
  colors[clr['ScrollbarGrabActive']]  = ImVec4(0x80CBC4FF)
  colors[clr['ComboBg']]              = colors[clr['PopupBg']]
  colors[clr['CheckMark']]            = ImVec4(0x212121FF)
  colors[clr['SliderGrab']]           = ImVec4(0x212121FF)
  colors[clr['SliderGrabActive']]     = ImVec4(0x80CBC4FF)
  colors[clr['Button']]               = ImVec4(0xC3E88D90)
  colors[clr['ButtonHovered']]        = ImVec4(0xC3E88DFF)
  colors[clr['ButtonActive']]         = ImVec4(0x61616150)
  colors[clr['Header']]               = ImVec4(0x151515FF)
  colors[clr['HeaderHovered']]        = ImVec4(0x252525FF)
  colors[clr['HeaderActive']]         = ImVec4(0x303030FF)
  colors[clr['Separator']]            = colors[clr['Border']]
  colors[clr['SeparatorHovered']]     = ImVec4(0x212121FF)
  colors[clr['SeparatorActive']]      = ImVec4(0x212121FF)
  colors[clr['ResizeGrip']]           = ImVec4(0x212121FF)
  colors[clr['ResizeGripHovered']]    = ImVec4(0x212121FF)
  colors[clr['ResizeGripActive']]     = ImVec4(0x212121FF)
  colors[clr['CloseButton']]          = ImVec4(0x212121FF)
  colors[clr['CloseButtonHovered']]   = ImVec4(0xD41223FF)
  colors[clr['CloseButtonActive']]    = ImVec4(0xD41223FF)
  colors[clr['PlotLines']]            = ImVec4(0x212121FF)
  colors[clr['PlotLinesHovered']]     = ImVec4(0x212121FF)
  colors[clr['PlotHistogram']]        = ImVec4(0x212121FF)
  colors[clr['PlotHistogramHovered']] = ImVec4(0x212121FF)
  colors[clr['TextSelectedBg']]       = ImVec4(0x212121FF)
  colors[clr['ModalWindowDarkening']] = ImVec4(0x21212180)
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
  if not doesDirectoryExist(getWorkingDirectory()..'\\config') then createDirectory(getWorkingDirectory()..'\\config') end

  applyCustomStyle()
  loadData()

  print(u8:decode('{FFFFFF}Скрипт успешно загружен.'))
  print(u8:decode('{FFFFFF}Версия: {9932cc}'..thisScript()['version']..'{FFFFFF}. Автор: {9932cc}Akionka{FFFFFF}.'))
  print(u8:decode('{FFFFFF}Приятного использования! :)'))

  if data['settings']['alwaysAutoCheckUpdates'] then
    checkUpdates()
  end

  sampRegisterChatCommand('autotaker', function()
    mainWindowState.v = not mainWindowState.v
  end)

  while true do
    wait(0)
    imgui.Process = mainWindowState.v
  end
end

function checkUpdates()
  local fpath = os.tmpname()
  if doesFileExist(fpath) then os.remove(fpath) end
  downloadUrlToFile('https://api.github.com/repos/akionka/'..thisScript()['name']..'/releases', fpath, function(_, status, _, _)
    if status == 58 then
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'r')
        if f then
          local info = decodeJson(f: read('*a'))
          f:close()
          os.remove(fpath)
          if v(info[1]['tag_name']) > v(thisScript()['version']) then
            updatesAvaliable = true
            lastTagAvaliable = info[1]['tag_name']
            alert('Найдено объявление. Текущая версия: {9932cc}'..thisScript()['version']..'{FFFFFF}, новая версия: {9932cc}'..info[1]['tag_name']..'{FFFFFF}')
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

function update()
  downloadUrlToFile('https://github.com/akionka/'..thisScript()['name']..'/releases/download/'..lastTagAvaliable..'/autotaker.lua', thisScript()['path'], function(_, status, _, _)
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

  active.v = data['settings']['active'] or false
  selectedProfile  = data['settings']['selectedProfile'] or 1

  if selectedProfile == 0 then return end
  if selectedProfile < 0 or selectedProfile > #data['profiles'] then
    selectedProfile = 0
    return
  end
  typescriptwork.v = data['profiles'][selectedProfile]['typescriptwork'] or 0
end

function saveData()
  local configFile = io.open(getWorkingDirectory()..'\\config\\autotaker.json', 'w+')
  configFile:write(encodeJson(data))
  configFile:close()
end

function alert(text)
  local prefix = 'Autotaker'
  sampAddChatMessage(u8:decode('[' .. prefix .. ']: ' .. text), -1)
end

function searchForItem(table, item)
  for i, v in ipairs(table) do
    if v == item then return i end
  end
end

function getPrefix()
  return prefixes[data['profiles'][selectedProfile]['typescriptwork'] + 1]
end