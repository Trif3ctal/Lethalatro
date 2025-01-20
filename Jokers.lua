SMODS.Atlas {
    key = "TestMod",
    path = "TestMod.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'Bracken',
    loc_txt = {
        name = 'Bracken',
        text = {
            "Discards {C:attention}#3#{} random card from",
            " your hand after every round. Gains ",
            "{X:mult,C:white}X0.01{} the {C:attention}rank {}of the discarded ",
            "card every round.",
            "{C:inactive}(Currently {}{X:Xmult,C:white}X#1#{C:inactive} mult)"
        }
    },
    config = { extra = { mult = 1, mult_gain = 0.01, discard = 1} },
    rarity = 3,
    atlas = 'TestMod',
    pos = { x = 0, y = 0 },
    cost = 5,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain, card.ability.extra.discard } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.mult >= 1.01 then
            return {
                Xmult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.mult } },
                
            }
        end

        if context.after and not context.blueprint then
            G.E_MANAGER:add_event(Event({ 
                trigger = 'immediate',
                func = function()
                local any_selected = nil
                local _cards = {}
                for k, v in ipairs(G.hand.cards) do
                    _cards[#_cards+1] = v
                end
                for i = 1, 1 do
                    if G.hand.cards[i] then 
                        local selected_card, card_key = pseudorandom_element(_cards, pseudoseed('bracken'))
                        card.ability.extra.mult_gain = (0.01 * selected_card.base.nominal)
                        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                        G.hand:add_to_highlighted(selected_card, true)
                        table.remove(_cards, card_key)
                        any_selected = true
                        play_sound('card1', 1)
                    end
                end
                if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
            return true end }))
            return {
                message = 'Upgraded!',
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

SMODS.Joker {
    key = 'Stopsign',
    loc_txt = {
        name = 'Stop Sign',
        text = {
            "Disables effects of {C:attention}Boss Blinds{},",
            "destroyed at end of ante"
        }
    },
    config = {},
    rarity = 2,
    atlas = 'TestMod',
    pos = { x = 1, y = 0 },
    cost = 4,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
            G.GAME.blind:disable()
            return {
                message = "Boss disabled!",
                colour = G.C.GREEN
            }
        end
        if context.end_of_round and G.GAME.blind.boss and not context.repetition and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                func = function()
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                        G.jokers:remove_card(card)
                        card:start_dissolve()
                        card = nil
                    return true; end}))
                return true
            end
        }))
    end
    end
}