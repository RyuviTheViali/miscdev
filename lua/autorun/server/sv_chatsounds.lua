if CLIENT then return end

util.AddNetworkString("newchatsounds")

net.Receive("newchatsounds",function(l,p)
	local ply,str = p,net.ReadString()
	local senders = player.GetAll()
	table.RemoveByValue(senders,ply)

	net.Start("newchatsounds")
		net.WriteEntity(ply)
		net.WriteString(str)
	net.Send(senders)
end)
