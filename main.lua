local WidgetContainer = require("ui/widget/container/widgetcontainer")
local GitHandler = require("git_handler")
local UI = require("ui_menu")
local DataStorage = require("datastorage")
local logger = require("logger")
local _ = require("gettext")

local GitSync = WidgetContainer:extend{
    name = "GitSync",
    settings = {},
    -- Pastas a serem sincronizadas (Exemplo: settings e estatísticas)
    sync_paths = {
        DataStorage:getSettingsDir(),
        DataStorage:getFullDataDir() .. "/statistics.sqlite3",
    }
}

function GitSync:init()
    self:loadSettings()
    self:registerEvents()
    self.ui = UI
end

function GitSync:loadSettings()
    -- Carrega de um arquivo .lua no diretório do plugin
    local settings_file = DataStorage:getSettingsDir() .. "/gitsync_conf.lua"
    local ok, config = pcall(dofile, settings_file)
    self.settings = ok and config or { 
        repo_url = "", 
        ssh_key = "", 
        auto_sync_on_close = true,
        commit_template = "KOReader Sync [%os]"
    }
end

function GitSync:saveSettings()
    local f = io.open(DataStorage:getSettingsDir() .. "/gitsync_conf.lua", "w")
    if f then
        f:write("return " .. require("util").tableToString(self.settings))
        f:close()
    end
end

function GitSync:registerEvents()
    -- Gatilho ao fechar um livro
    self.onReaderExit = function()
        if self.settings.auto_sync_on_close then
            self:doSync(false)
        end
    end
end

function GitSync:doSync(show_message)
    local repo_resolved = GitHandler:resolveURL(self.settings.repo_url)
    local repo_local_path = DataStorage:getSettingsDir() -- No Git, o root é o diretório de settings
    
    local params = {
        repo_path = repo_local_path,
        ssh_key = self.settings.ssh_key,
        commit_template = self.settings.commit_template:gsub("%%os", os.getenv("OS") or "eReader"),
    }

    if show_message then
        local UIMessage = require("ui/widget/uimessage")
        self.msg = UIMessage:new{ text = _("Sincronizando com Git...") }
        self.msg:show()
    end

    -- Execução assíncrona simples via scheduleTask para não travar a UI
    require("ui/uimanager"):scheduleTask(function()
        local out = GitHandler:sync(params)
        if show_message and self.msg then
            self.msg:onClose()
            UIMessage:new{ text = _("Sincronização Concluída:\n") .. out, timeout = 3 }:show()
        end
    end)
end

function GitSync:addToMainMenu(menu_items)
    menu_items.gitsync = {
        text = _("Git Sync"),
        sub_item_table = self.ui:showConfig(self),
    }
end

return GitSync