---------------------------------------------------------------------------------------
--
-- UI.lua
--
---------------------------------------------------------------------------------------
module(..., package.seeall)

---------------------------------------------------------------------------------------
-- GLOBAL
---------------------------------------------------------------------------------------

local coinsheet = graphics.newImageSheet("coinsprite.png", { width=32, height=32, numFrames=8 } )
local widget = require "widget"
-- local b=require("Lbuilder")
-- local p=require("Lplayer")
local JSON=require("JSON")
local game=require("Lgame")
local isOpn		--window open
local isPaused	--paused
local isUse		--using an item
local infwg 	--info window group
local bkwg 		--book window group
local dwg 		--death window group
local swg		--sound window group
local exmg		--exit menu group
local umg		--use menu group
local invg		--inv group
local eqpg		--equip group
local GoldCount=0
local GCDisplay
local CDisplay
local DisplayS=1.25
local gwg
local gShown=true
local DeathMessages={
	-- Lava
	{
		"Roasted by lava.",
		"Swimming in lava.",
		"Hyperthermia.",
		"Skin melting.",
		"Do I smell barbecue?",
	},
	-- Mob
	{
		"Fighting a mob.",
		"Face smashed in.",
		"Your insides are on the floor.",
		"Pro-tip: Keep your extremities together.",
		"Exsanguination.",
		"Don't mess with the mobs.",
		"Do not feed the mobs.",
	},
	-- Poison
	{
		"Well, now you know.",
		"Smooth move.",
		"Nice one, smartass.",
		"That was poison.",
		"You had so much potential...",
	},
	-- Portal
	{
		"Portal dismemberment.",
		"I think your leg is over there.",
		"Your blood didn't teleport...",
		"Stay inside the portal at all times.",
		"Not your best teleport.",
		"Did you find the secret cow level?",
	},
	-- Energy
	{
		"Falling unconscious in a dungeon.",
		"Should've kept some energy drinks handy.",
		"So is having energy a priority to you now?",
		"Should've gotten a good night's sleep.",
	},
}

local function readAnims(animname)
	-- call JSON read func to receive lua table with JSON info
	-- adapt JSON info for ease of access
	filename = system.pathForFile( animname )
	file = assert(io.open(filename, "r"))
	-- file = assert(love.filesystem.load(animname, "r"))
	
	-- use JSON library to decode it to a LUA table
	-- then return table
	
	-- local output = J:decode(file:read("*all"))
	local output = JSON:decode(file:read("*all"))
	
	
	output=output["Animations"]["Animation"]
	
	-- arrange JSON info to a better array
	-- i used for id of animation
	-- first name is animation name
	-- animation subdivision -> parts
	-- part name is asset name
	-- for every frame of animation, save asset info
	-- x, y, scaleX, scaleY, rotation, depth
	-- depth is layering, who is in front of who
	-- then arrange color matrix to regular RGBA channels
	parsed={}
	local nameofsequence=output["-name"]
	parsed[nameofsequence] = {}
	parsed[nameofsequence]["maxframes"]=tonumber(output["-frameCount"])
	for j=1,table.maxn(output["Part"]) do
		local nameofasset=output["Part"][j]["-name"]
		parsed[nameofsequence][nameofasset]={}
		for k=1,table.maxn(output["Part"][j]["Frame"]) do
			parsed[nameofsequence][nameofasset][k]={}
			parsed[nameofsequence][nameofasset][k]["x"]=tonumber(output["Part"][j]["Frame"][k]["-x"])
			parsed[nameofsequence][nameofasset][k]["y"]=tonumber(output["Part"][j]["Frame"][k]["-y"])
			parsed[nameofsequence][nameofasset][k]["scaleX"]=tonumber(output["Part"][j]["Frame"][k]["-scaleX"])
			parsed[nameofsequence][nameofasset][k]["scaleY"]=tonumber(output["Part"][j]["Frame"][k]["-scaleY"])
			parsed[nameofsequence][nameofasset][k]["rotation"]=tonumber(output["Part"][j]["Frame"][k]["-rotation"])
			parsed[nameofsequence][nameofasset][k]["depth"]=tonumber(output["Part"][j]["Frame"][k]["-depth"])
			
			
			local b=output["Part"][j]["Frame"][k]["-colorMatrix"]
			local a={}
			local cont=0
			for word in string.gmatch(b,"%d+") do
				a[cont]=word
				cont=cont+1
			end
			
			local colorArray={}
			colorArray[1] = a[00] + a[01] + a[02] + a[03] + a[04]
			colorArray[2] = a[05] + a[06] + a[07] + a[08] + a[09]
			colorArray[3] = a[10] + a[11] + a[12] + a[13] + a[14]
			colorArray[4] = a[15] + a[16] + a[17] + a[18] + a[19]
			
			parsed[nameofsequence][nameofasset][k]["colors"]=colorArray
			
		end
	end
	return parsed
end

local function readAsset(assname)
	-- call JSON read function to receive lua table with JSON info
	
	filename = system.pathForFile( assname )
	file = assert(io.open(filename, "r"))
	
	-- use JSON library to decode it to a LUA table
	-- then return table
	
	-- local output = J:decode(file:read("*all"))
	local output = JSON:decode(file:read("*all"))
	output=output["frames"]
	
	-- arrange JSON info to a better array
	-- i used for id of animation
	-- first name is animation name
	-- animation subdivision -> parts
	-- part name is asset name
	-- for every frame of animation, save asset info
	-- x, y, xScale, yScale, rotation, depth
	-- depth is layering, who is in front of who
	-- then arrange color matrix to regular RGBA channels
	
	step={}
	for i=1,table.maxn(output) do
		step[i] = {}
		step[i]["filename"]=output[i]["filename"]
		step[i]["width"]=output[i]["frame"]["w"]
		step[i]["height"]=output[i]["frame"]["h"]
		step[i]["x"]=output[i]["frame"]["x"]
		step[i]["y"]=output[i]["frame"]["y"]
	end
	parsed={}
	parsed["frames"]=step
	return parsed
end

function isBusy()
	return isPaused
end

function CreateWindow(width,height,theme)
	width=width or 60
	height=height or 60
	theme=theme or 0
	if width>=60 and height>=60 then
		local WindowGroup=display.newGroup()
		local WindowElems={}
		local WindowSheet
		local itemwidth=49.5
		local itemheight=49.5
		local dg=WindowGroup
		local elm=WindowElems
		local spacex
		local spacey
		
		-- FIND THEME
		local totaloptions=readAsset('ui/MoreWindows.json')
		totaloptions=totaloptions["frames"]
		totaloptions["frames"]=nil
		local options={}
		options["frames"]={}
		for i=1,table.maxn(totaloptions) do
			local thisframe=totaloptions[i]
			local xinicial=thisframe["x"]
			local yinicial=thisframe["y"]
			local perframeoptions=readAsset('ui/Windows.json')
			perframeoptions=perframeoptions["frames"]
			for j=1,table.maxn(perframeoptions) do
				
				perframeoptions[j]["x"]=perframeoptions[j]["x"]+xinicial
				perframeoptions[j]["y"]=perframeoptions[j]["y"]+yinicial
				local curoption=(i-1)*(table.maxn(perframeoptions) )+j
				options["frames"][curoption]=perframeoptions[j]
			end
		end
		WindowSheet=graphics.newImageSheet( "ui/MoreWindows.png", options )
		
		local cols=math.ceil(width/(itemwidth))
		local rows=math.ceil(height/(itemheight))
		
		for x=1,cols do
			elm[x]={}
			if x==cols then
				spacex=width-(itemwidth)
			else
				spacex=(x-1)*(itemwidth)
			end
			for y=1,rows do
				local index
				local rot=0
				local xscale=1
				local yscale=1
				if y==rows then
					spacey=height-(itemheight)
				else
					spacey=(y-1)*(itemheight)
				end
				if x==1 or x==cols then
					if y==1 then
						-- NORTH CORNERS
						index=3
					elseif y==rows then
						-- SOUTH CORNERS
						index=2
					else
						-- LEFT AND RIGHT SIDES
						index=1
						rot=90
					end
					if x==cols then
						if rot==90 then
							yscale=-1
						else
							xscale=-1
						end
					end
				else
					if y==1 then
						-- NORTH SIDE
						index=5
					elseif y==rows then
						-- SOUTH SIDE
						index=1
					else
						-- IN SIDE
						index=4
					end
				end
				
				index=(theme*5)+index
				
				elm[x][y]=display.newImage(WindowSheet,index)
				elm[x][y].x=-(width/2)+25+spacex
				elm[x][y].y=-(height/2)+25+spacey
				elm[x][y].rotation=rot
				elm[x][y].xScale=xscale
				elm[x][y].yScale=yscale
				dg:insert(elm[x][y])
			end
		end
		
		WindowGroup.x=display.contentCenterX
		WindowGroup.y=display.contentCenterY
		
		WindowGroup.setFillColor=function(self,r,g,b,a)
			a=a or 1
			local colormatrix={r,g,b,a}
			for i=1,table.maxn(colormatrix) do
				if colormatrix[i]<0 then
					colormatrix[i]=0
				elseif colormatrix[i]>1 then
					colormatrix[i]=1
				end
			end
			for i=self.numChildren,1,-1 do
				local child = self[i]
				child:setFillColor(colormatrix[1],colormatrix[2],colormatrix[3],colormatrix[4])
			end
		end
		
		return WindowGroup
	else
		assert(false, "Invalid height or width.")
	end
end

function Essentials(value)
	-- p1=value
	isUse=false
	isOpn=false
	isPaused=false
	
	Interface:show()
	-- Runtime:addEventListener("enterFrame", GoldDisplay)
end


---------------------------------------------------------------------------------------
-- PAUSE MENU
---------------------------------------------------------------------------------------

local pwg
PauseMenu={}

function PauseMenu:show()

	scale=1.2
	espacio=64*scale
	statchangexs=200
	statchangey=(display.contentCenterY)-110
	statchangex=(display.contentCenterX)-statchangexs
	statchange={}
	pwg=display.newGroup()
	
	window=CreateWindow(506,210)
	window.x,window.y=(display.contentCenterX),60
	window:setFillColor(1,0.2,0.2)
	pwg:insert(window)
	
	pwgtext=display.newText("Game Paused.",0,0,"MoolBoran",80)
	pwgtext:setTextColor(1,1,1)
	pwgtext.x=display.contentCenterX
	pwgtext.y=150
	pwg:insert(pwgtext)
	
	bag=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/bagbtn.png",
		overFile="ui/bagbtn_hold.png",
		width=80, height=80,
		onRelease=OpenBag
	}
	bag.x = window.x-(80*2*1.2)
	bag.y =window.y-5
	bag.xScale = 1.2
	bag.yScale = bag.xScale
	pwg:insert(bag)
	
	info=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/infobtn.png",
		overFile="ui/infobtn_hold.png",
		width=80, height=80,
		onRelease=OpenInfo
	}
	info.x, info.y = bag.x+(80*bag.xScale), bag.y
	info.yScale = bag.yScale
	info.xScale = bag.xScale
	pwg:insert(info)
	
	snd=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/soundbtn.png",
		overFile="ui/soundbtn_hold.png",
		width=80, height=80,
		onRelease=OpenSnd
	}
	snd.x,snd.y = info.x+(80*info.xScale), bag.y
	snd.xScale=bag.xScale
	snd.yScale=bag.yScale
	pwg:insert(snd)
	
	magic=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/magicbtn.png",
		overFile="ui/magicbtn_hold.png",
		width=80, height=80,
		onRelease=OpenBook
	}
	magic.x, magic.y = snd.x+(80*snd.xScale), bag.y
	magic.yScale = bag.yScale
	magic.xScale = bag.xScale
	pwg:insert(magic)
	
	magic=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/magicbtn.png",
		overFile="ui/magicbtn_hold.png",
		width=80, height=80,
		onRelease=OpenBook
	}
	magic.x, magic.y = snd.x+(80*snd.xScale), bag.y
	magic.yScale = bag.yScale
	magic.xScale = bag.xScale
	pwg:insert(magic)
	
	quest=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/questbtn.png",
		overFile="ui/questbtn_hold.png",
		width=80, height=80,
		onRelease=OpenLog
	}
	quest.x, quest.y = magic.x+(80*magic.xScale), bag.y
	quest.yScale = bag.yScale
	quest.xScale = bag.xScale
	pwg:insert(quest)
	
	pausebtn=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/pause.png",
		overFile="ui/pause_hold.png",
		width=80, height=80,
		onRelease=Pause
	}
	pausebtn.x, pausebtn.y = display.contentWidth-(40*bag.xScale),40*bag.yScale
	pausebtn.yScale = bag.yScale
	pausebtn.xScale = bag.xScale
	
	
	-- pcg.isVisible=true
	pwg.isVisible=false
	-- pcg:toFront()
end

function PauseMenu:clear()
	if (pwg) then
		for i=pwg.numChildren,1,-1 do
			display.remove(pwg[i])
			pwg[i]=nil		
		end	
		pwg=nil
	end
end


---------------------------------------------------------------------------------------
-- GENERAL WINDOW MANAGER
---------------------------------------------------------------------------------------

function toggleState(mute)
	if isOpn==true then
		-- m.Visibility()
		-- m.ShowArrows()
		isOpn=false
		if mute~=true then
			-- a.Play(3)
		end
	elseif isOpn==false then
		-- m.CleanArrows()
		isOpn=true
		if mute~=true then
			-- a.Play(4)
		end
	end
	-- g.ShowGCounter()
	-- p.LetsYodaIt()
end

function canWindowCheck()
	local shap=shp.AtTheMall()
	if shap==false then
		return true
	else
		return false
	end
end

function ForceClose()
	if isOpn==true then
		if (infwg) then
			ToggleInfo()
		end
		if (invg) then
			ToggleBag()
		end
		if (swg) then
			ToggleSound()
		end
		if (exmg) then
			ToggleExit()
		end
		if (bkwg) then
			ToggleSpells()
		end
	end
end

function Pause()
	if isPaused==true then
		ForceClose()
		isPaused=false
		pcg.isVisible=true
		psg.isVisible=true
		pwg.isVisible=false
		psg:toFront()
		pcg:toFront()
	elseif isPaused==false then
		isPaused=true
		pcg.isVisible=false
		psg.isVisible=false
		pwg.isVisible=true
		pwg:toFront()
	end
end


---------------------------------------------------------------------------------------
-- DEFAULT INTERFACE
---------------------------------------------------------------------------------------

local psg
Interface={}

function Interface:show()
	psg=display.newGroup()
	--[[
	local statwindow=CreateWindow(300,200)
	statwindow.x=80
	statwindow.y=100
	statwindow:setFillColor(1,0.2,0.2)
	psg:insert(statwindow)
	
	
	
	Interface.LifeDisplay = display.newText((p1["STATS"]["Health"].."/"..p1["STATS"]["MaxHealth"]),0,0,"Game Over",100)
	Interface.LifeDisplay.anchorX=0
	Interface.LifeDisplay.anchorY=0
	Interface.LifeDisplay.x=statwindow.x--40
	Interface.LifeDisplay.y=statwindow.y-90
	psg:insert(Interface.LifeDisplay)
	
	local LifeSymbol=display.newSprite( heartsheet, {name="heart",start=1,count=16,time=(1800)} )
	LifeSymbol.anchorX=0
	LifeSymbol.anchorY=0
	LifeSymbol.yScale=3.75
	LifeSymbol.xScale=3.75
	LifeSymbol.x = Interface.LifeDisplay.x-70
	LifeSymbol.y = Interface.LifeDisplay.y+5
	LifeSymbol:play()
	psg:insert(LifeSymbol)
	
	
	
	Interface.ManaDisplay = display.newText((p1["STATS"]["Mana"].."/"..p1["STATS"]["MaxMana"]),0,0,"Game Over",100)
	Interface.ManaDisplay.anchorX=0
	Interface.ManaDisplay.anchorY=0
	Interface.ManaDisplay.x=Interface.LifeDisplay.x
	Interface.ManaDisplay.y=Interface.LifeDisplay.y+60
	psg:insert(Interface.ManaDisplay)

	local ManaSymbol=display.newSprite( manasheet, {name="mana",start=1,count=3,time=500} )
	ManaSymbol.anchorX=0
	ManaSymbol.anchorY=0
	ManaSymbol.yScale=1.0625
	ManaSymbol.xScale=1.0625
	ManaSymbol.x = Interface.ManaDisplay.x-70
	ManaSymbol.y = Interface.ManaDisplay.y+5
	ManaSymbol:play()
	psg:insert(ManaSymbol)
	
	
	
	Interface.EnergyDisplay = display.newText((p1["STATS"]["Energy"].."/"..p1["STATS"]["MaxEnergy"]),0,0,"Game Over",100)
	Interface.EnergyDisplay.anchorX=0
	Interface.EnergyDisplay.anchorY=0
	Interface.EnergyDisplay.x=Interface.ManaDisplay.x
	Interface.EnergyDisplay.y=Interface.ManaDisplay.y+60
	psg:insert(Interface.EnergyDisplay)
	
	local EnergySymbol=display.newSprite( energysheet, {name="energy",start=1,count=4,time=500} )
	EnergySymbol.anchorX=0
	EnergySymbol.anchorY=0
	EnergySymbol.yScale=1.0625
	EnergySymbol.xScale=1.0625
	EnergySymbol.x = Interface.EnergyDisplay.x-70
	EnergySymbol.y = Interface.EnergyDisplay.y+5
	EnergySymbol:play()
	psg:insert(EnergySymbol)
	
	psg.isVisible=false
	]]
	--[[
	local backdrop=CreateWindow(360,200)
	backdrop.y=display.contentHeight-50
	psg:insert(backdrop)
	
	local bar1=display.newImageRect("ui/bar.png",438,48)
	bar1.xScale=1.0
	bar1.yScale=1.2
	bar1.x=display.contentCenterX
	bar1.y=display.contentHeight-130
	bar1:setFillColor(1,0,0)
	psg:insert(bar1)
	
	local bar1fill=display.newRoundedRect(0,0,436,46,17)
	bar1fill.xScale=bar1.xScale
	bar1fill.yScale=bar1.yScale
	bar1fill.x=bar1.x-(bar1fill.width*bar1.xScale/2)
	bar1fill.y=bar1.y
	bar1fill:setFillColor(1,0.2,0.2)
	bar1fill.anchorX=0
	bar1fill.max=bar1fill.width
	psg:insert(bar1fill)
	
	Interface.bar1fill=bar1fill
	
	bar1:toFront()
	
	local bar2=display.newImageRect("ui/bar.png",438,48)
	bar2.xScale=0.9
	bar2.yScale=bar2.xScale
	bar2.x=bar1.x
	bar2.y=bar1.y+55
	bar2:setFillColor(0.8,0,1)
	psg:insert(bar2)
	
	local bar2fill=display.newRoundedRect(0,0,436,46,17)
	bar2fill.xScale=bar2.xScale
	bar2fill.yScale=bar2.yScale
	bar2fill.x=bar2.x-(bar2fill.width*bar2.xScale/2)
	bar2fill.y=bar2.y
	bar2fill:setFillColor(0.6,0.2,0.8)
	bar2fill.anchorX=0
	bar2fill.max=bar2fill.width
	psg:insert(bar2fill)
	
	Interface.bar2fill=bar2fill
	
	bar2:toFront()
	
	local bar3=display.newImageRect("ui/bar.png",438,48)
	bar3.xScale=0.9
	bar3.yScale=bar3.xScale
	bar3.x=bar2.x
	bar3.y=bar2.y+50
	bar3:setFillColor(0,1,0)
	psg:insert(bar3)
	
	local bar3fill=display.newRoundedRect(0,0,436,46,17)
	bar3fill.xScale=bar3.xScale
	bar3fill.yScale=bar3.yScale
	bar3fill.x=bar3.x-(bar3fill.width*bar3.xScale/2)
	bar3fill.y=bar3.y
	bar3fill:setFillColor(0.2,1,0.2)
	bar3fill.anchorX=0
	bar3fill.max=bar3fill.width
	psg:insert(bar3fill)
	
	Interface.bar3fill=bar3fill
	
	bar3:toFront()
	
	-- EL CORAZONCITO (?)
	
	Interface.HeartSymbol={}
	Interface.HeartSymbol["ANIMATIONS"]=readAnims("ui/HeartAnim.json")
	Interface.HeartSymbol["CURFRAME"]=1
	Interface.HeartSymbol["SEQUENCE"]="BEAT"
	Interface.HeartSymbol["SCALE"]=1
	
	
	Interface.HeartSymbol["ASSETS"]={}
	Interface.HeartSymbol["ASSETS"][1]=display.newImageRect("ui/Outline.png",112,96)
	Interface.HeartSymbol["ASSETS"][1].x=bar1fill.x
	Interface.HeartSymbol["ASSETS"][1].y=bar1fill.y
	Interface.HeartSymbol["ASSETS"][1].name="Outline"
	
	Interface.HeartSymbol["ASSETS"][2]=display.newImageRect("ui/Fill.png",106,91)
	Interface.HeartSymbol["ASSETS"][2].x=Interface.HeartSymbol["ASSETS"][1].x
	Interface.HeartSymbol["ASSETS"][2].y=Interface.HeartSymbol["ASSETS"][1].y
	Interface.HeartSymbol["ASSETS"][2].name="Outline"
	
	Interface.HeartSymbol["TIME"]=1.0
	Interface.HeartSymbol["LASTTIME"]=1.0
	
	Interface.HeartSymbol.saturation=function()
		for i=1,table.maxn(Interface.HeartSymbol["ASSETS"]) do
			if Interface.HeartSymbol["TIME"]>=2.5 then
				Interface.HeartSymbol["ASSETS"][i].fill.effect.intensity = -3.75
			elseif (Interface.HeartSymbol["TIME"]>1) and Interface.HeartSymbol["TIME"]<2.5 then
				Interface.HeartSymbol["ASSETS"][i].fill.effect.intensity = Interface.HeartSymbol["TIME"]*(1-Interface.HeartSymbol["TIME"])
			elseif (Interface.HeartSymbol["TIME"]<1) then
				if (1-Interface.HeartSymbol["TIME"])*2>1 then
					Interface.HeartSymbol["ASSETS"][i].fill.effect.intensity = 1
				else
					Interface.HeartSymbol["ASSETS"][i].fill.effect.intensity = (1-Interface.HeartSymbol["TIME"])*2
				end
			else
				Interface.HeartSymbol["ASSETS"][i].fill.effect.intensity = 0
			end
		end
		Interface.HeartSymbol["LASTTIME"]=Interface.HeartSymbol["TIME"]
	end
	Interface.HeartSymbol.refresh=function()
	Interface.HeartSymbol:refresh()
	psg:insert(Interface.HeartSymbol["ASSETS"][1])
	psg:insert(Interface.HeartSymbol["ASSETS"][2])
	
	psg.x=psg.x+50
	
	Interface.statcheck=-1
	--]]
	-- Interface["EXP"]
	-- Interface.showncd=1
	
	-- local XPSymbol=display.newSprite( xpsheet, { name="xpbar", start=1, count=50, time=(2000) }  )
	-- XPSymbol.x = display.contentCenterX
	-- XPSymbol.y = 180
	-- XPSymbol:toFront()
	-- XPSymbol.shown=false
	-- XPSymbol:setFillColor(1,1,1,xptransp)
	
	-- local XPDisplay=display.newText( (((XPSymbol.frame-1)*2).."%"), 0, 0, "Game Over", 85 )
	-- XPDisplay.x = XPSymbol.x
	-- XPDisplay.y = XPSymbol.y
	-- XPDisplay:toFront()
	-- XPDisplay:setFillColor( 0, 0, 0,xptransp)
	
	-- Runtime:addEventListener("enterFrame",Interface.ExperienceFader)
	-- Runtime:addEventListener("enterFrame",Interface.refresh)
end

function Interface:refresh()
	Interface.statcheck=Interface.statcheck+1
	if Interface.statcheck==120 then
		-- p1:checkStats()
		Interface.statcheck=-1
	end
	
	-- local healthpercentage=(p1["STATS"]["Health"]/p1["STATS"]["MaxHealth"])
	-- if Interface.bar1fill.width~=Interface.bar1fill.max*healthpercentage then
		-- Interface.LifeDisplay.text=((p1["STATS"]["Health"].."/"..p1["STATS"]["MaxHealth"]))
	
		-- Interface.bar1fill.width=Interface.bar1fill.max*healthpercentage
	-- end
	--[[
	if ((p1["STATS"]["Health"].."/"..p1["STATS"]["MaxHealth"]))~=Interface.LifeDisplay.text then
		Interface.LifeDisplay.text=((p1["STATS"]["Health"].."/"..p1["STATS"]["MaxHealth"]))
		
		-- LifeSymbol:toFront()
		-- LifeDisplay:toFront()
	end
	
	if ((p1["STATS"]["Mana"].."/"..p1["STATS"]["MaxMana"]))~=Interface.ManaDisplay.text then -- Text Update
		Interface.ManaDisplay.text=((p1["STATS"]["Mana"].."/"..p1["STATS"]["MaxMana"]))
		
		-- ManaSymbol:toFront()
		-- ManaDisplay:toFront()
	end
	
	if ((p1["STATS"]["Energy"].."/"..p1["STATS"]["MaxEnergy"]))~=Interface.EnergyDisplay.text then -- Text Update
		Interface.EnergyDisplay.text=((p1["STATS"]["Energy"].."/"..p1["STATS"]["MaxEnergy"]))
		
		-- EnergySymbol:toFront()
		-- EnergyDisplay:toFront()
	end
	]]
end

function Interface:Fanfare()
	-- a.Play(9)
	if not (LvlWindow) then
		lvltransp=255
		LvlWindow=display.newImageRect("ui/fanfarelevelup.png",330,142)
		LvlWindow.xScale=2
		LvlWindow.yScale=LvlWindow.xScale
		LvlWindow.x=display.contentCenterX
		LvlWindow.y=display.contentCenterY-250
		LvlWindow:toFront()
		LvlWindow:setFillColor( lvltransp, lvltransp, lvltransp, lvltransp)
		timer.performWithDelay(10,LvlFanfare)
	else
		if lvltransp<20 then
			lvltransp=0
			display.remove(LvlWindow)
			LvlWindow=nil
		else
			lvltransp=lvltransp-(255/50)
			LvlWindow:setFillColor( lvltransp, lvltransp, lvltransp, lvltransp)
			LvlWindow:toFront()
			timer.performWithDelay(2,LvlFanfare)
		end
	end
end

function Interface:ExperienceFader()
	if XPSymbol.shown==true then
		-- print "SHOWN"
		if xptransp<1 then
			-- print "NOT IN POSITION"
			xptransp=xptransp+.1
			XPSymbol:setFillColor(1,1,1,xptransp)
			XPDisplay:setFillColor( 0, 0, 0,xptransp)
		elseif xptransp>=1 then
			-- print "IN POSITION"
			-- mpBar2:setFrame(math.floor(( (pMPcnt/p1["STATS"]["MaxMana"])*66 )+1))
			if XPSymbol.frame<(math.floor(( (p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"])*49 )+1)) and XPSymbol.frame~=50 then
				-- print ("ADDING FRAMES")
				XPSymbol:setFrame(XPSymbol.frame+1)
				XPDisplay.text=(math.ceil(p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"]*100).."%")
				
				showncd=60
			elseif XPSymbol.frame>(math.floor(( (p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"])*49 )+1)) then
				-- print ("RESETTING FRAMES")
				XPSymbol:setFrame(1)
				XPDisplay.text=(math.ceil(p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"]*100).."%")
			elseif XPSymbol.frame>=50 and p1["STATS"]["MaxExperience"]<=p1["STATS"]["Experience"] then
				-- print ("LEVELING UP")
				p1.lvl=p1.lvl+1
				local profit=p1["STATS"]["Experience"]-p1["STATS"]["MaxExperience"]
				p1["STATS"]["Experience"]=0+profit
				p1["STATS"]["MaxExperience"]=p1.lvl*50
				
				p1.pnts=p1.pnts+4
				
				LvlFanfare()
			else
				-- print ("COUNT UPDATED")
				showncd=showncd-1
				if showncd==0 then
					XPSymbol.shown=false
				end
			end
		end
	elseif XPSymbol.shown==false then
		-- print "HIDDEN"
		if xptransp>0 then
			-- print "NOT IN POSITION"
			xptransp=xptransp-.1
			XPSymbol:setFillColor(1,1,1,xptransp)
			XPDisplay:setFillColor( 0, 0, 0,xptransp)
		elseif xptransp<=0 then
			-- print "IN POSITION"
			if XPSymbol.frame~=(math.floor(( (p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"])*49 )+1)) then
				-- print "XP ISNT COUNT"
				XPSymbol.shown=true
			else
				-- print "XP IS COUNT"
			end
		end
	end
end


---------------------------------------------------------------------------------------
-- GOLD DISPLAY
---------------------------------------------------------------------------------------

function CallAddCoins()
	-- a.Play(1)
	p1["GOLD"]=p1["GOLD"]+1
end

function GoldDisplay()
	if not (gwg) then
		gwg=display.newGroup()
		showncd=1
		
		GWindow = CreateWindow(200,75)
		GWindow.x=display.contentWidth-80
		GWindow.y=145
		GWindow:setFillColor(1,0.3,0.3)
		gwg:insert(GWindow)
		
		CDisplay=display.newSprite( coinsheet, { name="coin", start=1, count=8, time=750}  )
		CDisplay.anchorX=0
		CDisplay.anchorY=0
		CDisplay.x, CDisplay.y = GWindow.x-80, GWindow.y-20
		CDisplay.xScale=DisplayS
		CDisplay.yScale=DisplayS
		CDisplay:toFront()
		CDisplay:play()
		gwg:insert(CDisplay)
		
		GCDisplay = display.newText( (GoldCount),0,0, "Game Over", 100 )
		GCDisplay.anchorX=0
		GCDisplay.anchorY=0
		GCDisplay.x,GCDisplay.y=CDisplay.x+60,CDisplay.y-10
		GCDisplay:setFillColor( 1, 1, 0.2)
		gwg:insert(GCDisplay)
		
		Runtime:addEventListener("enterFrame",MoveWindow)
	end
end

function MoveWindow()
	if (gwg) then
		local shownx=0
		local hiddenx=200
		if gShown==true and gwg.x~=shownx then
			-- print ("SHOWN; NOT IN POSITION")
			if gwg.x<shownx then
				gwg.x=gwg.x+5
			elseif gwg.x>shownx then
				gwg.x=gwg.x-5
			end
		elseif gShown==true and gwg.x==shownx then
			-- print ("SHOWN; IN POSITION")
			if GoldCount~=p1["GOLD"] then
				-- print ("UPDATING COUNT")
				if GoldCount<p1["GOLD"] then
					GoldCount=GoldCount+1
				elseif GoldCount>p1["GOLD"] then
					GoldCount=GoldCount-1
				end
				GCDisplay.text=(GoldCount)
				
				GCDisplay:setFillColor( 1, 1, 0.20)
				showncd=150
			else
				-- print ("COUNT UPDATED")
				showncd=showncd-1
				if showncd==0 then
					gShown=false
				end
			end
		elseif gShown==false and gwg.x~=hiddenx then
			-- print ("HIDDEN; NOT IN POSITION")
			if gwg.x<hiddenx then
				gwg.x=gwg.x+5
			elseif gwg.x>hiddenx then
				gwg.x=gwg.x-5
			end
		elseif gShown==false and gwg.x==hiddenx and p1["GOLD"]~=GoldCount then
			-- print ("HIDDEN; IN POSITION; GP ISNT COUNT")
			gShown=true
		elseif gShown==false and gwg.x==hiddenx then
			-- print ("HIDDEN; IN POSITION; GP IS COUNT")
		end
	end
end

function CleanCounter()
	display.remove(CDisplay)
	CDisplay=nil
	display.remove(GCDisplay)
	GCDisplay=nil
	display.remove(GWindow)
	GWindow=nil
end


---------------------------------------------------------------------------------------
-- CONTROLS
---------------------------------------------------------------------------------------

local pcg
Controls={}

function Controls:show()
	pcg=display.newGroup()
	
	Controls.joybkg=display.newImageRect("ui/joybkg.png",270,270)
	Controls.joybkg.x=150
	Controls.joybkg.y=display.contentHeight-150
	pcg:insert(Controls.joybkg)
	Controls.joybkg:setFillColor(1,1,1,0.4)
	
	Controls.joy=display.newImageRect("ui/joy.png",100,100)
	Controls.joy.x=Controls.joybkg.x
	Controls.joy.y=Controls.joybkg.y
	Controls.joy:setFillColor(1,1,1,0.6)
	pcg:insert(Controls.joy)
	local function wrapper(event)
		Controls:joystickHandler(event)
	end
	Runtime:addEventListener("touch",wrapper)
	
	local abutton=widget.newButton{
		font=native.systemFont,
		defaultFile="ui/circlebutton.png",
		overFile="ui/circlebutton_hold.png",
		width=80, height=80,
		onRelease=game.Controls.buttonPress
	}
	abutton.x = display.contentWidth-120
	abutton.y = display.contentHeight-120
	abutton.xScale = 2
	abutton.yScale = abutton.xScale
	pcg:insert(abutton)
	abutton:setFillColor(1,0,0,0.6)
	
	Controls.x=0
	Controls.y=0
	
	-- pcg.isVisible=false
	
	Controls.joy.isVisible=false
	-- Controls.joybkg.isVisible=false
	
	-- transit=col.getparticles()
	-- return transit
end

function Controls:joystickHandler( event )
	if isPaused==false then
		if event.x>display.contentCenterX then
			event.phase="ended"
		end
		if event.phase=="began" then
			Runtime:addEventListener("enterFrame",Controls.toGame)
			Controls.joy.isVisible=true
			-- Controls.joybkg.isVisible=true
		end
		if event.phase~="ended" then
		
			pcg:toFront()
			
			Controls.joy.x=event.x
			Controls.joy.y=event.y
			
			Controls.x=Controls.joy.x-Controls.joybkg.x
			Controls.y=Controls.joy.y-Controls.joybkg.y
			local h=math.sqrt( (Controls.x^2)+(Controls.y^2) )
			
			local r=125
			if h>r then
				local vx=Controls.x/h
				local vy=Controls.y/h
				Controls.x=vx*r
				Controls.y=vy*r
				
				Controls.joy.x=Controls.joybkg.x+Controls.x
				Controls.joy.y=Controls.joybkg.y+Controls.y
			end
		end
		if event.phase=="ended" then
			Controls.joy.isVisible=false
			-- Controls.joybkg.isVisible=false
			Runtime:removeEventListener("enterFrame",Controls.toGame)
			Controls.x=0
			Controls.y=0
			Controls.joy.x=Controls.joybkg.x
			Controls.joy.y=Controls.joybkg.y
			Controls:toGame()
		end
	end
end

function Controls:toGame()
	game.Controls:Check(Controls.x,Controls.y)
end


---------------------------------------------------------------------------------------
-- INVENTORY WINDOW
---------------------------------------------------------------------------------------

function OpenBag()
	local approve=canWindowCheck()
	if approve==true then
		ToggleBag()
	end
end

function ToggleBag(sound)
	if isOpn==false then
		if sound~=false then
			-- a.Play(3)
		end
		invg=display.newGroup()
		items={}
		curreqp={}
		toggleState()
		
		bkg=ui.CreateWindow(750,730)
		bkg.x,bkg.y = display.contentWidth/2, 600
		invg:insert( bkg )
		
		invinterface=display.newImageRect("ui/container.png", 570, 507)
		invinterface.x,invinterface.y = bkg.x,bkg.y+27
		invinterface.xScale,invinterface.yScale=1.28,1.28
		invg:insert( invinterface )
		
		CloseBtn=widget.newButton{
			label="X",
			labelColor = { default={255,255,255}, over={0,0,0} },
			fontSize=50,
			font=native.systemFont,
			defaultFile="ui/sbutton.png",
			overFile="ui/sbutton-over.png",
			width=80, height=80,
			onRelease = ForceClose}
		CloseBtn.xScale,CloseBtn.yScale=0.75,0.75
		CloseBtn.x = display.contentWidth-50
		CloseBtn.y = bkg.y-326
		invg:insert( CloseBtn )
		
		InvCheck()
		
		for i=1,table.maxn(p1.inv) do
			if (p1.inv[i])~=nil then
				local iteminfo=item.ReturnInfo(p1.inv[i][1],0)
				
	--			print ("Player has "..p1.inv[i][2].." of "..itmnme..".")
	
				items[#items+1]=display.newImageRect( "items/"..iteminfo.name..".png" ,64,64)
				items[#items].xScale=scale
				items[#items].yScale=scale
				items[#items].x = invinterface.x-322+(((#items-1)%9)*(espacio+(3*1.28)))
				items[#items].y = invinterface.y-282+((math.floor((#items-1)/9))*(espacio+(3*1.28)))
				function Gah()
					UseMenu(p1.inv[i][1],i)
				end
				items[#items]:addEventListener("tap",Gah)
				invg:insert( items[#items] )
				if p1.inv[i][2]~=1 then
					if p1.inv[i][2]>9 then
						items[#items].num=display.newText( (p1.inv[i][2]) ,0,0,"Game Over",80)
						items[#items].num.anchorX=0
						items[#items].num.anchorY=0
						items[#items].num.x=items[#items].x+5
						items[#items].num.y=items[#items].y-5
						invg:insert( items[#items].num )
					elseif p1.inv[i][2]<=9 then
						items[#items].num=display.newText( (p1.inv[i][2]) ,0,0,"Game Over",80)
						items[#items].num.anchorX=0
						items[#items].num.anchorY=0
						items[#items].num.x=items[#items].x+15
						items[#items].num.y=items[#items].y-5
						invg:insert( items[#items].num )
					end
				end
			end
		end
		
		for i=1,table.maxn(p1.eqp) do
			if (p1.eqp[i])~=nil then
				local iteminfo=item.ReturnInfo(p1.eqp[i][1],0)
	--			print ("Player has "..itmnme.." equipped in slot number "..p1.eqp[i][2]..".")
				curreqp[#curreqp+1]=display.newImageRect( "items/"..iteminfo.name..".png" ,64,64)
				curreqp[#curreqp].xScale=scale
				curreqp[#curreqp].yScale=scale
				if p1.eqp[i][2]==6 then
					plcmnt=1
				elseif p1.eqp[i][2]==2 then
					plcmnt=2
				elseif p1.eqp[i][2]==3 then
					plcmnt=3
				elseif p1.eqp[i][2]==0 then
					plcmnt=4
				elseif p1.eqp[i][2]==4 then
					plcmnt=5
				elseif p1.eqp[i][2]==1 then
					plcmnt=6
				elseif p1.eqp[i][2]==7 then
					plcmnt=7
				elseif p1.eqp[i][2]==5 then
					plcmnt=8
				elseif p1.eqp[i][2]==8 then
					plcmnt=9
				end
				curreqp[#curreqp].x = invinterface.x-322+(((plcmnt-1)%9)*(espacio+(3*1.28)))
				curreqp[#curreqp].y = invinterface.y+(64*5)-38
				function Argh()
					CheckMenu(p1.eqp[i][1])
				end
				curreqp[#curreqp]:addEventListener("tap",Argh)
				invg:insert( curreqp[#curreqp] )
			end
		end
		invg:toFront()
		if table.maxn(p1.inv)==0 then
	--		print "Inventory is empty."
		end
		if table.maxn(p1.eqp)==0 then
	--		print "Player has nothing equipped."
		end
	elseif isOpn==true and (invg) then
		if sound~=false then
			-- a.Play(4)
		end
		
		toggleState()
		if isUse==false then
			for i=table.maxn(items),1,-1 do
				display.remove(items[i])
				items[i]=nil
			end
			items=nil
			for i=table.maxn(curreqp),1,-1 do
				display.remove(curreqp[i])
				curreqp[i]=nil
			end
			curreqp=nil
			for i=invg.numChildren,1,-1 do
				display.remove(invg[i])
				invg[i]=nil
			end
			invg=nil
		else
			SpecialUClose()
			for i=table.maxn(items),1,-1 do
				display.remove(items[i])
				items[i]=nil
			end
			items=nil
			for i=table.maxn(curreqp),1,-1 do
				display.remove(curreqp[i])
				curreqp[i]=nil
			end
			curreqp=nil
			for i=invg.numChildren,1,-1 do
				display.remove(invg[i])
				invg[i]=nil
			end
			invg=nil
		end
		
	end
end

function AddItem(id,stacks,amount)
	local itmnme=item.ReturnInfo(id,0)
	local ItemAdded=false
	if not (amount) then
		amount=1
	end
	if table.maxn(p1.inv)==63 then
	--	print "Inventory is full!"
		return false
	elseif table.maxn(p1.inv)==0 then
		p1.inv[(#p1.inv+1)]={}
		p1.inv[(#p1.inv)][1]=id
		p1.inv[(#p1.inv)][2]=amount
	--	print ("Player now has "..p1.inv[1][2].." of "..itmnme..".")
	else
		for i=1, table.maxn(p1.inv) do
			if ItemAdded==false then
				if p1.inv[i] and p1.inv[i][1]==id and stacks==true then
						p1.inv[i][2]=((p1.inv[i][2])+amount)
		--				print ("Player now has "..p1.inv[i][2].." of "..itmnme..".")
						ItemAdded=true
				elseif i==(table.maxn(p1.inv)-1) then
				end
			end
		end
		if ItemAdded==false then
			p1.inv[(#p1.inv+1)]={}
			p1.inv[(#p1.inv)][1]=id
			p1.inv[(#p1.inv)][2]=amount
		--	print ("Player now has "..p1.inv[#p1.inv][2].." of "..itmnme..".")
			ItemAdded=true
		end
	end
end

function UseMenu(id,slot)
	if isUse==false then
		if id~=false then
			-- a.Play(3)
		end
	
		function UsedIt()
			isUse=false
			for i=umg.numChildren,1,-1 do
				local child = umg[i]
				child.parent:remove( child )
			end
			umg=nil
			p1.inv[slot][2]=p1.inv[slot][2]-1
			if p1.inv[slot][2]==0 then
				table.remove( p1.inv, slot )
			end
			if iteminfo.use==0 then
				if iteminfo.stats[1]<0 then
					p.ReduceHP((iteminfo.amount*-1),"Poison")
				elseif iteminfo.stats[1]>0 then
					p.AddHP(iteminfo.amount)
				end
				ToggleBag()
				ToggleBag()
			elseif iteminfo.use==1 then
				p.AddMP(iteminfo.amount)
				ToggleBag()
				ToggleBag()
			elseif iteminfo.use==2 then
				p.AddEP(iteminfo.amount)
				ToggleBag()
				ToggleBag()
			else
				ToggleBag()
				ui.Pause(true)
				if iteminfo.purpose==0 then
					WD.FloorPort(false)
				elseif iteminfo.purpose==1 then
					WD.FloorPort(true)
				elseif iteminfo.purpose==2 then
					b.Expand()
				end
			end
		end
		
		function LearnedIt()
			isUse=false
			p.LearnSorcery(iteminfo.spellid)
			for i=umg.numChildren,1,-1 do
				local child = umg[i]
				child.parent:remove( child )
			end
			umg=nil
			table.remove( p1.inv, slot )
			ToggleBag()
			ToggleBag()
		end
		
		function StatBoost()
			isUse=false
			p.StatBoost(iteminfo.statnum)
			for i=umg.numChildren,1,-1 do
				local child = umg[i]
				child.parent:remove( child )
			end
			umg=nil
			p1.inv[slot][2]=p1.inv[slot][2]-1
			if p1.inv[slot][2]==0 then
				table.remove( p1.inv, slot )
			end
			ToggleBag()
			ToggleBag()
		end
		
		function EquippedIt()
			-- a.Play(8)
			for i=1,table.maxn(p1.eqp) do
				if (p1.eqp[i]) and (p1.eqp[i][1]) and (p1.eqp[i][2]) and (p1.eqp[i][2]==iteminfo.slot) then
					p1.inv[#p1.inv+1]={}
					p1.inv[#p1.inv][1]=p1.eqp[i][1]
					p1.inv[#p1.inv][2]=1
					table.remove( p1.eqp, (i) )
				end
			end
			
			p1.eqp[#p1.eqp+1]={}
			p1.eqp[#p1.eqp][1]=id
			p1.eqp[#p1.eqp][2]=iteminfo.slot
			
			if (iteminfo.slot==0) then
				p1.weapon="armed"
			end
			
			isUse=false
			for i=umg.numChildren,1,-1 do
				local child = umg[i]
				child.parent:remove( child )
			end
			umg=nil
			
			table.remove( p1.inv, slot )
			
			ToggleBag()
			ToggleBag()
			p.ModStats(statchange[1],statchange[2],statchange[3],statchange[4],statchange[5],statchange[6],statchange[7])
			statchange={}
		end
		
		function DroppedIt()
			statchange={}
			isUse=false
			for i=umg.numChildren,1,-1 do
				local child = umg[i]
				child.parent:remove( child )
			end
			umg=nil
			table.remove( p1.inv, slot )
			ToggleBag()
			ToggleBag()
		end
		
		umg=display.newGroup()
		umg:toFront()
		isUse=true
		
	--	print ("Player wants to use item "..id..", in slot "..slot..".")
		window=ui.CreateWindow(768,308)
		window.x,window.y = display.contentWidth/2, 450
		umg:insert( window )
		
		for i=1,table.maxn(items) do
			if items[i] then
				items[i]:removeEventListener("tap",Gah)
			end
		end
		for i=1,table.maxn(curreqp) do
			if curreqp[i] then
				curreqp[i]:removeEventListener("tap",Argh)
			end
		end
		
		local backbtn=  widget.newButton{
			label="Back",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=200, height=55,
			onRelease = UseMenu}
		backbtn.x = (display.contentWidth/2)
		backbtn.y = (display.contentHeight/2)+30
		umg:insert( backbtn )
		
		local dropbtn=  widget.newButton{
			label="Drop",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=200, height=55,
			onRelease = DroppedIt}
		dropbtn.x = ((display.contentWidth/4)*3)+50
		dropbtn.y = (display.contentHeight/2)+30
		umg:insert( dropbtn )
		
		iteminfo=item.ReturnInfo(id)
		
		local lolname=display.newText( (iteminfo.name) ,0,0,"MoolBoran",90)
		lolname.x=display.contentWidth/2
		lolname.y=(display.contentHeight/2)-150
		umg:insert( lolname )
		
		if iteminfo.type==0 then --Regular items
			local usebtn=  widget.newButton{
				label="Use",
				labelColor = { default={255,255,255}, over={0,0,0} },
				font="MoolBoran",
				fontSize=50,
				labelYOffset=10,
				defaultFile="ui/cbutton.png",
				overFile="ui/cbutton-over.png",
				width=200, height=55,
				onRelease = UsedIt
			}
			usebtn.x = (display.contentWidth/4)-50
			usebtn.y = (display.contentHeight/2)+30
			umg:insert( usebtn )
			
			local descrip=display.newText( (iteminfo.descrip) ,0,0,"MoolBoran",55)
			descrip.y=(display.contentHeight/2)-50
			descrip.x=display.contentWidth/2
			descrip:setFillColor( 0.7, 0.7, 0.7)
			umg:insert( descrip )
		end	
		if iteminfo.type==1 then --Equipments
			local equipbtn=  widget.newButton{
				label="Equip",
				labelColor = { default={255,255,255}, over={0,0,0} },
				font="MoolBoran",
				fontSize=50,
				labelYOffset=10,
				defaultFile="ui/cbutton.png",
				overFile="ui/cbutton-over.png",
				width=200, height=55,
				onRelease = EquippedIt
			}
			equipbtn.x = (display.contentWidth/4)-50
			equipbtn.y = (display.contentHeight/2)+30
			umg:insert( equipbtn )
			
			local itmfound=false
			local equipstats
			for i=1,table.maxn(p1.eqp) do
				if p1.eqp[i][2]==iteminfo.slot then
					equipstats=item.ReturnInfo(p1.eqp[i][1])
					itmfound=true
				end
			end
			
			if itmfound==false then
				equipstats={}
				equipstats.armor=0
				equipstats.stats={0,0,0,0,0,0,}
			end
			
			statchange={
				iteminfo.stats[1]-equipstats.stats[1],
				iteminfo.stats[2]-equipstats.stats[2],
				iteminfo.stats[3]-equipstats.stats[3],
				iteminfo.stats[4]-equipstats.stats[4],
				iteminfo.stats[5]-equipstats.stats[5],
				iteminfo.stats[6]-equipstats.stats[6],
				iteminfo.armor-equipstats.armor
			}
			stattxts={}
			
			local eqpstatchnge=false
			local stats={"CON","DEX","STR","MGC","STA","INT","ARMOR"}
			for c=1,7 do
				if statchange[c]>0 then
					stattxts[c]=display.newText( (stats[c].." +"..statchange[c]),0,0,"MoolBoran",60)
					stattxts[c]:setFillColor( 0.25, 0.7, 0.25)
					stattxts[c].x=statchangex+(statchangexs*((c-1)%3))
					stattxts[c].y=statchangey+(40*math.floor((c-1)/3))
					umg:insert( stattxts[c] )
					eqpstatchnge=true
					if c==7 then
						stattxts[c].x=statchangex+statchangexs
					end
				elseif statchange[c]<0 then
					stattxts[c]=display.newText( (stats[c].." "..statchange[c]) ,0,0,"MoolBoran",60)
					stattxts[c]:setFillColor( 0.7, 0.25, 0.25)
					stattxts[c].x=statchangex+(statchangexs*((c-1)%3))
					stattxts[c].y=statchangey+(40*math.floor((c-1)/3))
					umg:insert( stattxts[c] )
					eqpstatchnge=true
					if c==7 then
						stattxts[c].x=statchangex+statchangexs
					end
				end
			end
			
			if eqpstatchnge==false then
				stattxts[1]=display.newText( "No change." ,0,0,"MoolBoran",55)
				stattxts[1]:setFillColor( 0.7, 0.7, 0.7)
				stattxts[1].y=(display.contentHeight/2)-50
				stattxts[1].x=display.contentWidth/2
				umg:insert( stattxts[1] )
			end
		end
		if iteminfo.type==2 then --Specials
			if itemstats[4]==0 or itemstats[4]==1 then
				local usebtn=  widget.newButton{
					label="Teleport",
					labelColor = { default={255,255,255}, over={0,0,0} },
					font="MoolBoran",
					fontSize=50,
					labelYOffset=10,
					defaultFile="ui/cbutton.png",
					overFile="ui/cbutton-over.png",
					width=200, height=55,
					onRelease = UsedIt
				}
				usebtn.x = (display.contentWidth/4)-50
				usebtn.y = (display.contentHeight/2)+30
				umg:insert( usebtn )
			elseif itemstats[4]==2 then
				local usebtn=  widget.newButton{
					label="Expand",
					labelColor = { default={255,255,255}, over={0,0,0} },
					font="MoolBoran",
					fontSize=50,
					labelYOffset=10,
					defaultFile="ui/cbutton.png",
					overFile="ui/cbutton-over.png",
					width=200, height=55,
					onRelease = UsedIt
				}
				usebtn.x = (display.contentWidth/4)-50
				usebtn.y = (display.contentHeight/2)+30
				umg:insert( usebtn )
			end
			
			local descrip=display.newText( (iteminfo.descrip) ,0,0,"MoolBoran",55)
			descrip.y=(display.contentHeight/2)-50
			descrip.x=display.contentWidth/2
			descrip:setFillColor( 0.7, 0.7, 0.7)
			umg:insert( descrip )
		end
		if iteminfo.type==3 then --Scrolls
			local learnbtn=  widget.newButton{
				label="Learn",
				labelColor = { default={255,255,255}, over={0,0,0} },
				font="MoolBoran",
				fontSize=50,
				labelYOffset=10,
				defaultFile="ui/cbutton.png",
				overFile="ui/cbutton-over.png",
				width=200, height=55,
				onRelease = LearnedIt
			}
			learnbtn.x = (display.contentWidth/4)-50
			learnbtn.y = (display.contentHeight/2)+30
			umg:insert( learnbtn )
			
			local descrip=display.newText( (item.info.descrip) ,0,0,"MoolBoran",55)
			descrip.y=(display.contentHeight/2)-50
			descrip.x=display.contentWidth/2
			descrip:setFillColor( 0.7, 0.7, 0.7)
			umg:insert( descrip )
			
		end
		if iteminfo.type==4 then --Boosters
			local boostbtn=  widget.newButton{
				label="Use",
				labelColor = { default={255,255,255}, over={0,0,0} },
				font="MoolBoran",
				fontSize=50,
				labelYOffset=10,
				defaultFile="ui/cbutton.png",
				overFile="ui/cbutton-over.png",
				width=200, height=55,
				onRelease = StatBoost
			}
			boostbtn.x = (display.contentWidth/4)-50
			boostbtn.y = (display.contentHeight/2)+30
			umg:insert( boostbtn )
			
			local descrip=display.newText( (iteminfo.descrip) ,0,0,"MoolBoran",55)
			descrip.y=(display.contentHeight/2)-50
			descrip.x=display.contentWidth/2
			descrip:setFillColor( 0.7, 0.7, 0.7)
			umg:insert( descrip )
			
		end
		
	elseif isUse==true then
		if id~=false then
			-- a.Play(4)
		end
		SpecialUClose()
		ToggleBag(false)
		ToggleBag(false)
	end
end

function CheckMenu(id)
	if isUse==false then
		umg=display.newGroup()
		umg:toFront()
		isUse=true
		
	--	print ("Player wants to use item "..id..", in slot "..slot..".")
		window=ui.CreateWindow(768, 308)
		window.x,window.y = display.contentWidth/2, 450
		umg:insert( window )
		
		for i=1,table.maxn(items) do
			if items[i] then
				items[i]:removeEventListener("tap",Gah)
			end
		end
		for i=1,table.maxn(curreqp) do
			if curreqp[i] then
				curreqp[i]:removeEventListener("tap",Argh)
			end
		end
		
		local backbtn=  widget.newButton{
			label="Back",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=200, height=55,
			onRelease = CheckMenu}
		backbtn.x = (display.contentWidth/2)
		backbtn.y = (display.contentHeight/2)+30
		umg:insert( backbtn )
		
		itemstats=item.ReturnInfo(id)
		
		local lolname=display.newText( (itemstats.name) ,0,0,"MoolBoran",90)
		lolname.x=display.contentWidth/2
		lolname.y=(display.contentHeight/2)-150
		umg:insert( lolname )
		
		if iteminfo.type==1 then
			
			statchange={
				itemstats.stats[1],
				itemstats.stats[2],
				itemstats.stats[3],
				itemstats.stats[4],
				itemstats.stats[5],
				itemstats.stats[6],
				itemstats.armor
			}
			stattxts={}
			
			local stats={"CON","DEX","STR","MGC","STA","INT","ARMOR"}
			for c=1,7 do
				if statchange[c]>0 then
					stattxts[c]=display.newText( (stats[c].." +"..statchange[c]),0,0,"MoolBoran",60)
					stattxts[c]:setFillColor( 0.25, 0.7, 0.25)
					stattxts[c].x=statchangex+(statchangexs*((c-1)%3))
					stattxts[c].y=statchangey+(40*math.floor((c-1)/3))
					umg:insert( stattxts[c] )
					if c==7 then
						stattxts[c].x=statchangex+statchangexs
					end
				elseif statchange[c]<0 then
					stattxts[c]=display.newText( (stats[c].." "..statchange[c]) ,0,0,"MoolBoran",60)
					stattxts[c]:setFillColor( 0.7, 0.25, 0.25)
					stattxts[c].x=statchangex+(statchangexs*((c-1)%3))
					stattxts[c].y=statchangey+(40*math.floor((c-1)/3))
					umg:insert( stattxts[c] )
					if c==7 then
						stattxts[c].x=statchangex+statchangexs
					end
				end
			end
		end
	elseif isUse==true then
		SpecialUClose()
		ToggleBag()
		ToggleBag()
	end
end

function SpecialUClose()
	isUse=false
	statchange={}
	for i=umg.numChildren,1,-1 do
		local child = umg[i]
		child.parent:remove( child )
	end
	umg=nil
end

function SilentQuip(id)
	itemstats=item.ReturnInfo(id)
	p.ModStats(itemstats.stats[1],itemstats.stats[2],itemstats.stats[3],itemstats.stats[4],itemstats.stats[5],itemstats.stats[6],itemstats.armor)
	p1.eqp[#p1.eqp+1]={}
	p1.eqp[#p1.eqp][1]=id
	p1.eqp[#p1.eqp][2]=itemstats[3]
end


---------------------------------------------------------------------------------------
-- CHARACTER WINDOW
---------------------------------------------------------------------------------------

function OpenInfo()
	local approve=canWindowCheck()
	if approve==true then
		ToggleInfo()
	end
end

function ToggleInfo(sound)
	if isOpn==false then
		if sound~=false then
			-- a.Play(3)
		end
		
		toggleState()
		infwg=display.newGroup()
		info={}
		pli={}
		mini={}
		
		bkg=ui.CreateWindow(768,840)
		bkg.x,bkg.y = display.contentWidth/2, 605
		
		CloseBtn=widget.newButton{
			label="X",
			labelColor = { default={255,255,255}, over={0,0,0} },
			fontSize=50,
			font=native.systemFont,
			defaultFile="ui/button.png",
			overFile="ui/button_hold.png",
			width=80, height=80,
			onRelease = ForceClose}
		CloseBtn.xScale,CloseBtn.yScale=0.75,0.75
		CloseBtn.x,CloseBtn.y = display.contentWidth-30, bkg.y-390
		CloseBtn:setFillColor(1.0,0.2,0.2)
		
		
		StatInfo()
	elseif isOpn==true and (infwg) then
		if sound~=false then
			-- a.Play(4)
		end
		display.remove(bkg)
		bkg=nil
		toggleState()
		display.remove(CloseBtn)
		CloseBtn=nil
		for i=table.maxn(info),1,-1 do
			display.remove(info[i])
			info[i]=nil
		end
		info=nil
		for i=table.maxn(pli),1,-1 do
			display.remove(pli[i])
			pli[i]=nil
		end
		pli=nil
		for i=table.maxn(mini),1,-1 do
			display.remove(mini[i])
			mini[i]=nil
		end
		mini=nil
		for i=infwg.numChildren,1,-1 do
			display.remove(infwg[i])
			infwg[i]=nil
		end
		infwg=nil
	end
end

function StatChange()
	--[[
	for s=1,6 do
		info[#info+1]=display.newText(
			(
				p1["STATS"][s]["NAME"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].x=(display.contentWidth/4)+((display.contentWidth/2)*math.floor((s-1)%2))
		info[#info].y=110+(220*math.floor((s-1)/2))
		infwg:insert(info[#info])
	end
	for s=1,6 do
		info[#info+1]=display.newText(
			(
				p1.nat[s]
			),
			0,0,"MoolBoran",60
		)
		info[#info].x=info[#info-6].x
		info[#info].y=info[#info-6].y+80
		infwg:insert(info[#info])
	end
	for s=1,6 do
			pli[#pli+1]=  widget.newButton{
				defaultFile="ui/sbutton.png",
				overFile="ui/sbutton-over.png",
				font=native.systemFont,
				width=80, height=80,
				onRelease = More
			}
			pli[#pli].x = info[6+s].x+90
			pli[#pli].y = info[6+s].y-10
			infwg:insert(pli[#pli])
			
			pli[#pli+1]=display.newImageRect("ui/+.png",11,11)
			pli[#pli].x = pli[#pli-1].x
			pli[#pli].y = pli[#pli-1].y
			pli[#pli].xScale = 3.0
			pli[#pli].yScale = 3.0
			infwg:insert(pli[#pli])
		if p1.pnts>0 and p1.nat[s]<p1.lvl*10 then
		else
			pli[#pli]:setEnabled(false)
			pli[#pli]:setFillColor(0.5,0.5,0.5,0.5)
		end
	end
	for s=1,6 do
			mini[#mini+1]=  widget.newButton{
				defaultFile="ui/sbutton.png",
				overFile="ui/sbutton-over.png",
				font=native.systemFont,
				width=80, height=80,
				onRelease = Less
			}
			mini[#mini].x = info[6+s].x-90
			mini[#mini].y = info[6+s].y-10
			infwg:insert(mini[#mini])
		if p1.nat[s]>1 then
		else
			mini[#mini]:setEnabled(false)
			mini[#mini]:setFillColor(0.5,0.5,0.5,0.5)
		end
			
			mini[#mini+1]=display.newImageRect("ui/-.png",11,11)
			mini[#mini].x = mini[#mini-1].x
			mini[#mini].y = mini[#mini-1].y
			mini[#mini].xScale = 3.0
			mini[#mini].yScale = 3.0
			mini[#mini].isVisible=mini[#mini-1].isVisible
			infwg:insert(mini[#mini])
	end
	
	swapInfoBtn=  widget.newButton{
		defaultFile="ui/sbutton.png",
		overFile="ui/sbutton-over.png",
		font=native.systemFont,
		width=80, height=80,
		onRelease = SwapInfo}
	swapInfoBtn.x = display.contentWidth-60
	swapInfoBtn.y = display.contentHeight-280
	swapInfoBtn.state=true
	infwg:insert( swapInfoBtn )
	
	swapInfoImg=display.newImageRect("ui/plusminusinfo.png",70,70)
	swapInfoImg.x=swapInfoBtn.x
	swapInfoImg.y=swapInfoBtn.y
	swapInfoImg.xScale=0.7
	swapInfoImg.yScale=swapInfoImg.xScale
	infwg:insert(swapInfoImg)
	
	info[#info+1]=display.newText(
		(
			"Stat Management"
		),
		0,0,"MoolBoran",80
	)
	info[#info].anchorY=0
	info[#info].y=10
	info[#info].x=display.contentCenterX
	info[#info]:setFillColor(0.5,1,0.5)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("Stat Points: "..p1.pnts),0,0,"MoolBoran",60)
	info[#info].anchorY=0
	info[#info].y=730
	info[#info].x=display.contentCenterX
	infwg:insert(info[#info])
	if p1.pnts==0 then
		info[#info]:setFillColor(0.7,0.7,0.7)
	end
	infwg.y=200
	]]
end

function StatInfo()
--[[
	local baseX=50
	local baseY=90
	local SpacingX=350
	local SpacingY=50
	local symLength=16
	local primary=1
	local secundary=0.30
	
	info[1]=display.newText((p1["NAME"]),0,0,"MoolBoran",80)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=50
	info[#info].y=10
	infwg:insert(info[1])
	
	info[#info+1]=display.newText(("HP:"),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX
	info[#info].y=baseY
	infwg:insert(info[#info])
	
	local text=(p1["STATS"]["Health"].."/"..p1["STATS"]["MaxHealth"].."  ("..math.ceil(p1["STATS"]["Health"]/p1["STATS"]["MaxHealth"]*100).."%"..")")
	info[#info+1]=display.newText(text,0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+90
	info[#info].y=baseY
	info[#info]:setFillColor(primary,secundary,secundary)
	infwg:insert(info[#info])
	
	local text=("Weight: ~"..math.ceil(p1["STATS"]["Weight"]).."kg")
	info[#info+1]=display.newText(text,0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX
	info[#info].y=baseY
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("MP:"),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX
	info[#info].y=baseY+SpacingY
	infwg:insert(info[#info])
	
	local text=(p1["STATS"]["Mana"].."/"..p1["STATS"]["MaxMana"].."  ("..math.ceil(p1["STATS"]["Mana"]/p1["STATS"]["MaxMana"]*100).."%"..")")
	info[#info+1]=display.newText(text,0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+90
	info[#info].y=baseY+SpacingY
	info[#info]:setFillColor(primary,secundary,primary)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("EP:"),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX
	info[#info].y=baseY+SpacingY
	infwg:insert(info[#info])
	
	local text=(p1["STATS"]["Energy"].."/"..p1["STATS"]["MaxEnergy"].."  ("..math.ceil(p1["STATS"]["Energy"]/p1["STATS"]["MaxEnergy"]*100).."%"..")")
	info[#info+1]=display.newText(text,0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX+90
	info[#info].y=baseY+SpacingY
	info[#info]:setFillColor(secundary,primary,secundary)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("Level: "..p1["STATS"]["Level"]),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX
	info[#info].y=baseY+(SpacingY*2)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("XP:"),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX
	info[#info].y=baseY+(SpacingY*2)
	infwg:insert(info[#info])
	
	local text=(p1["STATS"]["Experience"].."/"..p1["STATS"]["MaxExperience"].."  ("..math.ceil(p1["STATS"]["Experience"]/p1["STATS"]["MaxExperience"]*100).."%"..")")
	info[#info+1]=display.newText(text,0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX+90
	info[#info].y=baseY+(SpacingY*2)
	info[#info]:setFillColor(secundary,secundary,primary)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("Gold: "..p1["GOLD"].." coins"),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX+SpacingX
	info[#info].y=baseY+(SpacingY*3)
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("Statistics:"),0,0,"MoolBoran",70)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX-20
	info[#info].y=350
	infwg:insert(info[#info])
	
	for s=1,6 do
		info[#info+1]=display.newText(
			(
				p1["STATS"][s]["NAME"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].anchorX=0
		info[#info].anchorY=0
		info[#info].x=baseX
		info[#info].y=420+(45*(s-1))
		infwg:insert(info[#info])
	end
	
	info[#info+1]=display.newText(("Armor: "..p1["STATS"]["Armor"]),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX
	info[#info].y=690
	infwg:insert(info[#info])
	
	info[#info+1]=display.newText(("Stat Points: "..p1["STATS"]["Free"]),0,0,"MoolBoran",60)
	info[#info].anchorX=0
	info[#info].anchorY=0
	info[#info].x=baseX
	info[#info].y=690+SpacingY
	infwg:insert(info[#info])
	
	for s=1,6 do
		info[#info+1]=display.newText(
			(
				p1["STATS"][s]["NATURAL"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].anchorX=0
		info[#info].anchorY=0
		info[#info].x=info[#info-s].x+250
		info[#info].y=420+(45*(s-1))	
		infwg:insert(info[#info])
	end
	
	for s=1,6 do
		info[#info+1]=display.newText(
			(
			"+"..p1["STATS"][s]["EQUIP"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].anchorX=0
		info[#info].anchorY=0
		info[#info].x=info[#info-s].x+80
		info[#info].y=420+(45*(s-1))
		if p1["STATS"][s]["EQUIP"]>0 then
			info[#info]:setFillColor(0.20,0.8,0.20)
		elseif p1["STATS"][s]["EQUIP"]<0 then
			info[#info]:setFillColor(0.8,0.20,0.20)
		else
			info[#info]:setFillColor(0.6,0.6,0.6)
		end
		infwg:insert(info[#info])
	end
	
	for s=1,6 do
		info[#info+1]=display.newText(
			(
			"+"..p1["STATS"][s]["BOOST"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].anchorX=0
		info[#info].anchorY=0
		info[#info].x=info[#info-s].x+80
		info[#info].y=420+(45*(s-1))
		if p1["STATS"][s]["BOOST"]>0 then
			info[#info]:setFillColor(0.20,0.8,0.20)
		elseif p1["STATS"][s]["BOOST"]<0 then
			info[#info]:setFillColor(0.8,0.20,0.20)
		else
			info[#info]:setFillColor(0.6,0.6,0.6)
		end
		infwg:insert(info[#info])
	end
	
	for s=1,6 do
		info[#info+1]=display.newText(
			(
				"= "..p1["STATS"][s]["TOTAL"]
			),
			0,0,"MoolBoran",60
		)
		info[#info].anchorX=0
		info[#info].anchorY=0
		info[#info].x=info[#info-s].x+80
		info[#info].y=420+(45*(s-1))
		if p1["STATS"][s]["TOTAL"]>p1["STATS"][s]["NATURAL"] then
			info[#info]:setFillColor(0.20,0.8,0.20)
		elseif p1["STATS"][s]["TOTAL"]<p1["STATS"][s]["NATURAL"] then
			info[#info]:setFillColor(0.8,0.20,0.20)
		else
		end
		infwg:insert(info[#info])
	end
	
	swapInfoBtn=  widget.newButton{
		defaultFile="ui/sbutton.png",
		overFile="ui/sbutton-over.png",
		font=native.systemFont,
		width=80, height=80,
		onRelease = SwapInfo}
	swapInfoBtn.x = display.contentWidth-60
	swapInfoBtn.y = display.contentHeight-280
	swapInfoBtn.state=false
	infwg:insert( swapInfoBtn )
	
	swapInfoImg=display.newImageRect("ui/plusminus.png",70,70)
	swapInfoImg.x=swapInfoBtn.x
	swapInfoImg.y=swapInfoBtn.y
	swapInfoImg.xScale=0.7
	swapInfoImg.yScale=swapInfoImg.xScale
	infwg:insert(swapInfoImg)
	
	infwg:toFront()
	infwg.y=200
	]]
end

function SwapInfo(sound)
	if isOpn==true and (infwg) then
		if sound~=false then
			-- a.Play(4)
		end
		--if swapInfoBtn.state==false then
		if (true) then
			for i=table.maxn(info),1,-1 do
				display.remove(info[i])
				info[i]=nil
			end
			for i=table.maxn(mini),1,-1 do
				display.remove(mini[i])
				mini[i]=nil
			end
			for i=table.maxn(pli),1,-1 do
				display.remove(pli[i])
				pli[i]=nil
			end
			for i=infwg.numChildren,1,-1 do
				display.remove(infwg[i])
				infwg[i]=nil
			end
			StatChange()
		else
			for i=table.maxn(info),1,-1 do
				display.remove(info[i])
				info[i]=nil
			end
			for i=table.maxn(mini),1,-1 do
				display.remove(mini[i])
				mini[i]=nil
			end
			for i=table.maxn(pli),1,-1 do
				display.remove(pli[i])
				pli[i]=nil
			end
			for i=infwg.numChildren,1,-1 do
				display.remove(infwg[i])
				infwg[i]=nil
			end
			StatInfo()
		end
	end
end

function More( event )
	local statnum=1
	if event.x>display.contentCenterX then
		statnum=statnum+1
	end
	if event.y>500 then
		statnum=statnum+2
	end
	if event.y>700 then
		statnum=statnum+2
	end
	p.Natural(statnum,1)
	SwapInfo(false)
	SwapInfo()
end

function Less( event )
	local statnum=1
	if event.x>display.contentCenterX then
		statnum=statnum+1
	end
	if event.y>500 then
		statnum=statnum+2
	end
	if event.y>700 then
		statnum=statnum+2
	end
	p.Natural(statnum,-1)
	SwapInfo(false)
	SwapInfo()
end

function InvFull()
	InvCheck()
	if table.maxn(p1.inv)==63 then
	--	print "Inventory is full!"
		return true
	else
		return false
	end
end

function InvCheck() --Checks if items in bag can be stacked together
	for a=table.maxn(p1.inv),1,-1 do
		for b=table.maxn(p1.inv),1,-1 do
			if (p1.inv[a])and(p1.inv[b]) and a~=b then
				if p1.inv[a][1]==p1.inv[b][1] then
					local stack=item.ReturnInfo(p1.inv[a][1],3)
					if stack==true then
						p1.inv[a][2]=p1.inv[a][2]+p1.inv[b][2]
						table.remove(p1.inv,b)
					end
				end
			end
		end
	end
end


---------------------------------------------------------------------------------------
-- AUDIO WINDOW
---------------------------------------------------------------------------------------

function OpenSnd()
	local approve=canWindowCheck()
	if approve==true then
		ToggleSound()
	end
end

function ToggleSound(sound)
	if isOpn==false then
		if sound~=false then
			-- a.Play(3)
		end
		
		toggleState()
		swg=display.newGroup()
	
		window=ui.CreateWindow(768,308)
		window.x=display.contentCenterX
		window.y=display.contentCenterY
		swg:insert(window)
	
		scroll=display.newImageRect("ui/scroll.png",600,50)
		scroll.x=display.contentCenterX
		scroll.y=display.contentCenterY-40
		scroll.xScale=1.15
		scroll.yScale=scroll.xScale
		scroll:addEventListener("touch",MusicScroll)
		swg:insert(scroll)
		
		CloseBtn=widget.newButton{
			label="X",
			labelColor = { default={255,255,255}, over={0,0,0} },
			fontSize=50,
			font=native.systemFont,
			defaultFile="ui/sbutton.png",
			overFile="ui/sbutton-over.png",
			width=80, height=80,
			onRelease = ForceClose}
		CloseBtn.xScale,CloseBtn.yScale=0.75,0.75
		CloseBtn.x = display.contentWidth-30
		CloseBtn.y = 390
		swg:insert(CloseBtn)
		
		local m=a.muse()
		m=m*10
		scrollind=display.newImageRect("ui/scrollind.png",15,50)
		scrollind.x=display.contentCenterX-(290*scroll.xScale)+( m*(290*scroll.xScale)/5 )
		scrollind.y=scroll.y
		scrollind.xScale=1.45
		scrollind.yScale=scrollind.xScale
		swg:insert(scrollind)
		
		musicind=display.newText( ("Music Volume".." "..(m*10).."%"),0,0,"MoolBoran",50 )
		musicind.x=scroll.x
		musicind.y=scroll.y+10
		swg:insert(musicind)
		
		scroll2=display.newImageRect("ui/scroll.png",600,50)
		scroll2.x=scroll.x
		scroll2.y=scroll.y+100
		scroll2.xScale=scroll.xScale
		scroll2.yScale=scroll.xScale
		scroll2:addEventListener("touch",SoundScroll)
		swg:insert(scroll2)
		
		local s=a.sfx()
		s=s*10
		scrollind2=display.newImageRect("ui/scrollind.png",15,50)
		scrollind2.x=display.contentCenterX-(290*scroll.xScale)+( s*(290*scroll.xScale)/5 )
		scrollind2.y=scroll2.y
		scrollind2.xScale=scrollind.xScale
		scrollind2.yScale=scrollind.xScale
		swg:insert(scrollind2)
		
		soundind=display.newText( ("Sound Volume".." "..(s*10).."%"),0,0,"MoolBoran",50 )
		soundind.x=scroll2.x
		soundind.y=scroll2.y+10
		swg:insert(soundind)

	elseif isOpn==true and (swg) then
		if sound~=false then
			-- a.Play(4)
		end
		toggleState()
		for i=swg.numChildren,1,-1 do
			display.remove(swg[i])
			swg[i]=nil
		end
		swg=nil
	end
end

function MusicScroll( event )
	if event.x>display.contentCenterX+(290*scroll.xScale) then
		scrollind.x=display.contentCenterX+(290*scroll.xScale)
		a.MusicVol(1.0)
		musicind.text=("Music Volume".." "..(1.0*100).."%")
	elseif event.x<display.contentCenterX-(290*scroll.xScale) then
		scrollind.x=display.contentCenterX-(290*scroll.xScale)
		a.MusicVol(0.0)
		musicind.text=("Music Volume".." "..(0.0*100).."%")
	else
		for s=1,11 do
			local x=display.contentCenterX-(290*scroll.xScale)+( (s-1)*58 )
			if event.x>x-(290*scroll.xScale)/10 and event.x<x+(290*scroll.xScale)/10 then
				scrollind.x=display.contentCenterX-(290*scroll.xScale)+( (s-1)*(290*scroll.xScale)/5 )
				a.MusicVol((s-1)/10)
				musicind.text=("Music Volume".." "..((s-1)*10).."%")
			end
		end
	end
end

function SoundScroll( event )
	if event.x>display.contentCenterX+(290*scroll.xScale) then
		scrollind2.x=display.contentCenterX+(290*scroll.xScale)
		a.SoundVol(1.0)
		soundind.text=("Sound Volume".." "..(1.0*100).."%")
	elseif event.x<display.contentCenterX-(290*scroll.xScale) then
		scrollind2.x=display.contentCenterX-(290*scroll.xScale)
		a.SoundVol(0.0)
		soundind.text=("Sound Volume".." "..(0.0*100).."%")
	else
		for s=1,11 do
			local x=display.contentCenterX-(290*scroll.xScale)+( (s-1)*58 )
			if event.x>x-(290*scroll.xScale)/10 and event.x<x+(290*scroll.xScale)/10 then
				scrollind2.x=display.contentCenterX-(290*scroll.xScale)+( (s-1)*(290*scroll.xScale)/5 )
				a.SoundVol((s-1)/10)
				soundind.text=("Sound Volume".." "..((s-1)*10).."%")
			end
		end
	end
end


---------------------------------------------------------------------------------------
-- EXIT WINDOW
---------------------------------------------------------------------------------------

function OpenExit()
	local approve=canWindowCheck()
	if approve==true then
		ToggleExit()
	end
end

function ToggleExit(sound)
	if isOpn==false then
		if sound~=false then
			a.Play(3)
		end
		
		toggleState()
		exmg=display.newGroup()
		
		window=display.newImageRect("ui/usemenu.png", 768, 308)
		window.x,window.y = display.contentWidth/2, 450
		exmg:insert( window )
		
		lolname=display.newText( ("You pressed the exit button.") ,0,0,"MoolBoran",70)
		lolname.x=display.contentCenterX
		lolname.y=(display.contentHeight/2)-140
		exmg:insert( lolname )
		
		lolname2=display.newText( ("Are you sure you want to exit?") ,0,0,"MoolBoran",55)
		lolname2.x=display.contentCenterX
		lolname2.y=lolname.y+50
		exmg:insert(lolname2)
		
		lolname3=display.newText( ("\(Unsaved progress will be lost.\)") ,0,0,"MoolBoran",40)
		lolname3:setFillColor(0.7,0.7,0.7)
		lolname3.x=display.contentCenterX
		lolname3.y=lolname2.y+50
		exmg:insert(lolname3)
		
		AcceptBtn=  widget.newButton{
			label="Yes",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=200, height=55,
			onRelease = DoExit}
		AcceptBtn.x = (display.contentWidth/2)-130
		AcceptBtn.y = (display.contentHeight/2)+30
		exmg:insert( AcceptBtn )
		
		BackBtn=  widget.newButton{
			label="No",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=200, height=55,
			onRelease = ForceClose}
		BackBtn.x = (display.contentWidth/2)+130
		BackBtn.y = (display.contentHeight/2)+30
		exmg:insert( BackBtn )
		
		exmg:toFront()
		
	elseif isOpn==true and (exmg) then
		if sound~=false then
			a.Play(4)
		end
		for i=exmg.numChildren,1,-1 do
			display.remove(exmg[i])
			exmg[i]=nil
		end
		exmg=nil
		toggleState()
	end
end

function DoExit()
	native.requestExit()
end


---------------------------------------------------------------------------------------
-- SPELLBOOK WINDOW
---------------------------------------------------------------------------------------

function OpenBook()
	local approve=canWindowCheck()
	if approve==true then
		ToggleSpells()
	end
end

function ToggleSpells(sound)
	if isOpn==false then
		if sound~=false then
			a.Play(3)
		end
		
		toggleState()
		bkwg=display.newGroup()
		spellicons={}
		spellnames={}
		spelltrigger={}
		
		bkg=CreateWindow(768,840,1)
		bkg.x,bkg.y = display.contentWidth/2, 305
		bkwg:insert(bkg)
		
		CloseBtn=widget.newButton{
			label="X",
			labelColor = { default={255,255,255}, over={0,0,0} },
			fontSize=50,
			font=native.systemFont,
			defaultFile="ui/sbutton.png",
			overFile="ui/sbutton-over.png",
			width=80, height=80,
			onRelease = ForceClose}
		CloseBtn.xScale,CloseBtn.yScale=0.75,0.75
		CloseBtn.x = display.contentWidth-30
		CloseBtn.y = -85 --15
		bkwg:insert(CloseBtn)
		
		for i=1,table.maxn(p1.spells) do
		
			spelltrigger[i]=display.newRect(0,0,310,80)
			spelltrigger[i].anchorX=0
			spelltrigger[i].anchorY=0
			spelltrigger[i].x = 10
			spelltrigger[i].y = -105+((i-1)*85)
			spelltrigger[i]:setFillColor(0,0,0,0.5)
			spelltrigger[i]:addEventListener("tap",SpellInfo)
			bkwg:insert(spelltrigger[i])
			
			if p1.spells[i][3]==true then
				spellicons[i]=display.newImageRect(("spells/"..p1.spells[i][1]..".png"),80,80)
				spellicons[i].anchorX=0
				spellicons[i].anchorY=0
				spellicons[i].x=spelltrigger[i].x+5
				spellicons[i].y=spelltrigger[i].y
				bkwg:insert(spellicons[i])
				
				spellnames[i]=display.newText((p1.spells[i][1]),0,0,"MoolBoran",50)
				spellnames[i].anchorX=0
				spellnames[i].anchorY=0
				spellnames[i].x=spellicons[i].x+85
				spellnames[i].y=spellicons[i].y+15
				spellnames[i]:setFillColor(0,0,0)
				bkwg:insert(spellnames[i])
			else
				spellicons[i]=display.newImageRect(("spells/"..p1.spells[i][1].." X.png"),80,80)
				spellicons[i].anchorX=0
				spellicons[i].anchorY=0
				spellicons[i].x=spelltrigger[i].x+5
				spellicons[i].y=spelltrigger[i].y
				bkwg:insert(spellicons[i])
				
				spellnames[i]=display.newText((p1.spells[i][1]),0,0,250,100,"Runes of Galdamir",35)
				spellnames[i].anchorX=0
				spellnames[i].anchorY=0
				spellnames[i].x=spellicons[i].x+85
				spellnames[i].y=spellicons[i].y+20
				spellnames[i]:setFillColor(0,0,0)
				bkwg:insert(spellnames[i])
			end
		end
		
		bkwg.y=300
	elseif isOpn==true and (bkwg) then
		toggleState()
		if sound~=false then
			a.Play(4)
		end
		for i=table.maxn(spellicons),1,-1 do
			display.remove(spellicons[i])
			spellicons[i]=nil
		end
		spellicons=nil
		for i=table.maxn(spellnames),1,-1 do
			display.remove(spellnames[i])
			spellnames[i]=nil
		end
		spellnames=nil
		for i=table.maxn(spelltrigger),1,-1 do
			display.remove(spelltrigger[i])
			spelltrigger[i]=nil
		end
		spelltrigger=nil
		for i=bkwg.numChildren,1,-1 do
			display.remove(bkwg[i])
			bkwg[i]=nil
		end
		bkwg=nil
	end
end

function SpellInfo( event )
	local selectedSpell
	for i=1,table.maxn(spelltrigger) do
		if event.y-300>spelltrigger[i].y and event.y-300<spelltrigger[i].y+80 then
			selectedSpell=i
		end
	end
	if (spellshown) then
		for i=table.maxn(spellshown),1,-1 do
			display.remove(spellshown[i])
			spellshown[i]=nil
		end
		spellshown=nil
	end
	spellshown={}
	
	if p1.spells[selectedSpell][3]==true then
		spellshown[1]=display.newText( (p1.spells[selectedSpell][1]),0,0,"MoolBoran",80)
		spellshown[1].x=((display.contentWidth/4)*3)-50
		spellshown[1].y=-50
		spellshown[1]:setFillColor(0,0,0)
		bkwg:insert(spellshown[1])
		
		spellshown[2]=display.newText( 
			(p1.spells[selectedSpell][2]),
			0,
			0,
			420,0,"MoolBoran",45
		)
		spellshown[2].anchorX=0
		spellshown[2].anchorY=0
		spellshown[2].x=spellshown[1].x-190
		spellshown[2].y=spellshown[1].y+50
		spellshown[2]:setFillColor(0.20,0.20,0.20)
		bkwg:insert(spellshown[2])
		
		spellshown[3]=display.newText( (p1.spells[selectedSpell][4].." MP"),0,0,"MoolBoran",65)
		spellshown[3].x=((display.contentWidth/4)*3)-50
		spellshown[3].y=350
		spellshown[3]:setFillColor(0.7,0.28,0.7)
		bkwg:insert(spellshown[3])
		
		spellshown[4]=display.newText( (p1.spells[selectedSpell][5].." EP"),0,0,"MoolBoran",65)
		spellshown[4].x=spellshown[3].x
		spellshown[4].y=spellshown[3].y+50
		spellshown[4]:setFillColor(0.28,0.7,0.28)
		bkwg:insert(spellshown[4])
	else
		spellshown[1]=display.newText( (p1.spells[selectedSpell][1]),0,0,"Runes of Galdamir",70)
		spellshown[1].x=((display.contentWidth/4)*3)-50
		spellshown[1].y=-50
		spellshown[1]:setFillColor(0,0,0)
		bkwg:insert(spellshown[1])
		
		spellshown[2]=display.newText( 
			(p1.spells[selectedSpell][2]),
			0,
			0,
			420,0,"Runes of Galdamir",45
		)
		spellshown[2].anchorX=0
		spellshown[2].anchorY=0
		spellshown[2].x=spellshown[1].x-190
		spellshown[2].y=spellshown[1].y+70
		spellshown[2]:setFillColor(0.20,0.20,0.20)
		bkwg:insert(spellshown[2])
		
		spellshown[3]=display.newText( (p1.spells[selectedSpell][4].." MP"),0,0,"Runes of Galdamir",55)
		spellshown[3].x=((display.contentWidth/4)*3)-50
		spellshown[3].y=350
		spellshown[3]:setFillColor(0.7,0.28,0.7)
		bkwg:insert(spellshown[3])
		
		spellshown[4]=display.newText( (p1.spells[selectedSpell][5].." EP"),0,0,"Runes of Galdamir",55)
		spellshown[4].x=spellshown[3].x
		spellshown[4].y=spellshown[3].y+70
		spellshown[4]:setFillColor(0.28,0.7,0.28)
		bkwg:insert(spellshown[4])
	end
end


---------------------------------------------------------------------------------------
-- DEATH WINDOW
---------------------------------------------------------------------------------------

function DeathMenu(cause)
	if isOpn==false then
		dwg=display.newGroup()
		isOpn=true
		DMenu=ui.CreateWindow(700, 500)
		DMenu.x,DMenu.y = display.contentCenterX, 450
		Dthtxt=display.newGroup()
		dwg:insert( DMenu )
		
		Deathmsg=display.newText("Game Over!",0,0, "MoolBoran", 90)
		Deathmsg.x = display.contentCenterX
		Deathmsg.y = 290
		Dthtxt:insert( Deathmsg )
		
		Deathmsg2=display.newText(" ",0,0,"MoolBoran", 55)
		Deathmsg2:setFillColor(0.7, 0.7, 0.7)
		Deathmsg2.x = display.contentCenterX
		Deathmsg2.y = Deathmsg.y+50
		Dthtxt:insert( Deathmsg2 )
		
		if cause=="Lava" then
			Deathmsg2.text=(DeathMessages[1][math.random(1,table.maxn(DeathMessages[1]))])
		end
		if cause=="Mob" then
			Deathmsg2.text=(DeathMessages[2][math.random(1,table.maxn(DeathMessages[1]))])
		end
		if cause=="Poison" then
			Deathmsg2.text=(DeathMessages[3][math.random(1,table.maxn(DeathMessages[1]))])
		end
		if cause=="Portal" then
			Deathmsg2.text=(DeathMessages[4][math.random(1,table.maxn(DeathMessages[1]))])
		end
		if cause=="Energy" then
			Deathmsg2.text=(DeathMessages[5][math.random(1,table.maxn(DeathMessages[1]))])
		end
		
		ToMenuBtn =  widget.newButton{
			label="Back to Menu",
			labelColor = { default={255,255,255}, over={0,0,0} },
			font="MoolBoran",
			fontSize=50,
			labelYOffset=10,
			defaultFile="ui/cbutton.png",
			overFile="ui/cbutton-over.png",
			width=290, height=80,
			onRelease = onToMenuBtnRelease
		}
		ToMenuBtn.x = display.contentCenterX
		ToMenuBtn.y = display.contentHeight*0.61
		dwg:insert( ToMenuBtn )
		
		Round=WD.Circle()
		p1=p.GetPlayer()
		xsize,ysize=b.getData(2)
		scre,hs=sc.Scoring( Round , p1 , ((xsize+ysize)/2) )
		Round=tostring(Round)
		GCount=tostring(p1["GOLD"])
		GInfoTxt=display.newGroup()
		
		InfoTxt1=display.newText("You got to floor ",0,0,"MoolBoran", 60 )
		InfoTxt1.x=225
		InfoTxt1.y=Deathmsg2.y+100
		GInfoTxt:insert( InfoTxt1 )
		
		InfoTxt2=display.newText(Round,0,0,"MoolBoran", 60 )
		InfoTxt2:setFillColor(0.20, 1, 0.20)
		InfoTxt2.y=InfoTxt1.y
		InfoTxt2.anchorX=0
		InfoTxt2.x=InfoTxt1.x+20+(7*(#InfoTxt1.text))
		GInfoTxt:insert( InfoTxt2 )
		
		InfoTxt3= display.newText(" with ",0,0,"MoolBoran", 60 )
		InfoTxt3.y=InfoTxt1.y
		InfoTxt3.anchorX=0
		InfoTxt3.x=InfoTxt2.x+20+(15*(#InfoTxt2.text))
		GInfoTxt:insert( InfoTxt3 )
		
		InfoTxt4=display.newText(GCount,0,0,"MoolBoran", 60 )
		InfoTxt4.y=InfoTxt1.y
		InfoTxt4.anchorX=0
		InfoTxt4.x=InfoTxt3.x+20+(15*(#InfoTxt3.text))
		InfoTxt4:setFillColor(1, 1, 0.20)
		GInfoTxt:insert( InfoTxt4 )
		
		InfoTxt5=display.newText(" gold.",InfoTxt4.x+25+(15*(#GCount-1)),0,"MoolBoran", 60 )
		InfoTxt5.y=InfoTxt1.y
		InfoTxt5.anchorX=0
		InfoTxt5.x=InfoTxt4.x+20+(15*(#InfoTxt4.text))
		GInfoTxt:insert( InfoTxt5 )
		
		if hs==true then
			InfoTxt6=display.newText(("New high score:"),0,0,"MoolBoran", 60 )
			InfoTxt6:setFillColor(0.28, 1, 0.28)
			InfoTxt6.x=display.contentCenterX
			InfoTxt6.y=display.contentCenterY-20
			GInfoTxt:insert( InfoTxt6 )
		else
			InfoTxt6=display.newText(("Score:"),0,0,"MoolBoran", 60 )
			InfoTxt6:setFillColor(0.28, 1, 0.28)
			InfoTxt6.x=display.contentCenterX
			InfoTxt6.y=display.contentCenterY-20
			GInfoTxt:insert( InfoTxt6 )
		end
		
		InfoTxt7=display.newText((scre),0,0,"MoolBoran", 60 )
		InfoTxt7.x=display.contentCenterX
		InfoTxt7.y=display.contentCenterY+40
		GInfoTxt:insert( InfoTxt7 )
		
		dwg:insert( Dthtxt )
		dwg:insert( GInfoTxt )
		dwg:toFront()
		
		Runtime:removeEventListener("enterFrame", g.GoldDisplay)
		b.WipeMap()
		-- m.CleanArrows()
		a.changeMusic(0)
		s.WipeSave()
		
	elseif isOpn==true then
		for i=dwg.numChildren,1,-1 do
			display.remove(dwg[i])
			dwg[i]=nil
		end
		dwg=nil
		isOpn=false
	end
end

function onToMenuBtnRelease()
	if (dwg) then
		DeathMenu()
	end
	if (infwg) then
		ToggleInfo()
	end
	WD.SrsBsns()
end


