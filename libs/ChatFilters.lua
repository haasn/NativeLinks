-- gsub with the string flipped to the third position
gsub_ = lam (3, function (p, r, s, n) return
    string.gsub (s, p, lowerFun (r), n) end)

-- Promote a pure function to a chat filter
makeChatFilter = lam (4, function (f, s, e, m, ...) return
  false, f (m), ... end)

-- For debugging purposes, an easier way to inspect links
inspect = lam (0, print) .. take (1) .. gsub_ ("|", "||")