local _ = require("gettext")

return {
    name = "gitsync",
    fullname = _("Git Sync"),
    description = _("Sincroniza configurações, estatísticas de leitura e metadados usando Git como backend. Suporta atalhos para GitHub/GitLab e autenticação via chave SSH."),
    author = "Guilherme Galaverna",
    version = "1.0.0",
    category = "network",
    enabled = false,
}
