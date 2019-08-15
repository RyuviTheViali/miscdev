AddCSLuaFile()
if SERVER then
	do util.AddNetworkString("lloocckk") end
	net.Receive("lloocckk",function(len,ply)
		local p,e = net.ReadEntity(),net.ReadBool()
		if e then p:Lock() else p:UnLock() end
	end)
end

if CLIENT then
	hook.Add("InitPostEntity","LOCKABLE_CLIENT_INIT",function()
		local function SetLockState(ply,state)
			net.Start("lloocckk")
				net.WriteEntity(ply)
				net.WriteBool(state)
			net.SendToServer()
		end
		local m = LocalPlayer()
		hook.Add("ChatCommand","lock",function(com,paramstr,msg)
			if com:lower()~="lock" then return end
			SetLockState(m,true)
		end)
		hook.Add("ChatCommand","unlock",function(com,paramstr,msg)
			if com:lower()~="unlock" then return end
			SetLockState(m,false)
		end)
		hook.Remove("InitPostEntity","LOCKABLE_CLIENT_INIT")
	end)
end
