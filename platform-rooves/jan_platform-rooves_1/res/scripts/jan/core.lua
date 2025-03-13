local core = {}

--- Returns the first true value of pred(x) for any x in coll. 
-- Returns false if none of the items in coll return true for pred(item). 
---@param coll table 
---@param pred function 
---@return boolean
function core.Some(coll, pred)
    for i=1, #coll do
        if pred(coll[i]) then
            return true
        end
    end
    return false
end

--- Returns the first false value of pred(x) for any x in coll. 
-- Returns true if all the items in coll return true for pred(item). 
---@param coll table 
---@param pred function 
---@return boolean
function core.Every(coll, pred)
    for i=1, #coll do
        if not pred(coll[i]) then
            return false
        end
    end
    return true
end

--- Returns false if pred(x) is true for any x in coll.
-- Returns true if none of the items in coll return true for pred(item). 
---@param coll table 
---@param pred function 
---@return boolean
function core.NotAny(coll, pred)
    for i=1, #coll do
        if pred(coll[i]) then
            return false
        end
    end
    return true
end

--- Returns a new collection of the items in coll for which pred(item) returns true.
---@param coll table
---@param pred function
---@return table
function core.Filter(coll, pred)
    local result = {}
    for i=1, #coll do
        if(pred(coll[i])) then
            result[#result+1] = coll[i]
        end
    end
    return result
end

--- Returns a new collection of the result of applying f to each item in coll.
---@param coll table
---@param f function
---@return table
function core.Map(coll, f)
    local result = {}
    for i=1, #coll do
        result[i] = f(coll[i])
    end
    return result
end

--- Appends x to the end of coll.
-- This is a mutable operation and modifies supplied coll.
---@param coll table
---@param x function
---@return void
function core.Add(coll, x)
    coll[#coll+1] = x
end

return core