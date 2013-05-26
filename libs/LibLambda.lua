-- Appending two simple tables together
local function append (x_, y)
  local x = {unpack (x_)}
  for _,v in pairs (y) do x[#x+1] = v end
  return x end

-- Function composition
local comp = function (f, g) return
  lam ( type(g)=="function" and 0 or g.n
      , function (...) return f (g (...)) end) end

-- Possibly partial function application
local app = function (f, ...)
  local xs = {...}
  local n_ = f.n - #xs
  if n_ <= 0
    -- Directly call the underlying function for saturated applications
    then return f.f (...)
    -- Otherwise, capture a closure
    else return lam (n_, function (...) return
                           f.f (unpack (append (xs, {...}))) end) end end

-- Metawrapper for functions that allows composition and curried application,
-- parameter ‘n’ represents the minimum arity. Note that ‘nil’ parameters are
-- disregarded when applying, so be sure to set the arity to 0 if the argument
-- being nil is a possibility (or use bot instead).
lam = function (n, f) return
  setmetatable ({n=n, f=f}, { __concat = comp, __call = app }) end

-- Some basic functions
id = lam (0, function (...) return ... end)
const = lam (2, function (x, y) return x end)
flip = lam (3, function (f, x, y, ...) return f (y, x, ...) end)

-- Various utility functions that might come in handy

-- Takes a lambda (or function) and returns an actual function, for interop
-- with impure code
lowerFun = lam (1, function (f) return
  type (f) == "table" and f.f or f end)

-- First-class bottom
bot = setmetatable ({__bot = true},
        { __call = const (bot)
        , __eq   = function (x,y) return x.__bot and y.__bot end })

-- Sanity-checking a function, replacing it by const bot if invalid
safely = lam (0, function (f) return exists (f) or const (bot) end)

-- Assert a value to exist (ie. not bot), returns nil (not bot) otherwise
exists = lam (0, function (x) if (x == bot)
                                then return nil
                                else return x end end)

-- Version of ‘id’ which prints its arguments as a side-effect
trace = lam (1, function (...) print (...); return ... end)

-- Concatenate two or more strings, using a given separator
concatWith = lam (3, function (s, ...) return table.concat ({...}, s) end)
concat = concatWith ""

-- Split a string on a certain pattern
splitOn = lam (2, strsplit)

-- Try two functions, falling back on failure
try = lam (3, function (f, g, x) return
  exists (f (x)) or g (x) end)

-- These functions operate on the (co)domains of functions as if they were
-- lists, with individual positions as their elements

-- Drops a number of positions
drop = lam (2, function (n, ...)
  local t = {...}
  while n > 0 do table.remove (t, 1); n = n - 1 end
  return unpack (t) end)

-- Takes a number of positions
take = lam (2, function (n, ...)
  local t = {...}
  while #t > n do table.remove (t); end
  return unpack (t) end)

-- Singles out a certain position
pos = lam (1, function (n) return take (1) .. drop (n) end)