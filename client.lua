local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
lav = Tunnel.getInterface("ninelavagem",lav)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS --
-----------------------------------------------------------------------------------------------------------------------------------------
local andamento = false
local segundos = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCALIZAÇÃO DAS LAVAGENS DE DINHEIRO --
-----------------------------------------------------------------------------------------------------------------------------------------
local locais = {
	{ ['id'] = 1 , ['x'] = -1081.54, ['y'] = -261.36, ['z'] = 37.81, ['h'] = 209.77, },
	{ ['id'] = 2 , ['x'] = -1389.66, ['y'] = -584.98, ['z'] = 30.23, ['h'] = 31.19, }
}

local pedlist = {
	{  ['x'] = -1081.54, ['y'] = -261.36, ['z'] = 37.81, ['h'] = 209.77, ['hash'] = 0xFAB48BCB, ['hash2'] = "a_f_m_fatbla_01" },
	{ ['x'] = -1389.66, ['y'] = -584.98, ['z'] = 30.23, ['h'] = 31.19, ['hash'] = 0xD172497E, ['hash2'] = "a_m_m_afriamer_01" }
}

Citizen.CreateThread(function()
	for k,v in pairs(pedlist) do
		RequestModel(GetHashKey(v.hash2))
		while not HasModelLoaded(GetHashKey(v.hash2)) do
			Citizen.Wait(10)
		end

		local ped = CreatePed(4,v.hash,v.x,v.y,v.z-1,v.h,false,true)
		FreezeEntityPosition(ped,true)
		SetEntityInvincible(ped,true)
		SetBlockingOfNonTemporaryEvents(ped,true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSO --
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		for _,v in pairs(locais) do
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(v.x,v.y,v.z)
			local distance = GetDistanceBetweenCoords(v.x,v.y,cdz,x,y,z,true)
			if distance <= 1.5 and not andamento then
				drawTxt("PRESSIONE  ~r~E~w~  PARA INICIAR LAVAGEM",4,0.5,0.93,0.50,255,255,255,180)
				if IsControlJustPressed(0,38) and lav.checkDinheiro() and not IsPedInAnyVehicle(ped) then
					lav.lavagemPolicia(v.id,v.x,v.y,v.z,v.h)
					lav.webhookmafia ()
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INICIANDO LAVAGEM DE DINHEIRO --
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("iniciandolavagem1")
AddEventHandler("iniciandolavagem1",function(head,x,y,z)
	segundos = 0
	andamento = true
	SetEntityHeading(PlayerPedId(),head)
	SetEntityCoords(PlayerPedId(),x,y,z-1,false,false,false,false)
	SetCurrentPedWeapon(PlayerPedId(),GetHashKey("WEAPON_UNARMED"),true)
	TriggerEvent('cancelandolavagem',true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAGEM --
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if andamento then
			segundos = segundos - 1
			if segundos <= 0 then
				andamento = false
				ClearPedTasks(PlayerPedId())
				TriggerEvent('cancelandolavagem',false)
				lav.checkPayment()
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES --
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end