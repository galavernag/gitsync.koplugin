local Dispatcher = require("dispatcher")
local InputDialog = require("ui/widget/inputdialog")
local UIMessage = require("ui/widget/uimessage")
local MultiConfirmBox = require("ui/widget/multiconfirmbox")
local _ = require("gettext")

local GitSyncUI = {}

function GitSyncUI:showConfig(plugin)
    local menu_items = {
        {
            text = _("Configurar Repositório"),
            callback = function() self:inputRepo(plugin) end,
        },
        {
            text = _("Caminho da Chave SSH"),
            callback = function() self:inputSSH(plugin) end,
        },
        {
            text = _("Sincronizar Agora"),
            callback = function() plugin:doSync(true) end,
        }
    }
    -- Adicionar ao menu principal do KOReader
    return menu_items
end

function GitSyncUI:inputRepo(plugin)
    local dialog
    dialog = InputDialog:new({
        title = _("URL do Repositório (github:user/repo)"),
        input = plugin.settings.repo_url or "",
        buttons = {
            {
                text = _("Salvar"),
                callback = function()
                    local val = dialog:getInputValue()
                    plugin.settings.repo_url = val
                    plugin:saveSettings()
                end,
            },
        },
    })
    dialog:show()
end

function GitSyncUI:inputSSH(plugin)
    -- Similar ao inputRepo, mas para o path da chave privada
end

return GitSyncUI