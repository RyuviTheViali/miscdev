local tag = "godmode"

local meta = FindMetaTable("Player")

function meta:GodEnable()
	self:AddFlags(FL_GODMODE)
	if SERVER and self.SetNetData then
		self:SetNetData("GodMode",true)
	end
end

function meta:GodDisable()
	self:RemoveFlags(FL_GODMODE)
	if SERVER and self.SetNetData then
		self:SetNetData("GodMode",false)
	end
end

if CLIENT then
	local convar = CreateClientConVar("cl_" .. tag, "0", true, true)

	cvars.AddChangeCallback("cl_" .. tag, function(_, old, new)
		if old == new then return end
		new = tonumber(new)
		if not new then return end

		convar:SetInt(new)
		net.Start(tag)
			net.WriteBool(new >= 1)
		net.SendToServer()
	end, tag)

end

if SERVER then

	util.AddNetworkString(tag)

	hook.Add("PlayerSpawn", tag, function(ply)
		local val = ply:GetInfoNum("cl_" .. tag, "0")
		if val >= 1 then
			ply:GodEnable()
		else
			ply:GodDisable()
		end
	end)

	net.Receive(tag, function(_, ply)
		local god = net.ReadBool()
		if god then
			ply:GodEnable()
		else
			ply:GodDisable()
		end
	end)

end