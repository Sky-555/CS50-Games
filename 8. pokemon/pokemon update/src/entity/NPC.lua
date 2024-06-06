NPC = Class{__includes = Entity}

function NPC:init(def)
    Entity.init(self, def)

    self.text = "Hi, I'm an NPC, demonstrating some dialogue! Isn't that cool??"
end

function NPC:onInteract()
    gStateStack:push(DialogueState(self.text))
end