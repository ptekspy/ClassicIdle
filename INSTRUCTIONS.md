I want you to help me migrate all UI in my Roblox game into programmatic, componentised UI.

Important: do not implement the migration yourself.

Your job is to inspect the repo and then create a clear set of ordered markdown instruction files that tell me exactly what to do.

I want all instructions written into chronological markdown files, not delivered as a long chat walkthrough.

The markdown files should be clear, direct, practical, and specific.

# Goal

I want all gameplay UI to become programmatic and componentised.

By the end:

* There should be no required physical UI screens in Roblox Studio.
* All gameplay UI should be created from code.
* UI should be split into components.
* Each component should live in its own file.
* Components should accept props.
* After I delete the old Studio UI objects you identify, I should be able to click Play and see no visual difference.

# Your role

You are not implementing the migration.

You are creating the instruction plan for me to follow.

You should:

* inspect the repo
* inspect current UI code
* inspect current Roblox UI/world structure if available
* identify every existing UI area
* decide whether React-Lua should be used now
* design the component structure
* create ordered markdown files with exact instructions
* make the steps chronological
* make each file focused
* include exact code snippets I need to paste
* include exact files to create/edit
* include exact Roblox Studio objects to delete/keep
* include exact validation steps

Do not edit source files except the markdown instruction files.

Do not migrate the UI yourself.

# Required output files

Create a folder for the migration docs, for example:

```txt
docs/ui-migration/
```

Use the repo’s existing docs folder convention if one already exists.

Create ordered markdown files like this:

```txt
docs/ui-migration/
  00_UI_AUDIT.md
  01_REACT_LUA_DECISION.md
  02_TARGET_COMPONENT_STRUCTURE.md
  03_WORLD_CHANGES.md
  04_UI_FOUNDATION.md
  05_MIGRATE_FIRST_SMALL_UI.md
  06_MIGRATE_MAIN_HUD.md
  07_MIGRATE_INTERACTION_UI.md
  08_MIGRATE_MENUS.md
  09_DELETE_OLD_UI.md
  10_FINAL_VALIDATION.md
```

Adjust names if the repo has better conventions, but keep the files numbered in chronological order.

Each markdown file should be independently useful and clear.

# Markdown style

The markdown files should be practical instructions, not vague notes.

Use:

* short sections
* checklists
* exact file paths
* exact object paths
* exact code blocks
* exact commands if needed
* clear “done when” criteria
* clear validation steps

Avoid:

* vague advice
* long essays
* unexplained architecture
* “you may want to” language
* dumping too much unrelated context

Each file should answer:

```txt
What am I doing?
Why am I doing it?
What files do I create?
What files do I edit?
What code do I paste?
What Studio changes do I make?
How do I test it?
What should success look like?
What should I not touch yet?
```

# First file: UI audit

`00_UI_AUDIT.md` should list every UI thing you find.

For every UI object or UI-related script, include:

* file path or Roblox object path
* what it appears to do
* whether it is physical Studio UI, generated code, imperative code, or already componentised
* whether it should be migrated
* whether it can eventually be deleted
* what depends on it
* migration risk level

Look for:

* ScreenGui
* SurfaceGui
* BillboardGui
* Frame
* TextLabel
* TextButton
* ImageLabel
* ImageButton
* UIListLayout
* UIGridLayout
* UIPadding
* UICorner
* UIStroke
* UIGradient
* StarterGui
* PlayerGui
* generated UI scripts
* manually created UI instances
* React-Lua usage
* existing UI components
* existing UI style helpers
* existing hooks/state patterns
* remote/Replica data feeding UI

Also inspect UI related to:

* resources panel
* currency display
* quest tracker
* hotbar
* build mode controls
* build shop
* interaction prompts
* storage/bin UI
* upgrade UI
* NPC hire UI
* rocket stats/progress UI
* collection prompts
* BillboardGui labels
* SurfaceGui displays

# React-Lua decision

`01_REACT_LUA_DECISION.md` should clearly decide whether to migrate directly to React-Lua now.

I plan to migrate to React-Lua.

If React-Lua is already installed/configured or easy to safely introduce now, recommend migrating directly into React-Lua components.

If React-Lua is not ready, explain:

* what is missing
* whether it should be installed first
* whether it is safer to componentise with the current UI style first
* what the tradeoff is

Prefer React-Lua now if reasonable because the UI surface is still small.

Do not create a temporary custom UI framework if React-Lua can be used cleanly.

# Component structure

`02_TARGET_COMPONENT_STRUCTURE.md` should define the final component plan.

Every meaningful UI piece should become a component.

One component per file.

For each component, include:

* component name
* exact file path
* responsibility
* props
* parent component/screen
* child components
* data source
* actions/callbacks

Prefer this kind of structure if it fits the repo:

```txt
UI/
  Components/
    ResourcePanel.lua
    ResourceRow.lua
    CurrencyDisplay.lua
    QuestTracker.lua
    Hotbar.lua
    HotbarSlot.lua
    BuildModeControls.lua
    InteractionPrompt.lua
    ProgressBar.lua
  Screens/
    MainHud.lua
    BuildShopScreen.lua
    UpgradeScreen.lua
```

Use the repo’s actual folder conventions if different.

# Props rules

Leaf components should receive data through props.

Example prop concepts:

```lua
ResourceRow({
    resourceName = "Wood",
    amount = 10,
    icon = "...",
    layoutOrder = 1,
})
```

```lua
CurrencyDisplay({
    gold = 25,
    gems = 0,
})
```

```lua
QuestTracker({
    title = "Collect 10 Wood",
    description = "Collect wood from the forest.",
    progressText = "4 / 10",
    isComplete = false,
})
```

Do not hardcode player data deep inside leaf components.

Top-level screens may connect to replicated state and pass data down.

# World/UI changes

`03_WORLD_CHANGES.md` should only exist if world or Studio object changes are needed.

If world/UI object changes are needed, create it and include:

* exact Studio paths
* exact objects to delete later
* exact objects to keep
* exact objects that must not be deleted yet
* exact required folders/templates/assets
* when each object becomes safe to delete
* validation steps after deletion

If no world/UI object changes are needed yet, create a short file called:

```txt
03_NO_WORLD_CHANGES_NEEDED.md
```

and explain why.

# Programmatic UI foundation

`04_UI_FOUNDATION.md` should explain how to set up the programmatic UI foundation.

Include:

* files to create
* files to edit
* exact code to paste
* how UI roots mount
* how cleanup/unmount works
* how player reset/rejoin is handled
* how to avoid duplicate UI roots
* how to test that the root mounts once

If using React-Lua:

* follow existing repo conventions
* one component per file
* use typed props if the repo uses strict typing
* use the project’s existing React style
* mount roots cleanly
* unmount safely
* use existing player data hooks if present
* avoid mixing React-owned UI with imperative mutation

# Migration instruction files

Each migration file should focus on one stage.

For example:

`05_MIGRATE_FIRST_SMALL_UI.md`

* pick the smallest safest UI area
* explain why it is first
* give exact component files
* give exact code
* explain how to disable old UI without deleting it
* explain how to compare visual parity

`06_MIGRATE_MAIN_HUD.md`

* resources
* currency
* quest tracker
* hotbar
* other visible HUD pieces

`07_MIGRATE_INTERACTION_UI.md`

* prompts
* BillboardGui
* SurfaceGui
* collection prompts
* upgrade prompts

`08_MIGRATE_MENUS.md`

* build shop
* upgrade UI
* storage UI
* NPC hire UI

Use different files if the repo’s actual UI structure suggests better stages.

# Deletion plan

`09_DELETE_OLD_UI.md` must include the final deletion list.

For each old UI object, include:

* exact Roblox Studio path
* object name
* what it used to do
* what replaced it
* when it is safe to delete
* whether it must be deleted manually
* validation after deletion

The goal is:

After I delete the listed old UI objects:

* I click Play
* the new programmatic UI appears
* there is no visual difference
* there are no missing-object errors

# Final validation

`10_FINAL_VALIDATION.md` should include a full validation checklist.

Include checks for:

* UI appears once, not duplicated
* UI looks visually the same
* text matches
* colours match
* sizes match
* positions match
* inputs still work
* no missing-object errors
* no infinite remounts
* no client-authoritative gameplay logic
* reset/rejoin does not duplicate UI
* deleting old objects does not break new UI
* Play mode after deletion looks the same

# Visual parity requirement

The new UI should look the same as the old UI.

Do not redesign the UI unless I explicitly ask.

Preserve:

* position
* size
* colour
* font
* text
* icons
* padding
* corner radius
* stroke
* layering
* visibility
* input behaviour

If exact parity is not possible, explain why in the relevant markdown file.

# Programmatic UI requirement

Final gameplay UI should be created from code.

Allowed:

* image assets
* icons
* fonts
* code-created BillboardGui
* code-created SurfaceGui
* React-Lua roots
* intentionally documented templates if absolutely necessary

Not allowed:

* final HUD existing only as manually placed StarterGui objects
* final screens requiring manual Frame/TextLabel/Button instances in Studio
* hidden old physical UI that still drives live gameplay UI

# State/data flow

Inspect how UI currently gets data.

Possible sources:

* Replica/player data
* remotes
* attributes
* local state
* services
* storage/resource systems
* quest system
* build mode state

New UI should preserve behaviour.

UI should not become authoritative for gameplay.

UI should display state and send actions through existing safe remotes/services.

# Code standards for instructions

The markdown instructions should follow repo conventions.

When giving code:

* inspect nearby files first
* match naming
* match folder structure
* match module style
* match typing style
* match React/style conventions
* keep code small and readable
* one component per file
* components should accept props
* avoid broad rewrites
* do not introduce new dependencies unless clearly needed and explained
* do not change generated files unless they are the target of migration
* do not make unrelated formatting changes
* preserve existing public APIs unless necessary
* handle nil/missing data defensively
* avoid duplicated UI code

# Required final response after creating the markdown files

After creating the markdown files, respond with:

* list of markdown files created
* short description of what each file contains
* whether world/UI changes are required
* whether React-Lua is recommended now
* the first file I should read
* the first action I should take

Do not implement UI migration code.

Do not modify UI source files.

Only create the ordered markdown instruction files.
