-- Scrape a name from an ingame tooltip. Doesn't always work
scrape_ = setmetatable ({}, { __index = function (t,l)
  GameTooltip:SetOwner (UIParent, "ANCHOR_NONE")
  GameTooltip:SetHyperlink (l)
  t[l] = GameTooltipTextLeft1:GetText ()
  GameTooltip:Hide ()
  return t[l] end })
scrape = lam (1, function (l) return scrape_[l] end)

-- Returns an appropriate function for looking up ID names according to type
local prefix = concatWith ":"
local getName =
  { achievement = drop (1) .. GetAchievementInfo .. take (1)
  , battlepet = C_PetJournal.GetPetInfoBySpeciesID
  , enchant = scrape .. prefix "enchant"
  -- , encounter = trace .. EJ_GetEncounterInfo .. pos (1)
  , instancelock = GetMapNameByID .. pos (2)
  , item = GetItemInfo
  , journal = lam (2, function (t, i) return
       t == 0 and EJ_GetInstanceInfo (i)
    or t == 1 and EJ_GetEncounterInfo (i)
    or t == 2 and EJ_GetSectionInfo (i) end)
  , quest = scrape .. prefix "quest"
  , spell = GetSpellInfo
  , talent = scrape .. prefix "talent"
  , trade = GetSpellInfo .. pos (1)
  }

-- Regular expression for matching some link along with its type, data,
-- and displayed text
local linkRegex = "|H([^:]+):([^|]+)|h%[([^%]]+)%]|h"

-- Translate a single link, parameters are as captured by the regex
local translateLink = lam (3, function (t, d, n)
  r = (exists .. safely (getName [t]) .. splitOn ":") (d)
  if type (r) == "table" then print ("warning:", n, r) end
  return
  "|H" .. t .. ":" .. d .. "|h[" ..
    (type (r) == "string" and r or n) .. "]|h" end)

-- Hook to translate all links
local filter = makeChatFilter (gsub_ (linkRegex, translateLink))

-- Affected event types
local events =
  { "CHAT_MSG_CHANNEL", "CHAT_MSG_DND", "CHAT_MSG_EMOTE"
  , "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY"
  , "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER"
  , "CHAT_MSG_RAID_WARNING", "CHAT_MSG_SAY", "CHAT_MSG_WHISPER", "CHAT_MSG_YELL"
  }

for _,e in pairs (events) do ChatFrame_AddMessageEventFilter (e, filter) end