-----------------------------------------------------------------------------------------
--
-- Quest.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local coinsheet = graphics.newImageSheet( "bluecoinsprite.png", { width=32, height=32, numFrames=8 } )
local qsheet = graphics.newImageSheet( "quest.png", { width=447, height=80, numFrames=7 } )
local b=require("Lbuilder")
local gp=require("Lgold")
local set=require("Lsettings")
local lc=require("Llocale")
local WD=require("Lprogress")
local mob=require("Lmobai")
local HasQuest
local gqm
local QuestType
local NumKills
local CurKills
local MobLvl
local NumItem
local QUpdate
local CurItem
local AmCoins
local locaX
local locaY
local coins={}
local ItemName
local ItemNames={}
ItemNames["EN"]={
		"Magical Trinket",
		"Guard Insignia",
		"Ancient Book",
		"Mirror Fragment",
		"Dragon Claw",
	}
ItemNames["ES"]={
		"Baratija Magica",
		"Insignia de Guardia",
		"Libro Antiguo",
		"Fragmento de Espejo",
		"Garra de dragon",
	}

function Essentials()
	HasQuest=false
	gqm=display.newGroup()
	local info=set.Get(6)
	locaX=info[1]
	locaY=info[2]
end

function CreateQuest()
	if HasQuest==false then
	--	local roll=math.random(1,10)
		roll=6
		if roll>=6 then
	--		print "Quest get."
			HasQuest=true
			QWindow=display.newSprite( qsheet, { name="quest", start=1, count=7, time=1000,loopCount=1}  )
			QWindow.x= locaX
			QWindow.y= locaY
			QWindow:play()
			gqm:insert(QWindow)
			
			local lang=lc.giveLang()
			local text
			if lang=="EN" then
				text="Current Quest:"
			elseif lang=="ES" then
				text="Mision Actual:"
			end
			QTitle=display.newText(text,0,0,"MoolBoran",40)
			QTitle.anchorX=0
			QTitle.anchorY=0
			QTitle.x=QWindow.x-155
			QTitle.y=QWindow.y-35,
			QTitle:setFillColor( 255/255, 255/255, 255/255)
			gqm:insert(QTitle)
			
			QuestType=math.random(1,3)
	--		print ("QuestID: "..QuestType)
			if QuestType==1 then
				local mobs=mob.GetMobGroup()
				local mobcount=0
				for i=1, table.maxn( mobs ) do
					if (mobs[i]) then
						mobcount=mobcount+1
					end
				end
				local mobPerc=math.random(3,6)
				if mobcount>=mobPerc then
					CurKills=0
					NumKills=math.random(1,math.floor(mobcount/mobPerc))
					
					local text1
					local text2
					local text3
					if lang=="EN" then
						text1="Defeat"
						text2="mobs."
					elseif lang=="ES" then
						text1="Derrota"
						text2="enemigos."
					end
					QText=display.newText((text1.." "..NumKills.." "..text2.." ("..CurKills.."/"..NumKills..")"),0,0,"MoolBoran",40)
					QText.anchorX=0
					QText.anchorY=1.0
					QText.x=QWindow.x-155
					QText.y=QWindow.y+55
					QText:setFillColor( 255/255, 255/255, 255/255)
					gqm:insert(QText)
					if NumKills==0 then
	--					print "Quest Error. Wiping quest..."
						WipeQuest()
					end
				else
	--				print "Quest Error. Wiping quest..."
					WipeQuest()
				end
			end
			if QuestType==2 then
			
				CurItem=0
				ItemName=(math.random(1,table.maxn(ItemNames[lang])))
				NumItem=math.random(1,4)
				
				QText=display.newText((ItemNames[lang][ItemName].."s: ("..CurItem.."/"..NumItem..")"),0,0,"MoolBoran",40)
				QText.anchorX=0
				QText.anchorY=1.0
				QText.x=QWindow.x-155
				QText.y=QWindow.y+55
				QText:setFillColor( 255/255, 255/255, 255/255)
				gqm:insert(QText)
			end
			if QuestType==3 then
				local mobs=mob.GetMobGroup()
				local mobcount=0
				for i=1, table.maxn( mobs ) do
					if (mobs[i]) then
						mobcount=mobcount+1
					end
				end
				local mobPerc=math.random(3,6)
				if mobcount>=mobPerc then
					CurKills=0
					NumKills=math.random(1,math.floor(mobcount/mobPerc))
					local size=b.GetData(0)
					local zonas=((math.sqrt(size))/10)
					local round=WD.Circle()
					MobLvl=(math.random(1,zonas)+(zonas*(round-1)))
					
					local text1
					local text2
					local text3
					if lang=="EN" then
						text1="Defeat"
						text2="level"
						text3="mobs."
					elseif lang=="ES" then
						text1="Derrota"
						text2="nivel"
						text3="enemigos."
					end
					
					QText=display.newText((text1.." "..NumKills.." "..text2.." "..MobLvl.." "..text3.." ("..CurKills.."/"..NumKills..")"),0,0,"MoolBoran",40)
					QText.anchorX=0
					QText.anchorY=1.0
					QText.x=QWindow.x-155
					QText.y=QWindow.y+55
					QText:setFillColor( 255/255, 255/255, 255/255)
					gqm:insert(QText)
					if NumKills==0 then
	--					print "Quest Error. Wiping quest..."
						WipeQuest()
					end
				else
	--				print "Quest Error. Wiping quest..."
					WipeQuest()
				end
			end
		end
	end
end

function UpdateQuest(val,val2)
	if HasQuest==true then
		local lang=lc.giveLang()
		if QuestType==1 and val=="mob" then
	--		print "Quests updated."
			QWindow:setFrame(1)
			QWindow:play()
			CurKills=CurKills+1
			QText.text=("Defeat "..NumKills.." mobs. ("..CurKills.."/"..NumKills..")")
			if CurKills==NumKills then
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				
				QUpdate=display.newText(("Quest complete!"),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
				
				QuestComplete()
			else
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				QUpdate=display.newText((QText.text),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
			end
		end
		if QuestType==2 and val=="itm" then
	--		print "Quests updated."
			QWindow:setFrame(1)
			QWindow:play()
			CurItem=CurItem+1
			QText.text=(ItemNames[lang][ItemName].."s: ("..CurItem.."/"..NumItem..")")
			if CurItem==NumItem then
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				QUpdate=display.newText(("Quest complete!"),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
				
				QuestComplete()
			else
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				QUpdate=display.newText((QText.text),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
			end
		end
		if QuestType==3 and val=="mob" and val2==MobLvl then
	--		print "Quests updated."
			QWindow:setFrame(1)
			QWindow:play()
			CurKills=CurKills+1
			QText.text=("Defeat "..NumKills.." level "..MobLvl.." mobs. ("..CurKills.."/"..NumKills..")")
			if CurKills==NumKills then
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				QUpdate=display.newText(("Quest complete!"),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				QUpdate:setFillColor( transp/255, transp/255, transp/255, transp/255)
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
				
				QuestComplete()
			else
				if (QUpdate)then
					Runtime:removeEventListener("enterFrame",HandleIt)
					display.remove(QUpdate)
					QUpdate=nil
					display.remove(QUWindow)
					QUWindow=nil
				end
				transp=255
				QUpdate=display.newText((QText.text),0,0,"MoolBoran",70)
				QUpdate.x=display.contentCenterX
				QUpdate.y=display.contentHeight*.25
				Runtime:addEventListener("enterFrame",HandleIt)
				
				QUWindow=display.newRect (0,0,#QUpdate.text*22,60)
				QUWindow:setFillColor( 0, 0, 0,transp/2/255)
				QUWindow.x=QUpdate.x
				QUWindow.y=QUpdate.y-15
				QUpdate:toFront()
			end
		end
	end
end

function HandleIt()
	if transp<100 then
		transp=0
	else
		transp=transp-(255/350)
	end
	QUWindow:toFront()
	QUWindow:setFillColor( 0, 0, 0,transp/2/255)
	QUpdate:toFront()
	QUpdate:setFillColor( transp/255, transp/255, transp/255, transp/255)
	if transp==0 then
		Runtime:removeEventListener("enterFrame",HandleIt)
		display.remove(QUpdate)
		QUpdate=nil
		display.remove(QUWindow)
		QUWindow=nil
	end
end

function WipeQuest()
	if HasQuest==true then
	--	print "Quests wiped."
		for i=gqm.numChildren,1,-1 do
			local child = gqm[i]
			child.parent:remove( child )
		end
		HasQuest=false
	end
end

function QuestComplete()
	if HasQuest==true then
	--	print "Quest complete!"
		if QuestType==1 then
			local Round=WD.Circle()
			local gold=math.floor((Round*NumKills)/2)
			if gold>0 then
				gp.CallAddCoins(gold)
			end
			AmCoins=gold
		end
		if QuestType==2 then
			local Round=WD.Circle()
			local gold=math.floor((Round*(NumItem*3))/2)
			if gold>0 then
				gp.CallAddCoins(gold)
			end
			AmCoins=gold
		end
		if QuestType==3 then
			local Round=WD.Circle()
			local gold=math.floor((Round*NumKills*MobLvl)/2)
			if gold>0 then
				gp.CallAddCoins(gold)
			end
			AmCoins=gold
		end
		BlueCoins()
		BlueCoinz()
		HasQuest=false
	end
end

function BlueCoins()
	if AmCoins>0 then
		coins[#coins+1]=display.newSprite( coinsheet, { name="coin", start=1, count=8, time=500,}  )
		coins[#coins].x=display.contentWidth-416
		coins[#coins].y=130
		physics.addBody(coins[#coins], "dynamic", { friction=0.5, radius=15.0} )
		coins[#coins]:setLinearVelocity((math.random(-200,200)),-300)
		coins[#coins]:play()
		AmCoins=AmCoins-1
		timer.performWithDelay(50,BlueCoins)
	end
end

function BlueCoinz()
	for i=1,table.maxn(coins) do
		if coins[i] then
			if (coins[i].y) then
				if coins[i].y>(display.contentHeight+10) then
					table.remove(coins,(i))
				end
			end
		end
	end
	if table.maxn(coins)>0 then
		timer.performWithDelay(20,BlueCoinz)
	else
		for i=gqm.numChildren,1,-1 do
			local child = gqm[i]
			child.parent:remove( child )
		end
	end
end

function ReturnQuest()
	if HasQuest==true then
		if QuestType==1 then
			return QuestType
		elseif QuestType==2 then
			local lang=lc.giveLang()
			return QuestType,ItemNames[lang][ItemName]
		elseif QuestType==3 then
			return QuestType
		elseif QuestType==4 then
			return QuestType
		end
	else
		return nil
	end
end