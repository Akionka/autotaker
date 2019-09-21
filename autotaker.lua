script_name('AutoTaker')
script_author('akionka')
script_version('1.5.4')
script_version_number(13)
script_moonloader(27)

require 'deps' {
  'fyp:samp-lua',
  'fyp:moon-imgui',
  'kikito:semver'
}

local sampev           = require 'lib.samp.events'
local encoding         = require 'encoding'
local imgui            = require 'imgui'
local v                = require 'semver'


local updatesAvaliable = false
local lastTagAvaliable = '1.0'

encoding.default       = 'cp1251'
local u8               = encoding.UTF8

local prefix           = 'Autotaker'
local close_next       = false
local orderList        = {}
local locked           = false
encoding.default       = 'cp1251'
u8 = encoding.UTF8

local defaultProfile = {
  title = 'Profile1',
  typescriptwork = 0, --[[
    0 - PD,
    1 - FBI,
    2 - Army
  ]]

  police_items = {
    false, -- Бронежилет
    false, -- Прибор ночного видения
    false, -- Кобура
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
    false, -- Кобура
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
    false, -- Кобура
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

local names = {
  police_items = {
    'Бронежилет',
    'Прибор ночного видения',
    'Кобура',
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
    'Кобура',
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
    'Кобура',
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
              for k, v in pairs(data['profiles'][selectedProfile]['police_guns']) do
                if imgui.Selectable(names['police_guns'][k], data['profiles'][selectedProfile]['police_guns'][k]) then
                  data['profiles'][selectedProfile]['police_guns'][k] = not data['profiles'][selectedProfile]['police_guns'][k]
                  saveData()
                end
              end

            elseif typescriptwork.v == 1 then
              for k, v in pairs(data['profiles'][selectedProfile]['fbi_guns']) do
                if imgui.Selectable(names['fbi_guns'][k], data['profiles'][selectedProfile]['fbi_guns'][k]) then
                  data['profiles'][selectedProfile]['fbi_guns'][k] = not data['profiles'][selectedProfile]['fbi_guns'][k]
                  saveData()
                end
              end

            elseif typescriptwork.v == 2 then
              for k, v in pairs(data['profiles'][selectedProfile]['army_guns']) do
                if imgui.Selectable(names['army_guns'][k], data['profiles'][selectedProfile]['army_guns'][k]) then
                  data['profiles'][selectedProfile]['army_guns'][k] = not data['profiles'][selectedProfile]['army_guns'][k]
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
              for k, v in pairs(data['profiles'][selectedProfile]['police_items']) do
                if imgui.Selectable(names['police_items'][k], data['profiles'][selectedProfile]['police_items'][k]) then
                  data['profiles'][selectedProfile]['police_items'][k] = not data['profiles'][selectedProfile]['police_items'][k]
                  saveData()
                end
              end

            elseif typescriptwork.v == 1 then
              for k, v in pairs(data['profiles'][selectedProfile]['fbi_items']) do
                if imgui.Selectable(names['fbi_items'][k], data['profiles'][selectedProfile]['fbi_items'][k]) then
                  data['profiles'][selectedProfile]['fbi_items'][k] = not data['profiles'][selectedProfile]['fbi_items'][k]
                  saveData()
                end
              end

            elseif typescriptwork.v == 2 then
              for k, v in pairs(data['profiles'][selectedProfile]['army_items']) do
                if imgui.Selectable(names['army_items'][k], data['profiles'][selectedProfile]['army_items'][k]) then
                  data['profiles'][selectedProfile]['army_items'][k] = not data['profiles'][selectedProfile]['army_items'][k]
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
  local pickuppoolPtr = sampGetPickupPoolPtr(id)


  -- Доп. снаряжение
  if get_pickup_model(id, pickup) == 1242 then
    if locked then return false end
    if #orderList == 0 then
      if data['profiles'][selectedProfile]['typescriptwork'] == 0 then
        for k, v in pairs(data['profiles'][selectedProfile]['police_items']) do
          if v then
            table.insert(orderList, k)
          end
        end
      end
      if data['profiles'][selectedProfile]['typescriptwork'] == 1 then
        for k, v in pairs(data['profiles'][selectedProfile]['fbi_items']) do
          if v then
            table.insert(orderList, k)
          end
        end
      end
      if data['profiles'][selectedProfile]['typescriptwork'] == 2 then
        for k, v in pairs(data['profiles'][selectedProfile]['army_items']) do
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
      if data['profiles'][selectedProfile]['typescriptwork'] == 0 then
        for k, v in pairs(data['profiles'][selectedProfile]['police_guns']) do
          if v then
            table.insert(orderList, k - 1)
          end
        end
      end
      if data['profiles'][selectedProfile]['typescriptwork'] == 1 then
        for k, v in pairs(data['profiles'][selectedProfile]['fbi_guns']) do
          if v then
            table.insert(orderList, k - 1)
          end
        end
      end
      if data['profiles'][selectedProfile]['typescriptwork'] == 2 then
        for k, v in pairs(data['profiles'][selectedProfile]['army_guns']) do
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

  -- style.FrameBorderSize = 1.0
  style.WindowTitleAlign    = imgui.ImVec2(0.5, 0.5)
  style.FramePadding      = imgui.ImVec2(4.0, 2.0)
  style.ItemSpacing       = imgui.ImVec2(8.0, 2.0)
  -- style.WindowBorderSize  = 1.0
  -- style.TabBorderSize     = 1.0
  style.WindowRounding    = 1.0
  -- style.ChildRounding     = 1.0
  style.FrameRounding     = 1.0
  style.ScrollbarRounding = 1.0
  style.GrabRounding      = 1.0
  -- style.TabRounding       = 1.0

  colors[clr.Text]                  = ImVec4(1.00, 1.00, 1.00, 0.95)
  colors[clr.TextDisabled]          = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg]              = ImVec4(0.13, 0.12, 0.12, 1.00)
  -- colors[clr.ChildBg]               = ImVec4(1.00, 1.00, 1.00, 0.00)
  colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.05, 0.94)
  colors[clr.Border]                = ImVec4(0.53, 0.53, 0.53, 0.46)
  colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg]               = ImVec4(0.00, 0.00, 0.00, 0.85)
  colors[clr.FrameBgHovered]        = ImVec4(0.22, 0.22, 0.22, 0.40)
  colors[clr.FrameBgActive]         = ImVec4(0.16, 0.16, 0.16, 0.53)
  colors[clr.TitleBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgActive]         = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgCollapsed]      = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.MenuBarBg]             = ImVec4(0.12, 0.12, 0.12, 1.00)
  colors[clr.ScrollbarBg]           = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab]         = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive]   = ImVec4(0.48, 0.48, 0.48, 1.00)
  colors[clr.CheckMark]             = ImVec4(0.79, 0.79, 0.79, 1.00)
  colors[clr.SliderGrab]            = ImVec4(0.48, 0.47, 0.47, 0.91)
  colors[clr.SliderGrabActive]      = ImVec4(0.56, 0.55, 0.55, 0.62)
  colors[clr.Button]                = ImVec4(0.50, 0.50, 0.50, 0.63)
  colors[clr.ButtonHovered]         = ImVec4(0.67, 0.67, 0.68, 0.63)
  colors[clr.ButtonActive]          = ImVec4(0.26, 0.26, 0.26, 0.63)
  colors[clr.Header]                = ImVec4(0.54, 0.54, 0.54, 0.58)
  colors[clr.HeaderHovered]         = ImVec4(0.64, 0.65, 0.65, 0.80)
  colors[clr.HeaderActive]          = ImVec4(0.25, 0.25, 0.25, 0.80)
  colors[clr.Separator]             = ImVec4(0.58, 0.58, 0.58, 0.50)
  colors[clr.SeparatorHovered]      = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.SeparatorActive]       = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.ResizeGrip]            = ImVec4(0.87, 0.87, 0.87, 0.53)
  colors[clr.ResizeGripHovered]     = ImVec4(0.87, 0.87, 0.87, 0.74)
  colors[clr.ResizeGripActive]      = ImVec4(0.87, 0.87, 0.87, 0.74)
  -- colors[clr.Tab]                   = ImVec4(0.01, 0.01, 0.01, 0.86)
  -- colors[clr.TabHovered]            = ImVec4(0.29, 0.29, 0.29, 1.00)
  -- colors[clr.TabActive]             = ImVec4(0.31, 0.31, 0.31, 1.00)
  -- colors[clr.TabUnfocused]          = ImVec4(0.02, 0.02, 0.02, 1.00)
  -- colors[clr.TabUnfocusedActive]    = ImVec4(0.19, 0.19, 0.19, 1.00)
  -- colors[clr.DockingPreview]        = ImVec4(0.38, 0.48, 0.60, 1.00)
  -- colors[clr.DockingEmptyBg]        = ImVec4(0.20, 0.20, 0.20, 1.00)
  colors[clr.PlotLines]             = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered]      = ImVec4(0.68, 0.68, 0.68, 1.00)
  colors[clr.PlotHistogram]         = ImVec4(0.90, 0.77, 0.33, 1.00)
  colors[clr.PlotHistogramHovered]  = ImVec4(0.87, 0.55, 0.08, 1.00)
  colors[clr.TextSelectedBg]        = ImVec4(0.47, 0.60, 0.76, 0.47)
  -- colors[clr.DragDropTarget]        = ImVec4(0.58, 0.58, 0.58, 0.90)
  -- colors[clr.NavHighlight]          = ImVec4(0.60, 0.60, 0.60, 1.00)
  -- colors[clr.NavWindowingHighlight] = ImVec4(1.00, 1.00, 1.00, 0.70)
  -- colors[clr.NavWindowingDimBg]     = ImVec4(0.80, 0.80, 0.80, 0.20)
  -- colors[clr.ModalWindowDimBg]      = ImVec4(0.80, 0.80, 0.80, 0.35)
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
            alert('Найдено объявление. Текущая версия: {9932cc}'..thisScript()['version']..'{FFFFFF}, новая версия: {9932cc}'..info[0]['version']..'{FFFFFF}')
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

  active.v         = data['settings']['active'] or false
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
  sampAddChatMessage(u8:decode('['..prefix..']: '..text), -1)
end