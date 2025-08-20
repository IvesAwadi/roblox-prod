-- // Core //
Key = "" -- do not make this local
local fRequest = request or http_request or syn_request
local loadstring = loadstring

-- // Services //
local cloneref = cloneref or function(service) return service end  
local Players = cloneref(game:GetService("Players"))

local function e6a3(reason)
    local player = Players.LocalPlayer
    player:Kick(reason)
end

local function buildGithubUrl(repo, branch, path)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s", repo, branch, path)
end

local function loadFromGithub(repo, branch, src_path)
    local url = buildGithubUrl(repo, branch, src_path)
    local response = fRequest({Url = url, Method = "GET"})
    if not response then
        return nil, "no_response", url
    end

    if response.StatusCode ~= 200 then
        return nil, "http_error: " .. tostring(response.StatusCode), url
    end

    if not response.Body or response.Body == "" then
        return nil, "empty_src", url
    end

    local fn, err = loadstring(response.Body)
    if not fn then
        return nil, "compile_error: " .. tostring(err), url
    end

    local ok, result = pcall(fn)
    if not ok then
        return nil, "script_error: " .. tostring(result), url
    end

    return true, response.Body, url
end

local result, body, url = loadFromGithub("IvesAwadi/roblox-prod", "main", "Saber/saber.lua")
if not result then
    e6a3("Failed to retrieve source\nReason: " .. tostring(body) .. "\nURL: " .. tostring(url))
end
