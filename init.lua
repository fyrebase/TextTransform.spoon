local obj = {}
obj.__index = obj

obj.name = "TextTransform"
obj.version = "0.1"
obj.author = "Kirk Bentley <kirk@fyrebase.com>"
obj.jiraURL = ""

dofile(hs.spoons.resourcePath("TextUtils.lua"))

local menuItems = {}

-- ------------------------------------
-- Default Transform Context Menu Items
-- ------------------------------------

local stringTransformFunctions = {{
    title = "Title Case",
    fn = TextUtils.toTitleCase
}, {
    title = "Sentence case",
    fn = TextUtils.toSentenceCase
}, {
    title = "lower case",
    fn = TextUtils.toLowerCase
}, {
    title = "UPPER CASE",
    fn = TextUtils.toUpperCase
}}

-- ------------------------------------
-- Coding Transform Context Menu Items
-- ------------------------------------

local stringCodeTransformFunctions = {{
    title = "-"
}, {
    title = "camelCase",
    fn = TextUtils.toCamelCase
}, {
    title = "PascalCase",
    fn = TextUtils.toPascalCase
}, {
    title = "kebab-case",
    fn = TextUtils.toKebabCase
}, {
    title = "SCREAMING_SNAKE_CASE",
    fn = TextUtils.toScreamingSnakeCase
}, {
    title = "snake_case",
    fn = TextUtils.toSnakeCase
}}

-- ------------------------------------
-- String Transform Handler
-- ------------------------------------

local function stringTransform(fn)
    local clipboardContentString = TextUtils.currentSelection()

    hs.pasteboard.setContents(fn(clipboardContentString))
    hs.eventtap.keyStroke({"cmd"}, "v")
end

-- ------------------------------------
-- Add Provided Transforms to Menu Items
-- ------------------------------------

function addTransforms(menu, functions)
    for i, transformFunction in ipairs(functions) do
        menu[#menu + 1] = {
            title = transformFunction.title,
            fn = function()
                stringTransform(transformFunction.fn)
            end
        }
    end
end

addTransforms(menuItems, stringTransformFunctions)

local menu = hs.menubar.new()
menu:setTitle("Ω")
menu:removeFromMenuBar()
menu:setMenu(menuItems)

-- ------------------------------------
-- Add Code Transform to Menu
-- ------------------------------------

function obj:addCodeTransforms()
    addTransforms(menuItems, stringCodeTransformFunctions)
    menu:setMenu(menuItems)
end

-- ------------------------------------
-- Show Transform Context Menu
-- ------------------------------------

function obj:showTransformContextMenu()
    local mouse_position = hs.mouse.absolutePosition()
    menu:popupMenu(mouse_position)
end

-- ------------------------------------
-- Create MarkDown Link Fron History
-- ------------------------------------

function obj:createMarkDownLinkFromHistory()
    local sel = TextUtils.currentSelection()
    local tempClipboard = hs.pasteboard.uniquePasteboard()

    hs.pasteboard.writeAllData(tempClipboard, hs.pasteboard.readAllData(nil))

    local url = hs.pasteboard.getContents()

    if not string.match(url, '^[a-z]*://[^ >,;]*') then
        hs.alert.show("Give Me a URL 🤬")
        return
    end

    local str = "[" .. sel .. "](" .. url .. ")"

    hs.pasteboard.setContents(str)
    hs.timer.usleep(20000)
    hs.eventtap.keyStroke({"cmd"}, "v")
    hs.pasteboard.writeAllData(nil, hs.pasteboard.readAllData(tempClipboard))
    hs.pasteboard.deletePasteboard(tempClipboard)
end

-- ------------------------------------
-- Create Jira Link
-- ------------------------------------

function obj:createJiraLink()
    local sel = TextUtils.currentSelection()

    local str = self.jiraURL .. string.lower(sel)
    print("[" .. sel:upper() .. "](".. self.jiraURL .. string.lower(sel) .. ")")

    if hs.application.frontmostApplication():name() == "Slack" then
        str = "[" .. sel:upper() .. "](".. self.jiraURL .. string.lower(sel) .. ")"
    end

    hs.pasteboard.setContents(str)
    hs.timer.usleep(20000)
    hs.eventtap.keyStroke({"cmd"}, "v")
end

-- ------------------------------------
-- - Convert Slack Markdown to Markdown
-- ------------------------------------

function obj:createSlackMarkdownFromMarkdownHistory()
    hs.pasteboard.setContents(TextUtils.markdownToSlack(hs.pasteboard.getContents()))
    hs.eventtap.keyStroke({"cmd"}, "v")
    return
end

-- ------------------------------------
-- Bind HotKeys to Public Methods
-- ------------------------------------

function obj:bindHotKeys(mapping)
    local spec = {
        showDateTransformContextMenu = hs.fnutils.partial(self.showDateTransformContextMenu, self),
        showTransformContextMenu = hs.fnutils.partial(self.showTransformContextMenu, self),
        createMarkDownLink = hs.fnutils.partial(self.createMarkDownLinkFromHistory, self),
        createJiraLink = hs.fnutils.partial(self.createJiraLink, self),
        createSlackDownFromMarkDown = hs.fnutils.partial(self.createSlackMarkdownFromMarkdownHistory, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)

    return self
end

return obj
