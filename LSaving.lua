-----------------------------------------------------------------------------------------
--
-- Saving.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local b=require("Lbuilder")
local m=require("Ltiles")
local WD=require("Lprogress")
local su=require("Lstartup")
local v=require("Lversion")
local p=require("Lplayers")
local i=require("Lwindow")
local it=require("Litems")
local gp=require("Lgold")
local canMap=false
local saveSlot
local InvStrt
local EqpStrt
local SplStrt
local SplEnd
local Sve
local OKVers={
		"RELEASE 1.1.3",
	}

function Load()
	Sve={}
	local path = system.pathForFile(  "DoGSave"..saveSlot..".sav", system.DocumentsDirectory )
	for line in io.lines( path ) do
		n = tonumber(line)
		if n == nil then
			Sve[#Sve+1]=line
		else
			Sve[#Sve+1]=n
		end
	end
	
	local saveok=false
	for i=1,table.maxn(OKVers) do
		if Sve[1]==OKVers[i] then
			saveok=true
		end
	end
	
	if saveok==true then
		for o=1,table.maxn(Sve) do
			if (Sve[o])=="Spells"then
				SplStrt=o
			elseif (Sve[o])=="Eqp"then
				EqpStrt=o
			elseif (Sve[o])=="Inv"then
				InvStrt=o
			end
		end
		
		for l=1,table.maxn(Sve) do
			
			if (Sve[l])=="Round" then
				WD.RoundChange(Sve[l+1])
			
			elseif (Sve[l])=="Size" then
				b.Expand(false,Sve[l+1])
			
			elseif (Sve[l])=="Player" then
				-- Player Load 1 - Class & Char
				p.Load1(Sve[l+1],Sve[l+2])
				-- Player Load 2 - Natural Stats
				p.Load2(
					Sve[l+3],Sve[l+4],
					Sve[l+5],Sve[l+6],
					Sve[l+7],Sve[l+8]
				)
				-- Player Load 3 - Boost Stats
				p.Load3(
					Sve[l+9],Sve[l+10],
					Sve[l+11],Sve[l+12],
					Sve[l+13],Sve[l+14]
				)
				-- Player Load 4 - Stat Points, Level, XP
				p.Load4(
					Sve[l+15],Sve[l+16],
					Sve[l+17]
				)
				-- Player Load 5 - HP,MP,EP,Name,GP
				p.Load5(
					Sve[l+18],Sve[l+19],
					Sve[l+20],Sve[l+21],
					Sve[l+22]
				)
			elseif l>SplStrt and l<InvStrt then
				p.LoadSpells(Sve[l])
			elseif l==InvStrt then
				su.Operations2()
			elseif l>InvStrt and l<EqpStrt then
				if (l-InvStrt)%2==1 then
					local stacks=it.ReturnInfo(Sve[l],"stacks")
					i.AddItem(Sve[l],stacks,Sve[l+1])
				end
			
			elseif l>EqpStrt and (Sve[l])~=nil then
				i.SilentQuip(Sve[l])
			end
		end
	--	print "Save loaded successfully."
		LoadMap()
	else
	--	print "Save incompatible. Deleting..."
		WipeSave()
	end
end

function CheckSave(slot)
	local path = system.pathForFile(  "DoGSave"..slot..".sav", system.DocumentsDirectory )
	local fh, errStr = io.open( path, "r" )
	local okSave=false
	if (fh) then
		local contents = fh:read( "*a" )
	--	print( "Contents \n" .. contents )
		if (contents) and contents~="" and contents~=" " then
			Sve={}
			for line in io.lines( path ) do
				n = tonumber(line)
				if n == nil then
					Sve[#Sve+1]=line
				else
					Sve[#Sve+1]=n
				end
			end
			for i=1,table.maxn(OKVers) do
				if Sve[1]==OKVers[i] then
					okSave=true
				end
			end
			io.close(fh)
			if okSave==true then
				return Sve[27]
			else
				WipeSave(slot)
				return false
			end
		else
			io.close(fh)
			WipeSave(slot)
			return false
		end
	else
		-- io.close(fh)
		WipeSave(slot)
		return false
	end
end

function Save(doMap)
	local path = system.pathForFile(  "DoGSave"..saveSlot..".sav", system.DocumentsDirectory )
	local fh, errStr = io.open( path, "w+" )
	
	local GVer=v.HowDoIVersion()
	fh:write(GVer,"\n")
	
	local Round=WD.Circle()
	fh:write( "Round\n",Round,"\n")
	
	local Size=b.Expand(true)
	fh:write( "Size\n",Size,"\n")
	
	local P1=p.GetPlayer()
	fh:write("Player\n")
	--
	fh:write(P1.class,"\n",P1.char,"\n")
	--
	fh:write(P1.nat[1],"\n",P1.nat[2],"\n",P1.nat[3],
		"\n",P1.nat[4],"\n",P1.nat[5],"\n",P1.nat[6],
		"\n"
	)
	--
	fh:write(P1.bst[1],"\n",P1.bst[2],"\n",P1.bst[3],
		"\n",P1.bst[4],"\n",P1.bst[5],"\n",P1.bst[6],
		"\n"
	)
	--
	fh:write(P1.pnts,"\n",P1.lvl,"\n",P1.XP,"\n")
	--
	fh:write(P1.HP,"\n",P1.MP,"\n",P1.EP,"\n",P1.name,"\n",P1.gp,"\n")
	
	fh:write( "Spells\n")
	for s=1,table.maxn(P1.spells) do
		if P1.spells[s][3]==true then
			fh:write( P1.spells[s][1],"\n")
		end
	end
	
	fh:write( "Inv\n")
	for i=1,table.maxn(P1.inv) do
		if (P1.inv[i]) then
			fh:write( P1.inv[i][1],"\n")
			fh:write( P1.inv[i][2],"\n")
		end
	end
	fh:write( "Eqp\n")
	for i=1,table.maxn(P1.eqp) do
		if (P1.eqp[i]) then
			fh:write( P1.eqp[i][1],"\n")
		end
	end
	io.close( fh )
--	print ("Progress saved on floor "..Round..".")
	canMap=true
	if doMap==true then
		SaveMap()
	end
end

function WipeSave(slot)
	if not(slot)then
		local path = system.pathForFile(  "DoGSave"..saveSlot..".sav", system.DocumentsDirectory )
		local fh, errStr = io.open( path, "w+" )
		if (fh) then
			fh:write("")
			io.close( fh )
			
			local path = system.pathForFile(  "DoGMapSave"..saveSlot..".sav", system.DocumentsDirectory )
			local fh, errStr = io.open( path, "w+" )
			fh:write("")
			io.close( fh )
		end
	else
		local path = system.pathForFile(  "DoGSave"..slot..".sav", system.DocumentsDirectory )
		local fh, errStr = io.open( path, "w+" )
		
		fh:write("")
		io.close( fh )
		
		local path = system.pathForFile(  "DoGMapSave"..slot..".sav", system.DocumentsDirectory )
		local fh, errStr = io.open( path, "w+" )
		fh:write("")
		io.close( fh )
	end
end

function SaveMap()
	if canMap==true then
		canMap=false
		local path = system.pathForFile(  "DoGMapSave"..saveSlot..".sav", system.DocumentsDirectory )
		local fh, errStr = io.open( path, "w+" )
		
		local map=b.GetData(8,0)
		fh:write( "Map\n")
		for r in pairs(map) do
			fh:write("--\n")
			fh:write(r.."\n")
			if type(map[r])~="boolean" then
				for i in pairs(map[r]) do
					fh:write( map[r][i],"\n")
				end
			else
			end
		end
		fh:write("--\n")
		io.close( fh )
		local Round=WD.Circle()
	--	print ("Map saved on floor "..Round..".")
	end
end

function LoadMap()
	local firststop={}
	local Map={}
	local var={}
	local path = system.pathForFile(  "DoGMapSave"..saveSlot..".sav", system.DocumentsDirectory )
	for line in io.lines( path ) do
		n = tonumber(line)
		if n == nil then
			firststop[#firststop+1]=line
		else
			firststop[#firststop+1]=n
		end
	end
	for i=1,table.maxn(firststop) do
		if firststop[i]=="--" then
			if (var[#var]) then
				var[#var].endloc=i-1
			end
			if i~=table.maxn(firststop) then
				var[#var+1]={}
				var[#var].roomnum=firststop[i+1]
				var[#var].startloc=i+2
				Map[firststop[i+1]]={}
			end
		end
	end
	for v=1,table.maxn(var) do
		for l=var[v].startloc,var[v].endloc do
			Map[var[v].roomnum][l+1-var[v].startloc]=firststop[l]
		end
	end
	for r in pairs(Map) do
		if Map[r][1]==nil then
			Map[r]=false
		end
	end
	b.ReceiveMap(Map)
--	print "Map loaded successfully."
end

function setSlot(data)
	saveSlot=data
end