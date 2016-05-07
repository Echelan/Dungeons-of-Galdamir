-----------------------------------------------------------------------------------------
--
-- maps.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)
local mapsS={}
local mapsM={}
local mapsL={}
local tutorial={}
local test={}

--[[ KEY
a-						b-boundary
c-						d-break/wall
e-						f-
g-						h-healpad
i-energypad				j-manapad
k-keyblock				l-lava
m-portal1				n-portal2
�-portal3				o-wall
p-						q-alwaysbreakable
r-random				s-shop
t-						u-mobspawner
v-						w-water
x-walkable				y-
z-start/finish	

H = 10x10
S = 20x20
M = 30x30
L = 40x40
--]]
	
tut1={
	"b","b","b","b","b","b","b","b","b","b",
	"b","x","x","x","x","l","x","x","x","b",
	"b","o","o","o","o","o","o","o","h","b",
	"b","x","x","o","x","x","x","o","o","b",
	"b","x","o","o","x","o","o","o","o","b",
	"b","x","o","o","x","o","x","j","i","b",
	"b","x","x","x","x","o","x","o","x","b",
	"b","#","o","o","o","o","x","o","x","b",
	"b","x","x","x","w","x","x","o","z","b",
	"b","b","b","b","b","b","b","b","b","b",
	}

test1={
	"b","b","b","b","b","b","b","b","b","b",
	"b","z","x","o","x","x","x","q","u","b",
	"b","x","m","o","x","x","x","l","q","b",
	"b","o","o","o","x","x","x","x","x","b",
	"b","x","x","x","h","j","x","x","x","b",
	"b","x","x","x","i","s","x","x","x","b",
	"b","x","x","x","x","x","x","x","x","b",
	"b","x","w","x","x","x","x","n","x","b",
	"b","x","x","x","x","x","x","x","z","b",
	"b","b","b","b","b","b","b","b","b","b",
	}

map1H={
	"b","b","b","b","b","b","b","b","b","b",
	"b","z","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","z","b",
	"b","b","b","b","b","b","b","b","b","b",
	}
	
map1S={
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	"b","z","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","z","b",
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	}

map1M={
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	"b","z","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","z","b",
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	}

map1L={
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	"b","z","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","b",
	"b","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","r","z","b",
	"b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b","b",
	}

function CallMapGroups()
	mapsS={map1S}
	mapsM={map1M}
	mapsL={map1L}
	mapsH={map1H}
	tutorial={tut1}
	test={test1}
end

function GetMapGroups()
	return mapsS,mapsM,mapsL,mapsH,tutorial,test
end

