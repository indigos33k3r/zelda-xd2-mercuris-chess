local enemy = ...

-- Minillosaur egg: a small papillosaur that comes from an egg.
-- This enemy is usually be generated by a bigger one.

enemy:set_life(2)
enemy:set_damage(2)
enemy:set_size(24, 32)
enemy:set_origin(12, 20)
enemy:set_invincible()
enemy:set_attack_consequence("sword", "custom")
enemy:set_obstacle_behavior("flying")

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
sprite:set_animation("egg")
local in_egg = true

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  if in_egg then
    sprite:set_animation("egg")
    local angle = self:get_angle(self:get_map():get_entity("hero"))
    local m = sol.movement.create("straight")
    m:set_speed(120)
    m:set_angle(angle)
    m:set_max_distance(180)
    m:set_smooth(false)
    m:start(self)
  else
    self:go_hero()
  end
end

-- An obstacle is reached: in the egg state, break the egg.
function enemy:on_obstacle_reached(movement)

  if sprite:get_animation() == "egg" then
    self:break_egg()
  end
end

-- The movement is finished: in the egg state, break the egg.
function enemy:on_movement_finished(movement)
  -- Same thing as when an obstacle is reached.
  self:on_obstacle_reached(movement)
end

-- The enemy receives an attack whose consequence is "custom".
function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" and sprite:get_animation() == "egg" then
    -- The egg is hit by the sword.
    self:break_egg()
    sol.audio.play_sound("monster_hurt")
  end
end

-- Starts breaking the egg.
function enemy:break_egg()

  self:stop_movement()
  sprite:set_animation("egg_breaking")
end

--  The animation of the sprite is finished.
function sprite:on_animation_finished(animation)

  -- If the egg was breaking, make the minillosaur go.
  if animation == "egg_breaking" then
    self:set_animation("walking")
    enemy:set_size(16, 16)
    enemy:set_origin(8, 12)
    enemy:go_hero()
  end
end

function enemy:go_hero()

  self:snap_to_grid()
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
  self:set_default_attack_consequences()
  in_egg = false
end

