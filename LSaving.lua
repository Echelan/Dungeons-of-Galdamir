-----------------------------------------------------------------------------------------
--
-- Saving.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local p=require("Lplayers")
local gp=require("LGold")
local i=require("Lwindow")
local WD=require("LProgress")
local m=require("LMapHandler")
local it=require("LItems")
local b=require("LMapBuilder")
local Sve
local SplStrt
local SplEnd
local InvStrt
local EqpStrt

function Load()
	Sve={}
	local path = system.pathForFile(  "DoGSave.sav", system.DocumentsDirectory )
	for line in io.lines( path ) do
		n = tonumber(line)
		if n == nil then
			Sve[#Sve+1]=line
		else
			Sve[#Sve+1]=n
		end
	end
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
			m.Size(Sve[l+1])
		
		elseif (Sve[l])=="Player" then
			p.LoadPlayer( Sve[l+1],Sve[l+2],
				Sve[l+3],Sve[l+4],Sve[l+5],Sve[l+6],
				Sve[l+7],Sve[l+8],Sve[l+9],Sve[l+10],
				Sve[l+11],Sve[l+12],Sve[l+12]
			)
			
		elseif l>SplStrt and l<EqpStrt then
			p.LoadSpells(Sve[l])
		
		elseif l>EqpStrt and (Sve[l])~=nil then
			i.SilentQuip(Sve[l])
		
		elseif l>InvStrt and l<EqpStrt then
			if (l-InvStrt)%2==1 then
				local stacks=it.ReturnInfo(Sve[l],"stacks")
				i.AddItem(Sve[l],stacks,Sve[l+1])
			end
		end
	end
	b.YouShallNowPass()
end

function CheckSave()
	local path = system.pathForFile(  "DoGSave.sav", system.DocumentsDirectory )
	local fh, errStr = io.open( path, "r" )
	if (fh) then
		local contents = fh:read( "*a" )
	--	print( "Contents \n" .. contents )
		if (contents) and contents~="" and contents~=" " then
			return true
		else
			return false
		end
		
	else
		return false
	end
end

function Save()
	local path = system.pathForFile(  "DoGSave.sav", system.DocumentsDirectory )
	local fh, errStr = io.open( path, "w+" )
	
	local Round=WD.Circle()
	fh:write( "Round\n",Round,"\n")
	
	local Size=m.GetSize()
	fh:write( "Size\n",Size,"\n")
	
	local P1=p.GetPlayer()
	fh:write( "Player\n",P1.class,"\n",P1.char,"\n",P1.stats[1],
	"\n",P1.stats[2],"\n",P1.stats[3],"\n",P1.stats[4],"\n",P1.stats[5],
	"\n",P1.lvl,"\n",P1.XP,"\n",P1.HP,"\n",P1.MP,"\n",P1.name,"\n",P1.gp,"\n")
	
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
	print ("Progress saved on floor "..Round..".")
end