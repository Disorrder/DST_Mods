function log(...) if TUNING.MICHAEL.debug then print(...) end end

if not TUNING.MICHAEL then TUNING.MICHAEL = {
    -- Stats
    HEALTH = 150,
    HUNGER = 150,
    SANITY = 200,

    -- Attack
    ATTACK_RANGE = 2,
    ATTACK_PERIOD = TUNING.WILSON_ATTACK_PERIOD, -- .1
    UNARMED_DAMAGE = TUNING.UNARMED_DAMAGE, -- 10

    -- Rage
    RAGE   = 100, -- TODO test
    RAGE_LOSE = 1, -- per sec -- TODO test
    RAGE_LOSE_IN_COMBAT = 0, -- TODO

    RAGE_ATK_SCALE = 0.5, -- TODO
    RAGE_ASPEED_SCALE = 0, -- TODO
    RAGE_SPEED_SCALE = 0, -- TODO

    -- Hitting
    HIT_RAGE = 2, -- TODO
    HIT_SANITY = -1, -- TODO

    -- Foods
    HONEY_SANITY = 2,
    BERRIES_SANITY = 2,

    -- Loot weights
    BEE_HONEY_WEIGHT = 15,
    BEE_STINGER_WEIGHT = 5,
    get_bee_after_killing = false, -- Класть пчелу в инвентарь после убийства, для тестов

    -- System
    debug = true, -- TODO test
} end
