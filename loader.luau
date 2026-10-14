-- Auto-execute loader: always runs the newest 1recloading.luau on the branch.
-- It asks GitHub for the branch's latest commit and loads the file pinned to that commit, so the
-- raw-file CDN cache (a few minutes after each push) can never hand you an old build.
-- Put your Config above the loadstring line if you use one (the script keeps a pre-set Config).

local REPO = "darylloudi/tuman"
local BRANCH = "claude/eloquent-feynman-i34o49"
local FILE = "1recloading.luau"

local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/" .. FILE .. "?t=" .. tostring(os.time())

local ok, sha = pcall(function()
	local body = game:HttpGet("https://api.github.com/repos/" .. REPO .. "/commits/" .. BRANCH)
	return HttpService:JSONDecode(body).sha
end)
if ok and type(sha) == "string" and #sha >= 7 then
	url = "https://raw.githubusercontent.com/" .. REPO .. "/" .. sha .. "/" .. FILE
	print("[loader] running " .. FILE .. " @ " .. sha:sub(1, 7))
else
	print("[loader] commit lookup failed, using the branch file")
end

loadstring(game:HttpGet(url))()
