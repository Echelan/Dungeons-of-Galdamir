---------------------------------------------------------------------------------------
--
-- Saving.lua
--
---------------------------------------------------------------------------------------
module(..., package.seeall)

-- FORWARD CALLS
local key = { -- MAX: 62
		"0","1","2","3","4","5","6","7","8","9",
		"A","B","C","D","E","F","G","H","I","J",
		"K","L","M","N","O","P","Q","R","S","T",
		"U","V","W","X","Y","Z",
		"a","b","c","d","e","f","g","h","i","j",
		"k","l","m","n","o","p","q","r","s","t",
		"u","v","w","x","y","z",
	}
	
---------------------------------------------------------------------------------------
-- GLOBAL
---------------------------------------------------------------------------------------

local function readJSON(saveslot)
	-- # OPENING
	-- DEPENDENCIES
	local JSON=require("lua.json")
	-- FORWARD CALLS
	local filename
	local file
	local output
	-- LOCAL FUNCTIONS
	
	-- # BODY
	filename = system.pathForFile( saveslot )
	file = assert(io.open(filename, "r"))
	
	output = JSON:decode(file:read("*all"))
	
	-- # CLOSING
	return output
end

--[[ DEPRECATED
local function sumLarge(factor1, factor2)
	factor1=tostring(factor1)
	factor2=tostring(factor2)
	if #factor2>#factor1 then --factor1 siempre es mayor
		local temp=factor2
		factor2=factor1
		factor1=temp
	end
	local result=""
	local curdig=1
	while (#factor2>0 or #factor1>0) do
		local digfactor1=string.sub(factor1,#factor1,#factor1)
		local digfactor2=string.sub(factor2,#factor2,#factor2)
		factor1=string.sub(factor1,1,#factor1-1)
		factor2=string.sub(factor2,1,#factor2-1)
		digfactor1=tonumber(digfactor1)
		digfactor2=tonumber(digfactor2)
		if not (digfactor1) then
			digfactor1=0
		end
		if not (digfactor2) then
			digfactor2=0
		end
		
		local resultdig=digfactor1+digfactor2
		
		if (#result==curdig) then
			local asd=string.sub(result,1,1)
			result=string.sub(result,2,#result)
			asd=tonumber(asd)
			resultdig=resultdig+asd
		end
		resultdig=tostring(resultdig)
		
		result=resultdig..result
		curdig=curdig+1
	end
	return result
end
]]

--[[ DEV USE
local function printtable(param,space)
	space=space or ">"
	for k, v in pairs( param ) do
		if type(v)~="table" then
			print(space..k, v)
		else
			print (space..k.."={")
			printtable(v, "-"..space)
			print (space.."}")
		end
	end
end
]]

local function fileContents(filename)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local fh
	local errStr
	local contents
	-- LOCAL FUNCTIONS
	
	-- # BODY
	path = system.pathForFile(  filename, system.DocumentsDirectory )
	fh, errStr = io.open( path, "r")
	
	if (fh) then
		contents = fh:read( "*a" )
		io.close( fh )
	end
	
	if not(contents) then
		path=nil
	end
	
	-- # CLOSING
	return path,contents
end

function DecimalToBase(base, numero)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local str
	-- LOCAL FUNCTIONS
	
	-- # BODY
	str=""
	if base>table.maxn(key) then
		assert(false, "LA CAGASTE. BASE MAX="..table.maxn(key))
	else
		while numero>base-1 do
			str=key[(numero%base)+1]..str
			numero=math.floor(numero/base)
		end
		str=key[(numero%base)+1]..str
	end
	
	-- # CLOSING
	return str
end

function BaseToDecimal(base, numero)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local num
	local i
	local dig
	local j
	local found
	-- LOCAL FUNCTIONS
	
	-- # BODY
	num=0
	numero=tostring(numero)
	if base>table.maxn(key) then
		assert(false, "LA CAGASTE. BASE MAX="..table.maxn(key))
	else
		-- while numero>base-1 do
		i=0
		while #numero>0 do
			dig=string.sub(numero, #numero)
			numero=string.sub(numero, 1, #numero-1)
			
			
			j=1
			found=false
			while ( found==false and j<=table.maxn(key) ) do
				if (key[j]==dig) then
					found=true
				else
					j=j+1
				end
			end
			
			if found==false then
				assert(false, "Couldn't find '"..dig.."' in key.")
			end
			
			num=num+((j-1)*(base^i))
			i=i+1
		end
	end
	
	-- # CLOSING
	return num
end

function setSlot(value)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	-- LOCAL FUNCTIONS
	
	-- # BODY
	Save["SLOT"]=value
	
	-- # CLOSING
end



---------------------------------------------------------------------------------------
-- SAVE
---------------------------------------------------------------------------------------

Save = { }

function Save:keepMapData( mapSettings, generatedMap )
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local stringRegion
	-- LOCAL FUNCTIONS
	
	-- # BODY
	if ( not Save ["DATA"] ) then
		Save["DATA"] = { }
	end
	if ( not Save ["DATA"] .regions ) then
		Save["DATA"].regions = { }
	end
	
	for regionY = 1, mapSettings .maxRegions do
		for regionX = 1, mapSettings .maxRegions do
			local stringRegion = ""
	
			-- ADD REGION ADDRESS IN X
			local stringX = DecimalToBase ( 62, regionX )
			for i = #stringX, 1 do
				stringX = "0" .. stringX
			end
			stringRegion = stringRegion .. stringX
			
			-- ADD REGION ADDRESS IN Y
			local stringY = DecimalToBase ( 62, regionY )
			for i = #stringY, 1 do
				stringY = "0" .. stringY
			end
			stringRegion = stringRegion .. stringY
			
			-- SERIALIZE REGION
			-- A WALL IS REPRESENTED BY A 1
	
	
			-- FUTURE TILE CODES:
			-- 0: VOID
			-- 1: FLOOR
			-- 2: WALL
			-- 3: WEAK_WALL
			
			local startX = ((regionX - 1) * mapSettings .regionHalls) + 1
			local startY = ((regionY - 1) * mapSettings .regionHalls) + 1
			
			local endX = regionX * mapSettings .regionHalls
			local endY = regionY * mapSettings .regionHalls
			
			for y = startY, endY do
				local stringRow = ""
				for x = startX, endX do
					local value = 0
					if (generatedMap [y] [x] .isSolid) then
						value = 1
					end
					stringRow = stringRow .. value
				end
				
				stringRow = BaseToDecimal( 5, stringRow )
				stringRow = DecimalToBase( 62, stringRow )
				
				for i = #stringRow, 3 do
					stringRow = "0" .. stringRow
				end
				stringRegion = stringRegion .. stringRow
			end
			
			Save ["DATA"] .regions [table.maxn (Save["DATA"].regions) + 1] = stringRegion
			
		end
	end
	
	--[[
	-- REGION X POSITION
	
	stringRegion = ""
	if (x < 0) then
		stringRegion = stringRegion .. "-"
	else
		stringRegion = stringRegion .. "+"
	end
	
	x = math.abs ( x )
	x = DecimalToBase ( 62, x )
	for i = #x, 1 do
		x = "0" .. x
	end
	stringRegion = stringRegion .. x
	
	-- REGION Y POSITION
	
	if (y < 0) then
		stringRegion =stringRegion .. "-"
	else
		stringRegion = stringRegion .. "+"
	end
	
	y = math.abs ( y )
	y = DecimalToBase ( 62, y )
	for i = #y, 1 do
		y = "0" .. y
	end
	stringRegion = stringRegion .. y
	
	-- SERIALIZE REGION
	
	-- A WALL IS REPRESENTED BY A 1
	
	for i = 1, table.maxn (region) do
		fila = ""
		for j = 1, table.maxn (region [i]) do
			local value = 0
			if (region [j] [i] .solid) then
				value = 1
			end
			fila = fila .. value
		end
		
		fila = BaseToDecimal( 5, fila )
		fila = DecimalToBase( 62, fila )
		
		for i = #fila, 3 do
			fila = "0" .. fila
		end
		stringRegion = stringRegion .. fila
	end
	
	-- THIS CODE PREVENTED CONSTANT OVERWRITING OF REGION DATA WHEN REGIONS WERE SAVED ON LOAD AND UNLOAD
	-- SEEING AS NOW REGIONS ARE SAVED WHEN CREATED, THIS CODE IS UNNECESSARY, BUT IS KEPT FOR ARCHIVE PURPOSES
	
	-- found = false
	-- it = 1
	-- while (it <= table.maxn ( Save ["DATA"] .regions ) and found == false) do
		-- if (Save ["DATA"] .regions [it] == stringRegion) then
			-- found = true
		-- end
		-- it = it + 1
	-- end

	-- if (found == false) then
		Save ["DATA"] .regions [table.maxn (Save["DATA"].regions) + 1] = stringRegion
	-- end
	]]
	-- # CLOSING
end

--[[
function Save:keepRegionSeed(seed)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	-- LOCAL FUNCTIONS
	
	-- # BODY
	if not (Save["DATA"]) then
		Save["DATA"]={}
	end
	if not (Save["DATA"].regions) then
		Save["DATA"].regions={}
	end
	Save["DATA"].regions.seed = seed
	-- # CLOSING
end
]]

function Save:keepPlayerData(player)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local oldFile
	local player2
	-- LOCAL FUNCTIONS
	local function crunchTime(victim)
		for k, v in pairs( victim ) do
			if type(v)=="number" then
				-- print (k, v)
				v=DecimalToBase(62,v)
				victim[k]=tostring(v)
				
				for i=#victim,2 do
					victim[k]="0"..victim[k]
				end
			elseif type(v)=="table" then
				crunchTime(v)
			end
		end
	end
	
	-- # BODY
	if not (Save["DATA"]) then
		Save["DATA"]={}
	end
	
	oldFile=system.pathForFile( "TEMPSave"..Save["SLOT"]..".png", system.DocumentsDirectory)
	if (oldFile) then
		os.remove( oldFile )
	end
	display.save(player,"TEMPSave"..Save["SLOT"]..".png")
	
	player2={}
	player2["!N"]=player["NAME"] -- STRING
	player2["!G"]=player["GOLD"] -- INT -> INCREASE BASE
	
	player2["!MX"]=player["MAPX"] -- INT -> INCREASE BASE
	player2["!MY"]=player["MAPY"] -- INT -> INCREASE BASE
	player2["!CY"]=player["CURY"] -- INT -> INCREASE BASE
	player2["!CX"]=player["CURY"] -- INT -> INCREASE BASE
	
	player2["!S"]={}
	for i=1,table.maxn(player["STATS"]) do
		player2["!S"][i]=player["STATS"][i]
		player2["!S"][i]["ID"]=nil
		player2["!S"][i]["DESCRIPTION"]=nil
		player2["!S"][i]["NAME"]=nil
		player2["!S"][i]["TOTAL"]=nil
		player2["!S"][i]["!B"]=player2["!S"][i]["BOOST"] -- INT -> INCREASE BASE
		player2["!S"][i]["!N"]=player2["!S"][i]["NATURAL"] -- INT -> INCREASE BASE
		player2["!S"][i]["BOOST"]=nil
		player2["!S"][i]["NATURAL"]=nil
		player2["!S"][i]["EQUIP"]=nil
	end
	
	player2["!E"]=player["STATS"]["Energy"] -- INT -> INCREASE BASE
	player2["!F"]=player["STATS"]["Free"] -- INT -> INCREASE BASE
	player2["!H"]=player["STATS"]["Health"] -- INT -> INCREASE BASE
	player2["!M"]=player["STATS"]["Mana"] -- INT -> INCREASE BASE
	player2["!L"]=player["STATS"]["Level"] -- INT -> INCREASE BASE
	player2["!X"]=player["STATS"]["Experience"] -- INT -> INCREASE BASE
	
	player2["!S"]=player["SPELLS"] -- TABLE -> PARSE
	player2["!I"]=player["INVENTORY"] -- TABLE -> PARSE
	for i=1,table.maxn(player2["!I"]) do
		player2["!I"][i]["!A"]=player2["!I"][i]["AMOUNT"] -- INT -> INCREASE BASE
		player2["!I"][i]["!ID"]=player2["!I"][i]["ID"] -- INT -> INCREASE BASE
		player2["!I"][i]["AMOUNT"]=nil
		player2["!I"][i]["ID"]=nil
	end
	player2["!I"]["SLOTS"]=nil
	player2["!C"]=player["EQUIPMENT"] -- TABLE -> PARSE
	player2["!Q"]=player["QUESTS"] -- TABLE -> PARSE
	
	player=nil
	
	crunchTime(player2)
	
	player2=JSON:encode(player2)
	
	player2=string.gsub(player2, "\"", "")
	player2=string.gsub(player2, "\,", "")
	player2=string.gsub(player2, "\:", "")
	Save["DATA"].p1=player2
	
	-- # CLOSING
end

function Save:recordData()
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local fh
	local errStr
	local oldFile
	-- LOCAL FUNCTIONS
	
	-- # BODY
	path = system.pathForFile(  "Save"..Save["SLOT"]..".sav", system.DocumentsDirectory )
	fh, errStr = io.open( path, "w+" )
	
	oldFile=system.pathForFile( "Save"..Save["SLOT"]..".png", system.DocumentsDirectory)
	if (oldFile) then
		os.remove( oldFile )
	end
	os.rename( system.pathForFile( "TEMPSave"..Save["SLOT"]..".png", system.DocumentsDirectory ), system.pathForFile( "Save"..Save["SLOT"]..".png", system.DocumentsDirectory )	)
	
	fh:write( Save["DATA"].p1, "\n" )
	fh:write( JSON:encode_pretty(Save["DATA"].regions), "\n" )
	io.close( fh )
	
	-- # CLOSING
end



---------------------------------------------------------------------------------------
-- LOAD
---------------------------------------------------------------------------------------

Load = { }

function Load:retrieveData()
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local contents
	local player
	local maps
	local player2
	local one
	local two
	local sandwich
	-- LOCAL FUNCTIONS
	
	-- # BODY
	local path,contents=fileContents("Save"..Save["SLOT"]..".sav")
	if (contents) then
		for line,a in io.lines( path ) do
			if not(player) then
				player=line
			else
				maps=line
			end
		end
		maps=JSON:decode(maps)
		
		if not (Save["DATA"]) then
			Save["DATA"]={}
		end
		
		Save["DATA"].maps=maps
		Save["DATA"].p1=player
		
		-- print ("INTERPRETING...")
		-- print ("RAW: "..player)
		player2=string.gsub(player,"\!%u+","\"\,\"%1\":\"")
		player2="{"..string.sub(player2,4)
		player2=string.sub(player2,1,#player2-1).."\"}"
		-- print ("UNCRUNCHED: "..player2)
		
		-- NAME FIX
		one,two=string.find(player2,"\!N.+\,\"\!Q")
		sandwich=string.sub(player2,one,two-5)
		sandwich=string.gsub(sandwich,"\":\"","")
		sandwich=string.gsub(sandwich,"\!N","\!N\":\"")
		sandwich=sandwich.."\",\"!Q"
		player2=string.gsub(player2,"\!N.+\,\"\!Q",sandwich)
		-- print ("NAME FIX: "..player2)
		
		-- EQUIPS FIX
		one,two=string.find(player2,"\!C\".+\,\"\!CX")
		sandwich=string.sub(player2,one+4,two-4)
		sandwich=string.gsub(sandwich,"\"","")
		sandwich="!C\":"..sandwich.."\"!CQ"
		player2=string.gsub(player2,"\!C\".+\,\"\!CX",sandwich)
		-- print ("EQUIPS FIX: "..player2)
		
		-- SPELLS FIX
		one,two=string.find(player2,"\!S.+\,\"\!X")
		sandwich=string.sub(player2,one+4,two-4)
		sandwich=string.gsub(sandwich,"\"","")
		sandwich="!S\":"..sandwich..",\"!X"
		player2=string.gsub(player2,"\!S.+\,\"\!X",sandwich)
		-- print ("SPELLS FIX: "..player2)
		
		-- QUESTS FIX
		one,two=string.find(player2,"\!Q.+\,\"\!S")
		sandwich=string.sub(player2,one+4,two-4)
		sandwich=string.gsub(sandwich,"\"","")
		sandwich="!Q\":"..sandwich..",\"!S"
		player2=string.gsub(player2,"\!Q.+\,\"\!S",sandwich)
		-- print ("QUESTS FIX: "..player2)
		
		-- INVENTORY FIX
		one,two=string.find(player2,"\!I\".+\,\"\!L")
		sandwich=string.sub(player2,one+4,two-4)
		sandwich=string.gsub(sandwich,"\"","")
		sandwich=string.gsub(sandwich,"}{","},{")
		sandwich=string.gsub(sandwich,",","",1)
		sandwich=string.gsub(sandwich,"!A:","\"!A\":\"")
		sandwich=string.gsub(sandwich,"!ID:","\"!ID\":\"")
		sandwich=string.gsub(sandwich,"}","\"}")
		sandwich=string.gsub(sandwich,",","\",")
		sandwich=string.gsub(sandwich,"}\",","},")
		sandwich=string.gsub(sandwich,"\",\"!A","\"!A")
		sandwich="!I\":"..sandwich..",\"!L"
		player2=string.gsub(player2,"\!I\".+\,\"\!L",sandwich)
		-- print ("INVENTORY FIX: "..player2)
		
		-- print ("FIXES DONE:"..player2)
		player2=JSON:decode(player2)
		-- print ("JSONDECODED: ")
		-- printtable(player2)
		
		for k, v in pairs( player2 ) do
			if type(v)=="table" then
				for i=1,table.maxn(player2[k]) do
					for l, w in pairs( player2[k][i] ) do
						player2[k][i][l]=BaseToDecimal(62,w)
					end
				end
			elseif type(v)=="string" and k~="!N" then
				player2[k]=BaseToDecimal(62,v)
			end
		end
	end
	
	-- # CLOSING
	return player2
end

function Load:getName(slot)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local contents
	local name
	local one
	local two
	-- LOCAL FUNCTIONS
	
	-- # BODY
	path,contents=fileContents("Save"..slot..".sav")
	if (contents) then
		for line,a in io.lines( path ) do
			if not(name) then
				name=line
			end
		end
		
		name=string.gsub(name,"\!%u+","\"\,\"%1\":\"")
		
		one,two=string.find(name,"\!N.+\,\"\!Q")
		name=string.sub(name,one,two-5)
		name=string.gsub(name,"\":\"","")
		name=string.gsub(name,"\!N","")
	end
	
	-- # CLOSING
	return name
end

function Load:getExtraInfo(slot)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local contents
	local info
	local one
	local two
	local gold
	local level
	-- LOCAL FUNCTIONS
	
	-- # BODY
	path,contents=fileContents("Save"..slot..".sav")
	if (contents) then
		for line,a in io.lines( path ) do
			if not(info) then
				info=line
			end
		end
		
		info=string.gsub(info,"\!%u+","\"\,\"%1\":\"")
		
		one,two=string.find(info,"\!G.+\,\"\!H")
		gold=string.sub(info,one+5,two-5)
		
		one,two=string.find(info,"\!L.+\,\"\!M\"")
		level=string.sub(info,one+5,two-6)
		
		gold=BaseToDecimal(62,gold)
		level=BaseToDecimal(62,level)
	end
	
	-- # CLOSING
	return gold,level
end

function Load:getRegion(mapx,mapy)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local found
	local counter
	local thismapx
	local xneg
	local thismapy
	local yneg 	
	local parsed = nil
	local mapinfo
	local stringpos
	local estacol
	local temp
	-- LOCAL FUNCTIONS
	
	-- # BODY
	found=false
	counter=1
	
	if (Save["DATA"]) and (Save["DATA"].regions) then
		while found==false and counter<=table.maxn(Save["DATA"].regions) do
			
			thismapx=string.sub(Save["DATA"].regions[counter],1,2)
			thismapx=BaseToDecimal(62,thismapx)
			
			thismapy=string.sub(Save["DATA"].regions[counter],3,4)
			thismapy=BaseToDecimal(62,thismapy)
			
			if thismapx==mapx and thismapy==mapy then
				found=true
			else
				counter=counter+1
			end
		end
		
		if (found==true) then
			parsed={}
			
			mapinfo=string.sub(Save["DATA"].regions[counter],7)
			for i=1,#mapinfo/4 do
				stringpos=(i*4)
				parsed[i]=string.sub(mapinfo,stringpos-3, stringpos)
			end
			mapinfo=nil
			
			for i=1,table.maxn(parsed) do
				parsed[i]=BaseToDecimal(62,parsed[i])
				parsed[i]=DecimalToBase(5,parsed[i])
				for j=#parsed[i],9 do
					parsed[i]="0"..parsed[i]
				end
				estacol={}
				for j=1,#parsed[i] do
					estacol[j]=tonumber(string.sub(parsed[i],j, j))
				end
				parsed[i]=estacol
			end
			
			for i=1,table.maxn(parsed) do
				for j=i,table.maxn(parsed[i]) do
					temp=parsed[i][j]
					parsed[i][j]=parsed[j][i]
					parsed[j][i]=temp
				end
			end
		end
	end
	
	-- # CLOSING
	return parsed
end

function Load:regionExists(mapx,mapy)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local found
	local counter
	local thismapx
	local xneg
	local thismapy
	local yneg
	-- LOCAL FUNCTIONS
	
	-- # BODY
	found=false
	counter=1
	
	if (Save["DATA"]) and (Save["DATA"].regions) then
		while found==false and counter<=table.maxn(Save["DATA"].regions) do
			
			thismapx=string.sub(Save["DATA"].regions[counter],1,2)
			thismapx=BaseToDecimal(62,thismapx)
			
			
			thismapy=string.sub(Save["DATA"].regions[counter],3,4)
			thismapy=BaseToDecimal(62,thismapy)
			
			if thismapx==mapx and thismapy==mapy then
				found=true
			else
				counter=counter+1
			end
		end
		
	end
	
	-- # CLOSING
	return found
end



---------------------------------------------------------------------------------------
-- ERASE
---------------------------------------------------------------------------------------

Erase = { }

function Erase:clearSave(slot)
	-- # OPENING
	-- DEPENDENCIES
	-- FORWARD CALLS
	local path
	local success
	local errStr
	-- LOCAL FUNCTIONS
	
	-- # BODY
	path = system.pathForFile(  "Save"..slot..".sav", system.DocumentsDirectory )
	success,errStr=os.remove(path)
	
	-- # CLOSING
end

