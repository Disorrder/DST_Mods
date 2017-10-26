--------------------------
--  WIP! WIP! WIP! WIP!
-- ORIGINAL SGwerebeaver
--------------------------
require("stategraphs/commonstates")

local actionhandlers = 
{
    
    ActionHandler(ACTIONS.CHOP, "work"),
    ActionHandler(ACTIONS.MINE, "work"),
    ActionHandler(ACTIONS.DIG, "work"),
    ActionHandler(ACTIONS.HAMMER, "work"),
    -- ActionHandler(ACTIONS.EAT, "eat"),
	ActionHandler(ACTIONS.ATTACK, "attack"),
	
}


local events=
{
    --CommonHandlers.OnLocomote(true,false),
    EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run_start")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle")) then
            inst.sg:GoToState("idle")
        end
    end),

    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("bear_end", function(inst) inst.sg:GoToState("tohuman") end)
}

local states=
{

    State{
        name = "attack",
        tags = { "attack", "abouttoattack", "autopredict" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
            inst.AnimState:PlayAnimation("atk")
                
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)

            cooldown = math.max(cooldown, 13 * FRAMES)

            inst.sg:SetTimeout(cooldown)
            
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "hit",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")        
            inst.AnimState:PlayAnimation("hit")
            inst:ClearBufferedAction()

            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/hurt_beaver")
            
            inst.components.locomotor:Stop()

            if inst.components.playercontroller ~= nil then
                --Specify 3 frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(3)
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    
    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                PlayFootstep(inst, nil, true)
            end),
        },

        events =
        {   
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.AnimState:PlayAnimation("run_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.mem.footsteps > 3 then
                    PlayFootstep(inst, .6, true)
                else
                    inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    PlayFootstep(inst, 1, true)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if inst.sg.mem.footsteps > 3 then
                    PlayFootstep(inst, .6, true)
                else
                    inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    PlayFootstep(inst, 1, true)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst) 
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,

        events =
        {   
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "tohuman",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("death")
            inst.sg:SetTimeout(3)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
            inst.components.rage.doing_transform = true
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                --inst.SoundEmitter:KillSound("beavermusic")
                if inst == ThePlayer then
                TheFocalPoint.SoundEmitter:KillSound("beavermusic")
                end
                end)
        },
        
        ontimeout = function(inst)
            inst:ScreenFade(false, 2)
            inst:DoTaskInTime(2, function() 
                
                if TheWorld.ismastersim then
                    --TheWorld:PushEvent("ms_nextcycle")
                    print("Spawning in smoke and light!")
    				SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())

                    if not TheWorld.state.isday then
    				    SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    end

                    -- inst.components.rage.makeperson(inst)
                    inst.components.sanity:SetPercent(.25)
                    inst.components.health:SetPercent(.33)
                    inst.components.hunger:SetPercent(.25)
                    inst.components.rage.doing_transform = false
                    inst.sg:GoToState("wakeup")
                end

                inst:ScreenFade(true, 1)
            end)
        end
    },

    State{
        name = "transform_pst",
        tags = {"busy"},
        onenter = function(inst)
			if inst.components.playercontroller then inst.components.playercontroller:Enable(false) end
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("transform_pst")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            if inst.components.playercontroller then inst.components.playercontroller:Enable(true) end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) TheCamera:SetDistance(30) inst.sg:GoToState("idle") end ),
        },        
    },    

    State{
        name = "work",
        tags = {"busy", "working"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
            TimeEvent(6*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(7*FRAMES, function(inst) inst.sg:RemoveStateTag("working") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
            TimeEvent(8*FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),            
        },
		events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },   
    },

    -- State{
    --     name = "eat",
    --     tags = {"busy"},
        
    --     onenter = function(inst, feed)
    --         inst.Physics:Stop() 

    --         if feed ~= nil then
    --             inst.components.locomotor:Clear()
    --             inst:ClearBufferedAction()
    --             inst.sg.statemem.feed = feed
    --             inst.sg:AddStateTag("pausepredict")
    --             if inst.components.playercontroller ~= nil then
    --                 inst.components.playercontroller:RemotePausePrediction()
    --             end
    --         elseif inst:GetBufferedAction() then
    --             feed = inst:GetBufferedAction().invobject
    --         end

    --         inst.AnimState:PlayAnimation("eat")
    --         inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/eat_beaver") 
    --     end,
        
    --     timeline=
    --     {
    --         TimeEvent(9*FRAMES, function(inst) 

    --              if inst.sg.statemem.feed ~= nil then
    --                 inst.components.eater:Eat(inst.sg.statemem.feed)
    --             else
    --                 inst:PerformBufferedAction() 
    --             end

    --               end),
    --         TimeEvent(12*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
    --     },        
        
    --     events=
    --     {
    --         EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    --     },        
    -- },
}

CommonStates.AddIdle(states)
    
return StateGraph("werebeaver", states, events, "idle", actionhandlers)

