-----------------------------------------------------------------------------------------
--
-- Character Customization.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local o=require("LOptions")
local a=require("LAudio")
local widget = require "widget"
local charname
local charclass
local charmenu
local classmenu
local currentchar
local curmenu

function onLunRelease()
	a.Play(12)
	charname=0
	Classes()
	CurrentChar()
end

function onRefRelease()
	a.Play(12)
	charname=2
	Classes()
	CurrentChar()
end

function onArcRelease()
	a.Play(12)
	charname=1
	Classes()
	CurrentChar()
end

function onIngRelease()
	a.Play(12)
	charname=3
	Classes()	
	CurrentChar()
end

function onKnightRelease()
	a.Play(12)
	charclass=0
	CurrentChar()
end

function onThiefRelease()
	a.Play(12)
	charclass=2
	CurrentChar()
end

function onVikingRelease()
	a.Play(12)
	charclass=3
	CurrentChar()
end

function onWarriorRelease()
	a.Play(12)
	charclass=1
	CurrentChar()
end

function onMageRelease()
	a.Play(12)
	charclass=4
	CurrentChar()
end

function CharMenu()
	if (charclass) then
		Classes()
	CurrentChar()
	end
	if not (charmenu) then
		charmenu=display.newGroup()
	end
	for i=charmenu.numChildren,1,-1 do
		local child = charmenu[i]
		child.parent:remove( child )
	end
	
	local background = display.newImageRect( "bkgs/bkgchar.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
	charmenu:insert(background)
	
	local Luneth1=display.newImageRect("chars/0/char.png",65,65)
	Luneth1.x = display.contentWidth*0.2
	Luneth1.y = display.contentHeight*0.4
	charmenu:insert(Luneth1)
	
	local Luneth = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onLunRelease
	}
	Luneth:setReferencePoint( display.CenterReferencePoint )
	Luneth.x = display.contentWidth*0.2
	Luneth.y = display.contentHeight*0.4
	charmenu:insert(Luneth)
	
	local Refia1=display.newImageRect("chars/2/char.png",65,65)
	Refia1.x = display.contentWidth*0.4
	Refia1.y = display.contentHeight*0.4
	charmenu:insert(Refia1)
	
	local Refia = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onRefRelease
	}
	Refia:setReferencePoint( display.CenterReferencePoint )
	Refia.x = display.contentWidth*0.4
	Refia.y = display.contentHeight*0.4
	charmenu:insert(Refia)
	
	local Arc1=display.newImageRect("chars/1/char.png",65,65)
	Arc1.x = display.contentWidth*0.6
	Arc1.y = display.contentHeight*0.4
	charmenu:insert(Arc1)
	
	local Arc = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onArcRelease
	}
	Arc:setReferencePoint( display.CenterReferencePoint )
	Arc.x = display.contentWidth*0.6
	Arc.y = display.contentHeight*0.4
	charmenu:insert(Arc)
	
	local Ingus1=display.newImageRect("chars/3/char.png",65,65)
	Ingus1.x = display.contentWidth*0.8
	Ingus1.y = display.contentHeight*0.4
	charmenu:insert(Ingus1)
	
	local Ingus = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onIngRelease
	}
	Ingus:setReferencePoint( display.CenterReferencePoint )
	Ingus.x = display.contentWidth*0.8
	Ingus.y = display.contentHeight*0.4
	charmenu:insert(Ingus)
	
	local Back = widget.newButton{
	label="Back",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="button.png",
	overFile="button-over.png",
	width=308, height=80,
	onRelease = onBackRelease
	}
	Back:setReferencePoint( display.CenterReferencePoint )
	Back.x = display.contentWidth*0.5
	Back.y = display.contentHeight-120
	charmenu:insert(Back)

end

function Classes()
	if not (classmenu) then
		classmenu=display.newGroup()
	end
	for i=classmenu.numChildren,1,-1 do
		local child = classmenu[i]
		child.parent:remove( child )
	end
	
	--Viking
	local Viktxt=display.newText("Viking\n+STA", 0, 0, "Game Over", 80)
	Viktxt.x = display.contentWidth*0.2
	Viktxt.y = display.contentHeight*0.5+80
	classmenu:insert(Viktxt)
	
	local Viking1=display.newImageRect("chars/"..charname.."/3/char.png",65,65)
	Viking1.x = display.contentWidth*0.2
	Viking1.y = display.contentHeight*0.5
	classmenu:insert(Viking1)
	
	local Viking = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onVikingRelease
	}
	Viking:setReferencePoint( display.CenterReferencePoint )
	Viking.x = display.contentWidth*0.2
	Viking.y = display.contentHeight*0.5
	classmenu:insert(Viking)
	
	--Warrior
	local Wartxt=display.newText("Warrior\n+ATT", 0, 0, "Game Over", 80)
	Wartxt.x = display.contentWidth*0.2+345.6
	Wartxt.y = display.contentHeight*0.5+80
	classmenu:insert(Wartxt)
	
	local Warrior1=display.newImageRect("chars/"..charname.."/1/char.png",65,65)
	Warrior1.x = display.contentWidth*0.2+345.6
	Warrior1.y = display.contentHeight*0.5
	classmenu:insert(Warrior1)
	
	local Warrior = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onWarriorRelease
	}
	Warrior:setReferencePoint( display.CenterReferencePoint )
	Warrior.x = display.contentWidth*0.2+345.6
	Warrior.y = display.contentHeight*0.5
	classmenu:insert(Warrior)
	
	--Knight
	local Knitxt=display.newText("Knight\n+DEF", 0, 0, "Game Over", 80)
	Knitxt.x = display.contentWidth*0.2+115.2
	Knitxt.y = display.contentHeight*0.5+80
	classmenu:insert(Knitxt)
	
	local Knight1=display.newImageRect("chars/"..charname.."/0/char.png",65,65)
	Knight1.x = display.contentWidth*0.2+115.2
	Knight1.y = display.contentHeight*0.5
	classmenu:insert(Knight1)
	
	local Knight = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onKnightRelease
	}
	Knight:setReferencePoint( display.CenterReferencePoint )
	Knight.x = display.contentWidth*0.2+115.2
	Knight.y = display.contentHeight*0.5
	classmenu:insert(Knight)
	
	--Thief
	local Thitxt=display.newText("Thief\n+DEX", 0, 0, "Game Over", 80)
	Thitxt.x = display.contentWidth*0.8
	Thitxt.y = display.contentHeight*0.5+80
	classmenu:insert(Thitxt)
	
	local Thief1=display.newImageRect("chars/"..charname.."/2/char.png",65,65)
	Thief1.x = display.contentWidth*0.8
	Thief1.y = display.contentHeight*0.5
	classmenu:insert(Thief1)
	
	local Thief = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onThiefRelease
	}
	Thief:setReferencePoint( display.CenterReferencePoint )
	Thief.x = display.contentWidth*0.8
	Thief.y = display.contentHeight*0.5
	classmenu:insert(Thief)
	
	--Mage
	local Magtxt=display.newText("Mage\n+MGC", 0, 0, "Game Over", 80)
	Magtxt.x = display.contentWidth*0.2+230.4
	Magtxt.y = display.contentHeight*0.5+80
	classmenu:insert(Magtxt)
	
	local Mage1=display.newImageRect("chars/"..charname.."/4/char.png",65,65)
	Mage1.x = display.contentWidth*0.2+230.4
	Mage1.y = display.contentHeight*0.5
	classmenu:insert(Mage1)
	
	local Mage = widget.newButton{
	label="",
	labelColor = { default={0,0,0}, over={255,255,255} },
	fontSize=30,
	defaultFile="charbutton.png",
	overFile="charbutton-over.png",
	width=80, height=80,
	onRelease = onMageRelease
	}
	Mage:setReferencePoint( display.CenterReferencePoint )
	Mage.x = display.contentWidth*0.2+230.4
	Mage.y = display.contentHeight*0.5
	classmenu:insert(Mage)
	
end

function CurrentChar()
	if not (curmenu) then
		curmenu=display.newGroup()
	end
	for i=curmenu.numChildren,1,-1 do
		local child = curmenu[i]
		child.parent:remove( child )
	end
	if not (charname) then
		charname=0
	end
	if not (charclass) then
		charclass=0
	end
	
	local char=display.newText("Current Character:", 0, 0, "Game Over", 100)
	char.x = display.contentWidth*0.5
	char.y = display.contentHeight*0.6+60
	curmenu:insert(char)
	
	currentchar=display.newImageRect( "chars/"..charname.."/"..charclass.."/char.png", 76 ,76)
	currentchar.strokeWidth = 4
	currentchar:setStrokeColor(50, 50, 255)
	currentchar.x, currentchar.y = char.x,char.y+80
	curmenu:insert(currentchar)
end

function GetCharInfo(field)
	if field==1 then
		return charclass
	end		
	if field==0 then
		return charname
	end
end

function onBackRelease()
	a.Play(12)
	if (charmenu) then
		for i=charmenu.numChildren,1,-1 do
			local child = charmenu[i]
			child.parent:remove( child )
		end
	end
	if (classmenu) then
		for i=classmenu.numChildren,1,-1 do
			local child = classmenu[i]
			child.parent:remove( child )
		end
	end
	if (curmenu) then
		for i=curmenu.numChildren,1,-1 do
			local child = curmenu[i]
			child.parent:remove( child )
		end
	end
	o.DisplayOptions()
	return true	
end