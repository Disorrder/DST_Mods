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
    RAGE = 100, -- max rage on start
    RAGE_LIMIT = 100, -- max available rage
    RAGE_LOSE = .2, -- per sec
    RAGE_LOSE_IN_COMBAT = 0, -- TODO

    RAGE_ATK_SCALE = 0.5,
    RAGE_ASPEED_SCALE = 0.1,
    RAGE_SPEED_SCALE = 0, -- TODO inst.components.locomotor.runspeed

    -- Hitting
    HIT_RAGE = 2,
    HIT_SANITY = -2,

    -- Multiplicative bonus damage from another monsters (1 = +100%)
    DAMAGE_FROM_BEE = 0.5,

    -- Foods
    HONEY_SANITY = 2,
    BERRIES_SANITY = 2,

    -- Loot weights
    BEE_HONEY_WEIGHT = 15,
    BEE_STINGER_WEIGHT = 5,
    get_bee_after_killing = false, -- Класть пчелу в инвентарь после убийства, для тестов

    -- System
    debug = true,

    testAnim = {
        "run_pre",
        "run_loop",
        "run_pst",
    },
} end
