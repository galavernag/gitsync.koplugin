local _ = require("gettext")
local logger = require("logger")

local GitHandler = {}

function GitHandler:resolveURL(url)
    if url:find("^github:") then
        return url:gsub("^github:(.+)", "https://github.com/%1.git")
    elseif url:find("^gitlab:") then
        return url:gsub("^gitlab:(.+)", "https://gitlab.com/%1.git")
    end
    return url
end

function GitHandler:execute(cmd, repo_path, ssh_key)
    local env = ""
    if ssh_key and ssh_key ~= "" then
        -- Define o comando SSH para usar a chave específica
        env = string.format("GIT_SSH_COMMAND='ssh -i %s -o StrictHostKeyChecking=no' ", ssh_key)
    end
    
    local full_cmd = string.format("cd %s && %s%s 2>&1", repo_path, env, cmd)
    local handle = io.popen(full_cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

function GitHandler:sync(params)
    -- 1. Add
    self:execute("git add .", params.repo_path)
    -- 2. Commit
    local msg = params.commit_template or "Sync from KOReader: " .. os.date("%Y-%m-%d %H:%M")
    self:execute(string.format("git commit -m '%s'", msg), params.repo_path)
    -- 3. Pull (Rebase para evitar merges sujos em e-readers)
    self:execute("git pull --rebase", params.repo_path, params.ssh_key)
    -- 4. Push
    return self:execute("git push", params.repo_path, params.ssh_key)
end

return GitHandler