-- Lua script of map la_dream.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time,
-- as soon as this map becomes is loaded.
function map:on_started()
  -- Camera is moved manually
  local camera = map:get_camera()
  camera:start_manual()
  camera:set_position(320, 0)
  
  -- Cinematic black stipes.
  camera:set_size(320, 192)
  camera:set_position_on_screen(0, 24)

  -- Hide HUD.
  game:set_hud_enabled(false)

  -- Hide hero.
  local hero = map:get_hero()
  hero:freeze()
  hero:set_visible(false)

  -- Prevent the player from pausing the game
  game:set_suspended(true)

  -- Instead, show a castaway hero lying on the beach.
  local castaway_hero_sprite = castaway_hero:get_sprite()
  castaway_hero_sprite:set_animation("dying")
  castaway_hero_sprite:set_paused(true)
  castaway_hero_sprite:set_direction(0)
  castaway_hero_sprite:set_frame(castaway_hero_sprite:get_num_frames() - 1)

  -- Hide and show the right palm trees
  palm_trees_parallax:set_visible(false)
  palm_trees_static:set_visible(true)

  -- Launch first seagull
  map:make_seagull_move(seagull_4, 30)

  -- Wait a bit on the mountain top with the egg.
  sol.timer.start(map, 3000, function()
    map:move_camera_down_to_the_beach()
  end)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

-- Move camera from top of the mountain down to the beach
function map:move_camera_down_to_the_beach()
  -- Create the movement.
  local movement = sol.movement.create("straight")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_angle(3 * math.pi / 2) -- down
  
  -- Max y for the camera movement is Marine's Y 
  local camera = map:get_camera()
  local marine_camera_x, marine_camera_y = camera:get_position_to_track(marine)
  movement:set_max_distance(marine_camera_y)
  
  -- Marine begins to enter when the camera reach the y 162.
  function movement:on_position_changed()
   local x, y = movement:get_xy()
   if y == 96 then
     map:make_seagull_move(seagull_2, 40)
   elseif y == 162 then
     map:make_marine_enter_beach()
   end
  end

  -- Move seagull 1
  map:make_seagull_move(seagull_1, 40)

  -- Launch the camera movement
  movement:start(camera, function()
    -- Hide and show the right palm trees
    palm_trees_parallax:set_visible(true)
    palm_trees_static:set_visible(false)
  end)

end

-- Move Marine from outside the map to the East of the beach.
function map:make_marine_enter_beach()
  marine:get_sprite():set_animation("walking")
  local marine_x, marine_y = marine:get_position()
  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(576, marine_y)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    map:make_marine_go_to_wood_piece()
  end)

end

-- Move Marine to the floating wood piece.
function map:make_marine_go_to_wood_piece()

  local marine_x, marine_y = marine:get_position()
  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")
  
  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(marine_x, marine_y + 16)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    marine_sprite:set_animation("stopped")
    marine_sprite:set_paused(true)
    -- Marine is watching the wooden piece.
    sol.timer.start(map, 2000, function()
      map:make_marine_come_back_from_wood_piece()
    end)
  end)

end

-- Move Marine back to beach.
function map:make_marine_come_back_from_wood_piece()

  local marine_x, marine_y = marine:get_position()
  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")
  marine_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(marine_x, marine_y - 16)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    -- Continue Marine's balade on the beach.
    map:make_marine_go_to_wreck()
  end)

end

-- Move Marine to the ship wreck.
function map:make_marine_go_to_wreck()

  local wreck_x, wreck_y = ship_wreck:get_position() 
  local marine_x, marine_y = marine:get_position()
  marine:get_sprite():set_animation("walking")

  -- Once the free movement of the camera is done,
  -- the camera is locked on Marine.
  map:get_camera():start_tracking(marine)

  local movement = sol.movement.create("target")
  movement:set_speed(30)
  movement:set_smooth(true)
  movement:set_target(wreck_x + 96, marine_y)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    -- Mark a little stop: Marine is seeing the hero far away.
    local marine_sprite = marine:get_sprite()
    marine_sprite:set_animation("stopped")
    marine_sprite:set_paused(true)
    sol.timer.start(map, 1000, function()
      -- Then she runs to the hero.
      map:make_marine_go_to_link()
    end)
  end)

end

-- Move Marine to the hero lying on the beach.
function map:make_marine_go_to_link()

  local marine_sprite = marine:get_sprite()
  marine_sprite:set_animation("walking")
  marine_sprite:set_frame_delay(marine_sprite:get_frame_delay() / 4)
  marine_sprite:set_paused(false)

  local movement = sol.movement.create("target")
  movement:set_speed(120)
  movement:set_smooth(true)
  movement:set_target(castaway_hero, 24, 0)
  movement:set_ignore_obstacles(true)
  movement:start(marine, function()
    marine:get_sprite():set_animation("stopped")
    marine:get_sprite():set_paused(true)
  end)

end

-- Move the seagull npc
function map:make_seagull_move(seagull, speed)
  local seagull_sprite = seagull:get_sprite()
  seagull_sprite:set_animation("walking")
  seagull_sprite:set_paused(false)

  local movement = sol.movement.create("target")

  local seagull_x, seagull_y = seagull:get_position()

  if seagull_x < 0 then
    seagull_sprite:set_direction(0) -- right
    movement:set_target(640 + 32, seagull_y)
  elseif seagull_x > 640 then
    seagull_sprite:set_direction(2) -- left  
    movement:set_target(- 32, seagull_y)
  else 
    seagull_sprite:set_direction(0) -- right
    movement:set_target(640 + 32, seagull_y)
  end

  movement:set_speed(speed)
  movement:set_smooth(true)
  movement:set_ignore_obstacles(true) 
  
  movement:start(seagull, function()
    map:make_seagull_move(seagull, speed)
  end) 
end

-- TODO:
-- Marine tries to wake up Link.
-- Then progressively, she speaks more and more
-- like Zelda who is actually shouting at Link
-- in the real life (Link is dreaming!)
-- Then shake the screen, with a beeeeeep sound
-- and move to another map, where Link is in the bed.