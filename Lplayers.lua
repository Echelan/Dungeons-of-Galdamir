-----------------------------------------------------------------------------------------
--
-- players.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local energysheet = graphics.newImageSheet( "energysprite.png", { width=60, height=60, numFrames=4 } )
local heartsheet = graphics.newImageSheet( "heartsprite.png", { width=17, height=17, numFrames=16 } )
local manasheet = graphics.newImageSheet( "manasprite.png", { width=60, height=60, numFrames=3 } )
local xpsheet = graphics.newImageSheet( "xpbar.png", { width=392, height=40, numFrames=50 } )
local psheet = graphics.newImageSheet( "player.png", { width=24, height=32, numFrames=56 } )
local set=require("Lsettings")
local WD=require("Lprogress")
local su=require("Lstartup")
local b=require("Lbuilder")
local lc=require("Llocale")
local gold=require("Lgold")
local w=require("Lwindow")
local c=require("Lchars")
local a=require("Laudio")
local i=require("Litems")
local ui=require("Lui")
local DisplayCan=false
local Cheat=false
local StrongForce
local yCoord=856
local check=119
local xCoord=70
local scale=2.6
local transp2
local transp3
local player
local transp
local Map
local statinfo
local pseqs={
		{name="stand1",		start=1,  count=1, time=1000},
		{name="stand2",		start=2,  count=1, time=1000},
		{name="stand3",		start=3,  count=1, time=1000},
		{name="stand4",		start=4,  count=1, time=1000},
		{name="walk1",		start=5,  count=4, time=500},
		{name="walk2",		start=9,  count=4, time=500},
		{name="walk3",		start=13, count=4, time=500},
		{name="walk4",		start=17, count=4, time=500},
		{name="stance",		start=21, count=4, time=1000},
		{name="melee",		start=25, count=4, time=600,loopCount=1},
		{name="magic",		start=29, count=4, time=600,loopCount=1},
		{name="recover",	start=33, count=4, time=750},
		{name="hurt",		start=37, count=4, time=750},
		{name="heal1",		start=41, count=4, time=750},
		{name="heal2",		start=45, count=4, time=750},
		{name="heal3",		start=49, count=4, time=750},
		{name="heal4",		start=53, count=4, time=750},
	}
local names={}
names["EN"]={
		"Nameless",
		"Orphan",
		"Smith",
		"Slave",
		"Hctib",
	}
names["ES"]={
		"Innombrado",
		"Huerfano",
		"Perez",
		"Esclavo",
		"Atup",
	}
	
function CreatePlayers(name)
--[[
	local char =c.GetCharInfo(0)
	local class=c.GetCharInfo(1)

	if not (char) then
		char=math.random(0,3)
	end
	if not (class) then
		class=math.random(0,5)
	end
	]]
	char=0
	class=6
	--Visual
	player=display.newSprite( psheet, pseqs )
	player:setSequence("stand1")
	player.x, player.y = display.contentWidth/2, display.contentHeight/2
	player.xScale=scale
	player.yScale=player.xScale
	--Leveling
	if name==nil or name=="" or name==" " then
		player.name=names[lc.giveLang()][math.random(1,table.maxn(names[lc.giveLang()]))]
	elseif name=="Magus" or name=="MAGUS" or name=="magus" then
		player.name="Magus"
	elseif name=="Error" or name=="error" or name=="ERROR" then
		player.name="Error"
	else
		player.name=name
	end
	player.lvl=1
	player.MaxXP=50
	player.XP=0
	local lang=lc.giveLang()
	if lang=="EN" then
		player.clsnames={"Viking","Warrior","Knight","Sorcerer","Thief","Scholar","Freelancer"}
	elseif lang=="ES" then
		player.clsnames={"Vikingo","Guerrero","Caballero","Hechicero","Ladron","Erudito","Freelancer"}
	end
	player.char=char
	player.class=class
	--Extras
	player.gp=0
	player.eqp={  }
	player.inv={ {1,10},{32,1} }
	player.weight=5
	--Stats
	if lang=="EN" then
		player.statnames={"Stamina",	"Attack",	"Defense",	"Magic",	"Dexterity",	"Intellect"}
	elseif lang=="ES" then
		player.statnames={"Aguante",	"Ataque",	"Defensa",	"Magia",	"Destreza",	"Intelecto"}
	end
	player.eqs=			{0,			0,			0,			0,			0,				0}
	player.nat=			{2,			2,			2,			2,			2,				2}
	player.bon=			{0,			0,			0,			0,			0,				0}
	player.bst=			{0,			0,			0,			0,			0,				0}
	player.stats={
		(player.nat[1]+player.eqs[1]+player.bon[1]+player.bst[1]),
		(player.nat[2]+player.eqs[2]+player.bon[2]+player.bst[2]),
		(player.nat[3]+player.eqs[3]+player.bon[3]+player.bst[3]),
		(player.nat[4]+player.eqs[4]+player.bon[4]+player.bst[4]),
		(player.nat[5]+player.eqs[5]+player.bon[5]+player.bst[5]),
		(player.nat[6]+player.eqs[6]+player.bon[6]+player.bst[6]),
	}
	player.pnts=7
	--Spells
	if lang=="EN" then
		player.spells={
			{"Gouge","Place a deep wound on the enemy target.",true,9,13},
			{"Fireball","Cast a firey ball of death and burn the enemy.",true,16,7},
			{"Cleave","Hits for twice maximum damage. Can't be evaded.",false,5,13},
			{"Slow","Reduces enemy's dexterity.",false,28,5},
			{"Poison Blade","Inflicts poison.",false,16,19},
			{"Fire Sword","Hits for twice damage and inflicts a burn.",false,26,37},
			{"Healing","Heals for 20% of your maximum health.",false,58,4},
			{"Ice Spear","Hits for twice damage and reduces enemy's dexterity.",false,51,46},
		}
	elseif lang=="ES" then
		player.spells={
			{"Rajar","Deja una herida profunda en el enemigo.",true,9,13},
			{"Bola de Fuego","Lanza una bola de fuego y enciende al enemigo.",true,16,7},
			{"Hender","Pega por el doble de tu da�o . No evitable.",false,5,13},
			{"Alentar","Reduce la destreza de tu enemigo.",false,28,5},
			{"Cuchilla Venenosa","Inflige veneno.",false,16,19},
			{"Espada Encendida","Pega por el doble de tu da�o y enciende al enemigo.",false,26,37},
			{"Curacion","Cura por 20% de tu vida maxima.",false,58,4},
			{"Lanza de Hielo","Pega por el doble de tu  da�o  y reduce la destreza de tu enemigo.",false,51,46},
		}
	end
	--Secondary Stats
	player.portcd=0
	player.MaxHP=(10*player.lvl)+(player.stats[1]*20)
	player.MaxMP=(5*player.lvl)+(player.stats[6]*10)
	player.MaxEP=(5*player.lvl)+(player.stats[6]*10)
	player.HP=player.MaxHP
	player.MP=player.MaxMP
	player.EP=player.MaxEP
	player.SPD=(1.00-(player.stats[5]/100))
	--
	if (player) then
		Runtime:addEventListener("enterFrame",ShowStats)
		su.FrontNCenter()
	end
end

function SpriteSeq(value)
	if value==false then
		if player.sequence=="walk1" then
			player:setSequence("stand1")
			player:play()
		elseif player.sequence=="walk2" then
			player:setSequence("stand2")
			player:play()
		elseif player.sequence=="walk3" then
			player:setSequence("stand3")
			player:play()
		elseif player.sequence=="walk4" then
			player:setSequence("stand4")
			player:play()
		end
	elseif value==true then
		if player.sequence=="stand1" then
			player:setSequence("heal1")
			player:play()
		elseif player.sequence=="stand2" then
			player:setSequence("heal2")
			player:play()
		elseif player.sequence=="stand3" then
			player:setSequence("heal3")
			player:play()
		elseif player.sequence=="stand4" then
			player:setSequence("heal4")
			player:play()
		end
	else
		player:setSequence(value)
		player:play()
	end
end

function PlayerLoc(location,room)
	player.loc=location
	player.room=room
end

function GetPlayer()
	return player
end

function ShowStats()
	check=check+1
	if check==120 then
		statinfo={}
		statinfo[1]=set.Get(1)
		statinfo[2]=set.Get(2)
		statinfo[3]=set.Get(3)
		statinfo[4]=set.Get(4)
		statinfo[5]=set.Get(5)
		StatCheck()
		check=-1
	end
	
-- Life
	if not(LifeDisplay) then
		transp=255
		
		LifeDisplay = display.newText((player.HP.."/"..player.MaxHP),0,0,"Game Over",100)
		LifeDisplay.anchorX=0
		LifeDisplay.anchorY=0
		LifeDisplay.x=statinfo[1][1]
		LifeDisplay.y=statinfo[1][2]
		LifeDisplay:setFillColor( 255/255, 255/255, 255/255,transp/255)
		
		LifeWindow = display.newRect (0,0,#LifeDisplay.text*22,40)
		LifeWindow:setFillColor( 150/255, 150/255, 150/255,transp/2/255)
		LifeWindow.anchorX=0
		LifeWindow.anchorY=0
		LifeWindow.x=LifeDisplay.x
		LifeWindow.y=LifeDisplay.y+5
		
		LifeDisplay:toFront()
	end
	if not(LifeSymbol) then
		player.life=0
		LifeSymbol=display.newSprite( heartsheet, {name="heart",start=1,count=16,time=(1800)} )
		LifeSymbol.anchorX=0
		LifeSymbol.anchorY=0
		LifeSymbol.yScale=3.75
		LifeSymbol.xScale=3.75
		LifeSymbol.x = LifeDisplay.x-70
		LifeSymbol.y = LifeDisplay.y+5
		LifeSymbol:play()
		LifeSymbol:setFillColor(transp/255,transp/255,transp/255,transp/255)
	end
	
	if ((player.HP.."/"..player.MaxHP))~=LifeDisplay.text or StrongForce==true then
		transp=255
		LifeDisplay.text=((player.HP.."/"..player.MaxHP))
		
		display.remove(LifeWindow)
		LifeWindow = display.newRect (0,0,#LifeDisplay.text*22,40)
		LifeWindow:setFillColor( 150/255, 150/255, 150/255,transp/2/255)
		LifeWindow.anchorX=0
		LifeWindow.anchorY=0
		LifeWindow.x=LifeDisplay.x
		LifeWindow.y=LifeDisplay.y+12.5
		
		LifeSymbol:toFront()
		LifeDisplay:toFront()
		LifeDisplay:setFillColor( 255/255, 255/255, 255/255,transp/255)
		LifeSymbol:setFillColor(transp/255,transp/255,transp/255,transp/255)
	elseif ((player.HP.."/"..player.MaxHP))==LifeDisplay.text and transp~=0 and player.HP==player.MaxHP and StrongForce~=true then
		if statinfo[1][3]==0 then
			transp=transp-(255/50)
			if transp<20 then
				transp=0
			end
		else
			transp=255
		end
		LifeWindow:setFillColor( 150/255, 150/255, 150/255,transp/2/255)
		LifeDisplay:setFillColor( 255/255, 255/255, 255/255,transp/255)
		LifeSymbol:setFillColor(transp/255,transp/255,transp/255,transp/255)
	end
	
-- Mana
	if not(ManaDisplay) then
		transp3=255
		
		ManaDisplay = display.newText((player.MP.."/"..player.MaxMP),0,0,"Game Over",100)
		ManaDisplay.anchorX=0
		ManaDisplay.anchorY=0
		ManaDisplay.x=statinfo[2][1]
		ManaDisplay.y=statinfo[2][2]
		ManaDisplay:setFillColor( 255/255, 255/255, 255/255,transp3/255)
		
		ManaWindow = display.newRect (0,0,#ManaDisplay.text*22,40)
		ManaWindow:setFillColor( 150/255, 150/255, 150/255,transp3/2/255)
		ManaWindow.anchorX=0
		ManaWindow.anchorY=0
		ManaWindow.x=ManaDisplay.x
		ManaWindow.y=ManaDisplay.y+12.5
		
		ManaDisplay:toFront()
	end
	if not (ManaSymbol) then
		ManaSymbol=display.newSprite( manasheet, {name="mana",start=1,count=3,time=500} )
		ManaSymbol.anchorX=0
		ManaSymbol.anchorY=0
		ManaSymbol.yScale=1.0625
		ManaSymbol.xScale=1.0625
		ManaSymbol.x = ManaDisplay.x-70
		ManaSymbol.y = ManaDisplay.y+5
		ManaSymbol:play()
		ManaSymbol:setFillColor(transp3/255,transp3/255,transp3/255,transp3/255)
	end
	
	if ((player.MP.."/"..player.MaxMP))~=ManaDisplay.text or StrongForce==true then
		transp3=255
		ManaDisplay.text=((player.MP.."/"..player.MaxMP))
		
		display.remove(ManaWindow)
		ManaWindow = display.newRect (0,0,#ManaDisplay.text*22,40)
		ManaWindow:setFillColor( 150/255, 150/255, 150/255,transp3/2/255)
		ManaWindow.anchorX=0
		ManaWindow.anchorY=0
		ManaWindow.x=ManaDisplay.x
		ManaWindow.y=ManaDisplay.y+12.5
		
		ManaSymbol:toFront()
		ManaDisplay:toFront()
		ManaDisplay:setFillColor( 255/255, 255/255, 255/255,transp3/255)
		ManaSymbol:setFillColor(transp3/255,transp3/255,transp3/255,transp3/255)
	elseif ((player.MP.."/"..player.MaxMP))==ManaDisplay.text and transp3~=0 and player.MP==player.MaxMP and StrongForce~=true then
		if statinfo[1][3]==0 then
			transp3=transp3-(255/50)
			if transp3<20 then
				transp3=0
			end
		else
			transp3=255
		end
		ManaWindow:setFillColor( 150/255, 150/255, 150/255,transp3/2/255)
		ManaDisplay:setFillColor( 255/255, 255/255, 255/255,transp3/255)
		ManaSymbol:setFillColor(transp3/255,transp3/255,transp3/255,transp3/255)
	end
	
-- Energy
	if not(EnergyDisplay) then
		transp5=255
		EnergyDisplay = display.newText((player.EP.."/"..player.MaxEP),0,0,"Game Over",100)
		EnergyDisplay.anchorX=0
		EnergyDisplay.anchorY=0
		EnergyDisplay.x=statinfo[3][1]
		EnergyDisplay.y=statinfo[3][2]
		EnergyDisplay:setFillColor( 255/255, 255/255, 255/255,transp5/255)
		
		EnergyWindow = display.newRect (0,0,#EnergyDisplay.text*22,40)
		EnergyWindow:setFillColor( 150/255, 150/255, 150/255,transp5/2/255)
		EnergyWindow.anchorX=0
		EnergyWindow.anchorY=0
		EnergyWindow.x=EnergyDisplay.x
		EnergyWindow.y=EnergyDisplay.y+12.5
		
		EnergyDisplay:toFront()
	end
	if not (EnergySymbol) then
		EnergySymbol=display.newSprite( energysheet, {name="energy",start=1,count=4,time=500} )
		EnergySymbol.anchorX=0
		EnergySymbol.anchorY=0
		EnergySymbol.yScale=1.0625
		EnergySymbol.xScale=1.0625
		EnergySymbol.x = EnergyDisplay.x-70
		EnergySymbol.y = EnergyDisplay.y+5
		EnergySymbol:play()
		EnergySymbol:setFillColor(transp5/255,transp5/255,transp5/255,transp5/255)
	end
	
	if ((player.EP.."/"..player.MaxEP))~=EnergyDisplay.text or StrongForce==true then
		transp5=255
		EnergyDisplay.text=((player.EP.."/"..player.MaxEP))
		
		display.remove(EnergyWindow)
		EnergyWindow = display.newRect (0,0,#EnergyDisplay.text*22,40)
		EnergyWindow:setFillColor( 150/255, 150/255, 150/255,transp5/2/255)
		EnergyWindow.anchorX=0
		EnergyWindow.anchorY=0
		EnergyWindow.x=EnergyDisplay.x
		EnergyWindow.y=EnergyDisplay.y+12.5
		
		EnergySymbol:toFront()
		EnergyDisplay:toFront()
		EnergyDisplay:setFillColor( 255/255, 255/255, 255/255,transp5/255)
		EnergySymbol:setFillColor(transp5,transp5,transp5,transp5)
	elseif ((player.EP.."/"..player.MaxEP))==EnergyDisplay.text and transp5~=0 and player.EP==player.MaxEP and StrongForce~=true then
		if statinfo[3][3]==0 then
			transp5=transp5-(255/50)
			if transp5<20 then
				transp5=0
			end
		else
			transp5=255
		end
		EnergyWindow:setFillColor( 150/255, 150/255, 150/255,transp5/2/255)
		EnergyDisplay:setFillColor( 255/255, 255/255, 255/255,transp5/255)
		EnergySymbol:setFillColor(transp5/255,transp5/255,transp5/255,transp5/255)
	end
	
-- Experience
	if not (XPSymbol) then
		transp2=0
		XPSymbol=display.newSprite( xpsheet, { name="xpbar", start=1, count=50, time=(2000) }  )
		XPSymbol.x = statinfo[5][1]
		XPSymbol.y = statinfo[5][2]
		XPSymbol:toFront()
		XPSymbol:setFillColor(transp2/255,transp2/255,transp2/255,transp2/255)
		
		XPDisplay=display.newText( ((XPSymbol.frame*2).."%"), 0, 0, "Game Over", 85 )
		XPDisplay.x = XPSymbol.x
		XPDisplay.y = XPSymbol.y
		XPDisplay:toFront()
		XPDisplay:setFillColor( 0, 0, 0,transp2/255)
	end
	
-- Stat Points
	if not (StatSymbol) then
		transp4=0
		StatSymbol=display.newImageRect("unspent.png",240,80)
		StatSymbol.x = statinfo[4][1]
		StatSymbol.y = statinfo[4][2]
		StatSymbol:toFront()
		StatSymbol:setFillColor(transp4/255,transp4/255,transp4/255,transp4/255)
		su.FrontNCenter()
	end
	
	if StrongForce==true then
		StatSymbol:removeEventListener("touch",openStats)
		transp4=transp4-(255/50)
		if transp4<20 then
			transp4=0
		end
		StatSymbol:setFillColor(transp4/255,transp4/255,transp4/255,transp4/255)
	elseif player.pnts~=0 then
		StatSymbol:removeEventListener("touch",openStats)
		transp4=255
		StatSymbol:setFillColor(transp4/255,transp4/255,transp4/255,transp4/255)
		StatSymbol:addEventListener("touch",openStats)
	elseif player.pnts==0 and transp4~=0 then
		StatSymbol:removeEventListener("touch",openStats)
		transp4=transp4-(255/50)
		if transp4<20 then
			transp4=0
		end
		StatSymbol:setFillColor(transp4/255,transp4/255,transp4/255,transp4/255)
	end
end

function openStats( event )
	if event.phase=="ended" and DisplayCan==true then
		ui.Pause()
		w.ToggleInfo(false)
		w.SwapInfo(false)
	end
end

function LetsYodaIt()
	if StrongForce~=true then
		StrongForce=true
	else
		StrongForce=false
	end
end

function CalmDownCowboy(what)
	DisplayCan=what
end

function ReduceHP(amount,cause)
	if player.HP~=0 and Cheat==false then
		player.HP = player.HP - amount
		if player.HP <= 0 then
			player.HP = 0
			w.DeathMenu(cause)
		end
	end
end

function AddHP(amount)
	if player.HP~=player.MaxHP then
		player.HP = player.HP + amount
		if player.HP > player.MaxHP then
			player.HP = player.MaxHP
		end
		a.Play(5)
	end
end

function AddMP(amount)
	if player.MP~=player.MaxMP then
		player.MP = player.MP + amount
		if player.MP > player.MaxMP then
			player.MP = player.MaxMP
		end
		a.Play(5)
	end
end

function AddEP(amount)
	if player.EP~=player.MaxEP then
		player.EP = player.EP + amount
		if player.EP > player.MaxEP then
			player.EP = player.MaxEP
		end
		a.Play(5)
	end
end

function StatCheck()
	if player.class==0 then
		player.bon[3]=math.floor(player.nat[1]/3)
	elseif player.class==1 then
		player.bon[5]=math.floor(player.nat[2]/3)
	elseif player.class==2 then
		player.bon[6]=math.floor(player.nat[3]/6)
		player.bon[1]=math.floor(player.nat[3]/6)
	elseif player.class==3 then
		player.bon[5]=math.floor(player.nat[4]/3)
	elseif player.class==4 then
		player.bon[2]=math.floor(player.nat[5]/6)
		player.bon[4]=math.floor(player.nat[5]/6)
	elseif player.class==5 then
		player.bon[3]=math.floor(player.nat[6]/3)
	end
	player.stats={
		(player.nat[1]+player.eqs[1]+player.bon[1]+player.bst[1]),
		(player.nat[2]+player.eqs[2]+player.bon[2]+player.bst[2]),
		(player.nat[3]+player.eqs[3]+player.bon[3]+player.bst[3]),
		(player.nat[4]+player.eqs[4]+player.bon[4]+player.bst[4]),
		(player.nat[5]+player.eqs[5]+player.bon[5]+player.bst[5]),
		(player.nat[6]+player.eqs[6]+player.bon[6]+player.bst[6]),
	}
	player.SPD=(1.00-(player.stats[5]/100))
	player.MaxHP=(10*player.lvl)+(player.stats[1]*20)
	player.MaxMP=(5*player.lvl)+(player.stats[6]*10)
	player.MaxEP=(5*player.lvl)+(player.stats[6]*10)
	if player.HP>player.MaxHP then
		player.HP=player.MaxHP
	end
	if player.MP>player.MaxMP then
		player.MP=player.MaxMP
	end
	if player.EP>player.MaxEP then
		player.EP=player.MaxEP
	end
	player.weight=50
	for a=1,table.maxn(player.inv) do
		local w8=i.ReturnInfo(player.inv[a][1],5)
		player.weight=player.weight+(w8*player.inv[a][2])
	end
	for b=1,table.maxn(player.eqp) do
		local w8=i.ReturnInfo(player.eqp[b][1],5)
		player.weight=player.weight+w8
	end
end

function WhosYourDaddy()
	Cheat=true
end

function Statless()
	player=nil
	display.remove(LifeDisplay)
	display.remove(LifeWindow)
	display.remove(LifeSymbol)
	display.remove(ManaDisplay)
	display.remove(ManaWindow)
	display.remove(ManaSymbol)
	display.remove(EnergyDisplay)
	display.remove(EnergyWindow)
	display.remove(EnergySymbol)
	display.remove(XPSymbol)
	display.remove(XPDisplay)
	display.remove(StatSymbol)
	LifeDisplay=nil
	LifeWindow=nil
	LifeSymbol=nil
	ManaDisplay=nil
	ManaWindow=nil
	ManaSymbol=nil
	EnergyDisplay=nil
	EnergyWindow=nil
	EnergySymbol=nil
	XPSymbol=nil
	XPDisplay=nil
	StatSymbol=nil
end

function StatBoost(stat)
	player.bst[stat]=player.bst[stat]+1
	StatCheck()
end

function Natural(statnum,amnt)
	player.nat[statnum]=player.nat[statnum]+amnt
	player.pnts=player.pnts-(amnt)
	StatCheck()
end

function GrantXP(orbs)
	player.XP=player.XP+(orbs)
	if math.floor(player.XP)==0 then
		XPSymbol:setFrame( 1 )
	else
		timer.performWithDelay(50,OhCrap)
	end
end

function LvlUp()
	player.lvl=player.lvl+1
	local profit=player.XP-player.MaxXP
	player.XP=0+profit
	player.MaxXP=player.lvl*50
	
	if math.floor(player.XP)==0 then
		xpSymbol:setFrame( 1 )
	else
		timer.performWithDelay(50,OhCrap)
	end
	
	player.pnts=player.pnts+4
	
	player.MaxHP=(100*player.lvl)+(player.stats[1]*10)
	player.MaxMP=(player.lvl*15)+(player.stats[6]*10)
	player.HP=player.MaxHP
	player.MP=player.MaxMP
	LvlFanfare()
end

function LvlFanfare()
	a.Play(9)
	if not (LvlWindow) then
		transp10=255
		LvlWindow=display.newImageRect("fanfarelevelup.png",330,142)
		LvlWindow.xScale=2
		LvlWindow.yScale=LvlWindow.xScale
		LvlWindow.x=display.contentCenterX
		LvlWindow.y=display.contentCenterY-250
		LvlWindow:toFront()
		LvlWindow:setFillColor( transp10/255, transp10/255, transp10/255, transp10/255)
		timer.performWithDelay(10,LvlFanfare)
	else
		if transp10<20 then
			transp10=0
			display.remove(LvlWindow)
			LvlWindow=nil
		else
			transp10=transp10-(255/50)
			LvlWindow:setFillColor( transp10/255, transp10/255, transp10/255, transp10/255)
			LvlWindow:toFront()
			timer.performWithDelay(2,LvlFanfare)
		end
	end
end

function OhCrap()
	XPSymbol:toFront()
	XPDisplay:toFront()
	if XPSymbol.frame==50 and player.XP>player.MaxXP then
		LvlUp()
	elseif XPSymbol.frame>math.floor((player.XP/player.MaxXP)*50) then
		XPSymbol:setFrame(1)
		transp2=255
		XPSymbol:setFillColor(transp2/255,transp2/255,transp2/255,transp2/255)
		XPDisplay:setFillColor( 0, 0, 0,transp2)
		XPDisplay.text=((XPSymbol.frame*2).."%")
		timer.performWithDelay(50,OhCrap)
	elseif XPSymbol.frame<math.floor((player.XP/player.MaxXP)*50) then
		XPSymbol:setFrame(XPSymbol.frame+1)
		transp2=255
		XPSymbol:setFillColor(transp2/255,transp2/255,transp2/255,transp2/255)
		XPDisplay:setFillColor( 0, 0, 0,transp2/255)
		XPDisplay.text=((XPSymbol.frame*2).."%")
		timer.performWithDelay(50,OhCrap)
	elseif XPSymbol.frame==math.floor((player.XP/player.MaxXP)*50) and transp2~=0 then
		if statinfo[5][3]==0 then
			transp2=transp2-(255/50)
			if transp2<20 then
				transp2=0
			end
		else
			transp2=255
		end
		XPSymbol:setFillColor(transp2/255,transp2/255,transp2/255,transp2/255)
		XPDisplay:setFillColor( 0, 0, 0,transp2/255)
		timer.performWithDelay(50,OhCrap)
	end
end

function ModStats(sta,att,def,mgc,dex,int)
	player.eqs[1]=player.eqs[1]+sta
	player.eqs[2]=player.eqs[2]+att
	player.eqs[3]=player.eqs[3]+def
	player.eqs[4]=player.eqs[4]+mgc
	player.eqs[5]=player.eqs[5]+dex
	player.eqs[6]=player.eqs[6]+int
	StatCheck()
end

function LearnSorcery(id)
	player.spells[id][3]=true
	--print ("Player learned: "..player.spells[id][1])
end

function Load1(cls,chr)
--	print "Player loading..."
	Runtime:removeEventListener("enterFrame",ShowStats)
	display.remove(player)
	Statless()
	local char =chr
	local class=cls
	
	--Visual
	player=display.newSprite( psheet, pseqs )
	player:setSequence("stand1")
	player.x, player.y = display.contentWidth/2, display.contentHeight/2
	player.xScale=scale
	player.yScale=player.xScale
	player.char=char
	player.class=class
	
end

function Load2(stam,atk,dfnc,mgk,dxtrty,intlct)
	player.nat={}
	player.nat[1]=stam
	player.nat[2]=atk
	player.nat[3]=dfnc
	player.nat[4]=mgk
	player.nat[5]=dxtrty
	player.nat[6]=intlct
end

function Load3(stam,atk,dfnc,mgk,dxtrty,intlct)
	player.bst={}
	player.bst[1]=stam
	player.bst[2]=atk
	player.bst[3]=dfnc
	player.bst[4]=mgk
	player.bst[5]=dxtrty
	player.bst[6]=intlct
end

function Load4(pnts,lv,xpnts)
	player.lvl=lv
	player.MaxXP=player.lvl*50
	player.XP=xpnts
	player.pnts=pnts
end

function Load5(hitp,manp,enep,neim,golp)
	player.name=neim
	player.gp=golp
	player.MP=manp
	player.HP=hitp
	player.EP=enep
	FinishLoading()
end

function FinishLoading()
	local lang=lc.giveLang()
	if lang=="EN" then
		player.statnames={"Stamina",	"Attack",	"Defense",	"Magic",	"Dexterity",	"Intellect"}
	elseif lang=="ES" then
		player.statnames={"Aguante",	"Ataque",	"Defensa",	"Magia",	"Destreza",	"Intelecto"}
	end
	if lang=="EN" then
		player.clsnames={"Viking","Warrior","Knight","Sorcerer","Thief","Scholar","Freelancer"}
	elseif lang=="ES" then
		player.clsnames={"Vikingo","Guerrero","Caballero","Hechicero","Ladron","Erudito","Freelancer"}
	end
	player.eqs={0,0,0,0,0,0}
	player.bon={0,0,0,0,0,0}
	player.weight=5
	player.portcd=0
	player.stats={}
	player.inv={}
	player.eqp={}
	if lang=="EN" then
		player.spells={
			{"Gouge","Place a deep wound on the enemy target.",true,9,13},
			{"Fireball","Cast a firey ball of death and burn the enemy.",true,16,7},
			{"Cleave","Hits for twice maximum damage. Can't be evaded.",false,5,13},
			{"Slow","Reduces enemy's dexterity.",false,28,5},
			{"Poison Blade","Inflicts poison.",false,16,19},
			{"Fire Sword","Hits for twice damage and inflicts a burn.",false,26,37},
			{"Healing","Heals for 20% of your maximum health.",false,58,4},
			{"Ice Spear","Hits for twice damage and reduces enemy's dexterity.",false,51,46},
		}
	elseif lang=="ES" then
		player.spells={
			{"Rajar","Deja una herida profunda en el enemigo.",true,9,13},
			{"Bola de Fuego","Lanza una bola de fuego y enciende al enemigo.",true,16,7},
			{"Hender","Pega por el doble de tu da�o . No evitable.",false,5,13},
			{"Alentar","Reduce la destreza de tu enemigo.",false,28,5},
			{"Cuchilla Venenosa","Inflige veneno.",false,16,19},
			{"Espada Encendida","Pega por el doble de tu da�o y enciende al enemigo.",false,26,37},
			{"Curacion","Cura por 20% de tu vida maxima.",false,58,4},
			{"Lanza de Hielo","Pega por el doble de tu  da�o  y reduce la destreza de tu enemigo.",false,51,46},
		}
	end
	if (player) then
		check=119
		Runtime:addEventListener("enterFrame",ShowStats)
		su.FrontNCenter()
	end
end

function LoadSpells(name)
	for m=1,table.maxn(player.spells) do
		if player.spells[m][1]==name then
			player.spells[m][3]=true
		end
	end
end