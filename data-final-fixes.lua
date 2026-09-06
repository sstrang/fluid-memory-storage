-- Nullius compatibility for Fluid Memory Storage
--
-- Mirrors the Memory Storage (deep-storage-unit) integration, including all
-- the lessons from its 1.7.x fix cycle:
--
-- 1. Nullius's prototypes/hidden.lua (data-updates stage) hides every
--    non-nullius item, entity, recipe, and technology, and disables+hides
--    every non-nullius technology. Merely re-anchoring the tech leaves the
--    mod inert — the hiding-pass flags must be reversed here in
--    data-final-fixes (Nullius runs no hiding logic after data-updates, so
--    this sticks).
-- 2. Factorio 2.1 merged recipe `category`/`additional_categories` into
--    `categories`. Any category assignment in this file MUST use the
--    `categories` array — setting `category` here is a hard validation
--    error because this runs after Nullius's own conversion loop.
-- 3. Ingredient names must reference ITEM prototypes, not recipes.
--    Nullius renames vanilla items via localised_name while keeping the
--    vanilla internal name (e.g. "storage-tank" displays as
--    "Medium tank 1"); its hiding passes exempt items whose ORDER starts
--    with "nullius-", which override.lua sets on the renames.
--
-- Placement: late Electrical era, one tier above Memory Storage — the
-- fluid-storage analogue of the unit-storage tech. Anchor techs are all
-- electrical-era (pre-chemical-pack): thermal-storage-1 (order nullius-dl)
-- and plumbing-4 (large tank 1) share that order.

if not mods["nullius"] then return end

-- ---------------------------------------------------------------------------
-- Un-hide from Nullius's hiding passes
-- ---------------------------------------------------------------------------
local item = data.raw.item["fluid-memory-unit"]
if item then
  item.hidden = false
  item.subgroup = "storage"
end

local entity = data.raw["storage-tank"]["fluid-memory-unit"]
if entity then
  entity.hidden = false
end

-- ---------------------------------------------------------------------------
-- Recipe: re-ingredient with Nullius items (Electrical-era tier)
--
--   storage-tank  -> displays as "Medium tank 1" (plumbing-1); survives the
--                    hiding passes via its nullius-bcb order override.
--   constant-combinator -> Nullius "memory circuit" (computation); matches
--                    the circuit component in the Memory Storage recipe.
--   efficiency-module-1 (optimization-1); matches Memory Storage.
-- ---------------------------------------------------------------------------
local recipe = data.raw.recipe["fluid-memory-unit"]
if recipe then
  recipe.ingredients = {
    {type = "item", name = "storage-tank",         amount = 2},
    {type = "item", name = "constant-combinator",  amount = 2},
    {type = "item", name = "nullius-efficiency-module-1", amount = 8},
  }
  recipe.categories = {"large-crafting"}
  recipe.always_show_made_in = true
  -- Undo the hiding pass.
  recipe.hidden = false
  recipe.enabled = false
  recipe.allow_as_intermediate = true
  recipe.allow_decomposition = true
  recipe.order = nil
end

-- ---------------------------------------------------------------------------
-- Technology: re-anchor in the Nullius tree (late Electrical era)
-- ---------------------------------------------------------------------------
local tech = data.raw.technology["fluid-memory-storage"]
if tech then
  -- Undo the disabling pass.
  tech.enabled = true
  tech.hidden = false

  -- Prerequisites:
  --   nullius-thermal-storage-1 -- fluid/thermal storage maturity (electrical era)
  --   nullius-plumbing-4        -- provides the storage-tank ingredient (large tank 1)
  --   nullius-optimization-1    -- provides the nullius-efficiency-module-1 ingredient
  --   nullius-computation       -- provides the constant-combinator ingredient
  tech.prerequisites = {
    "nullius-thermal-storage-1",
    "nullius-plumbing-4",
    "nullius-optimization-1",
    "nullius-computation",
  }

  -- Science cost: four electrical-era packs. Sits above the sibling
  -- thermal-storage-1 (count 150) as the fluid-storage capstone of the era.
  tech.unit = {
    count = 200,
    ingredients = {
      {"nullius-geology-pack", 1},
      {"nullius-climatology-pack", 1},
      {"nullius-mechanical-pack", 1},
      {"nullius-electrical-pack", 1},
    },
    time = 50,
  }
end
