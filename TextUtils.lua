local function unseparate(string)
    return string:gsub("[_%-%.%:]+", " ")
end

local function uncamelize(string)
    return (string:gsub("%u", " %0"))
end

local function trimString(input)
    return input:gsub("^%s*(.-)%s*$", "%1")
end

--

TextUtils = {}

function TextUtils.currentSelection()
    local elem = hs.uielement.focusedElement()
    local sel = nil

    if elem then
        sel = elem:selectedText()
    end
    if (not sel) or (sel == "") then
        hs.eventtap.keyStroke({"cmd"}, "c")
        hs.timer.usleep(20000)
        sel = hs.pasteboard.getContents()
    end

    return (sel or "")
end

function TextUtils.toNoCase(string)
    local hasSpace = string:find("%s")
    local hasSeparator = not not string:find("([_%-%.%:])")
    local hasCamel = not not string:find("^%u?%l+%u%l*%u?%l*")

    if hasSpace then
        str =  string:lower()
    elseif hasSeparator then
        str =  (unseparate(string) or string):lower()
    elseif hasCamel then
        str =  uncamelize(string):lower()
    else
        str = string:lower()
    end

    return trimString(str)
end

function TextUtils.toSnakeCase(string)
    local str = TextUtils.toNoCase(string):gsub("%s", "_")

    str = str:gsub("^[-_]+", ""):gsub("[-_]+$", "")

    return str
end

function TextUtils.toScreamingSnakeCase(string)
    local str = TextUtils.toNoCase(string):gsub("%s", "_"):upper()

    str = str:gsub("^[-_]+", ""):gsub("[-_]+$", "")

    return str
end

function TextUtils.toKebabCase(string)
    local str = TextUtils.toNoCase(string):gsub("%s", "-")

    str = str:gsub("^[-_]+", ""):gsub("[-_]+$", "")

    return str
end

function TextUtils.toSentenceCase(string)
    local str = TextUtils.toNoCase(string):gsub("^%l", string.upper, 1)

    return str
end

function TextUtils.toLowerCase(string)
    return string:lower()
end

function TextUtils.toUpperCase(string)
    local str = string:upper()

    return str
end

function TextUtils.toCamelCase(string)
    local str = TextUtils.toNoCase(string)

    str = str:gsub("(%s)(%w)", function(s, c)
        return c:upper()
    end)

    str = str:gsub("^%a", string.lower)

    return str
end

function TextUtils.toPascalCase(string)
    local str = TextUtils.toNoCase(string)

    str = str:gsub("(%s)(%w)", function(s, c)
        return c:upper()
    end)

    str = str:gsub("^%l", string.upper)

    return str
end

function TextUtils.toTitleCase(str, options)
    local stopwords = "a an and at but by for in nor of on or so the to up yet"
    local defaults = hs.fnutils.split(stopwords, " ")
    local opts = options or {}
    local stop = opts.stopwords or defaults
    local result = {}

    str = TextUtils.toNoCase(str)

    if not str or str == "" then
        return ""
    end

    local words = hs.fnutils.split(str, ' ')
    result = hs.fnutils.imap(words, function(word)
        if hs.fnutils.contains(stop, word:lower()) then
            return word:lower()
        else
            return word:gsub("^(%w)", string.upper, 1)
        end
    end)

    return (table.concat(result, ' '):gsub("^%l", string.upper, 1))
end

function TextUtils.markdownToSlack(text)
    -- Replace ** with * for bold
    text = text:gsub("%*%*([^%*]+)%*%*", "*%1*")

    -- Replace > with ` for blockquotes
    text = text:gsub("> (.-)\n", "`%1`\n")

    -- Replace - [ ] with • for lists
    text = text:gsub("- %[%s%](.-)\n", "• %1\n")

    -- Replace - [x] with • for lists
    text = text:gsub("- %[[xX]%](.-)\n", "• %1\n")

    -- replace h3 headings with bold
    text = text:gsub("### ([^\n]+)\n", "*%1*\n")

    -- replace h2 headings with bold
    text = text:gsub("## ([^\n]+)\n", "*%1*\n")

    -- replace h1 headings with bold
    text = text:gsub("# ([^\n]+)\n", "*%1*\n")

    -- hs.alert('wtf')

    return text
end

return TextUtils
