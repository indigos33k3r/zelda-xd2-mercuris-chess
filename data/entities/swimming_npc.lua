-- Lua script of custom entity swimming_talking_npc.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()
  entity.can_talk = true
  entity.dialog_id = ""
  entity.max_distance_before_reset = 32
  -- Initialize the properties of your custom entity here,
  -- like the sprite, the size, and whether it can traverse other
  -- entities and be traversed by them.

  entity:set_traversable_by("hero", false)

  -- Talk to the hero when he's facing the entity
  entity:add_collision_test("facing", function()
    if entity.can_talk and entity:has_dialog_id_set() then
      -- Immediately disable the collision test and face the hero
      entity:get_sprite():set_direction(entity:get_direction4_to(map:get_hero()))
      entity.can_talk = false
      -- Start the dialog, then check when the hero is far enough to be able to talk to him again
      game:start_dialog(entity.dialog_id, function()
        sol.timer.start(map, 500, entity.check_distance)
      end)
    end
  end)
end

-- Set a dialog id to the swimming npc
function entity:set_dialog_id(dialog_id)
  entity.dialog_id = dialog_id
end

-- Get the dialog id of the swimming npc
function entity:get_dialog_id()
  return entity.dialog_id
end

-- Return a boolean to know if a dialog id has been set to the swimming npc
function entity:has_dialog_id_set()
  return entity.dialog_id ~= ""
end

-- Set a dialog id to the swimming npc
function entity:set_max_distance_before_reset(distance)
  entity.max_distance_before_reset = distance
end

-- Return a boolean to know if a dialog id has been set to the swimming npc
function entity:get_max_distancebefore_reset_()
  return entity.max_distance_before_reset
end

-- Called by a timer to reset the possibility to talk to the hero
function entity:check_distance()
  if entity:get_distance(map:get_hero()) > entity.max_distance_before_reset then
    entity.can_talk = true
  else
    return true
  end
end