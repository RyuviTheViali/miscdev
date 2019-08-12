local function GetRecursive(tab,part)
	tab[#tab+1] = part
	if part:HasChildren() then for k,v in pairs(part:GetChildren()) do GetRecursive(tab,v) end end
end

--HELLO

function SearchPACParts(ply,cls,nam)
	nam,cls = nam or "",cls or ""
	local parts,allparts = {},{}
	for k,v in pairs(ply.pac_parts or {}) do GetRecursive(allparts,v) end
	for k,v in pairs(allparts) do
		if cls == "" then
			parts[#parts+1] = v
		else
			if v.ClassName == cls then if v.Name:find(nam) then parts[#parts+1] = v end end
		end
	end
	return parts
end

local function RefreshModels(ply,find)
	for k,v in pairs(SearchPACParts(ply,"model")) do
		local mod = v:GetModel()
		if not mod:lower():find("https://") then continue end
		local found = true
		for kk,vv in pairs(find) do if not mod:lower():find(vv) then found = false end end
		if found then
			pac.urlobj.Cache[mod] = nil
			v:SetModel(v:GetModel())
		end
	end
end

hook.Add("ChatCommand","pacrefresh",function(c,a,m)
	if c:lower() == "pacrefresh" or c:lower() == "pref" then
		local atab = string.Explode(",",a)
		local ply,find = easylua.FindEntity(atab[1]),{}
		for i=2,#atab do if atab[i] ~= "" then find[#find+1] = atab[i] end end
		RefreshModels(ply,find)
	end
end)

concommand.Add("pacrefresh",function(p,c,a)
	local ply,find = easylua.FindEntity(a[1]),{}
	for i=2,#a do if a[i] ~= "" then find[#find+1] = a[i] end end
	RefreshModels(ply,find)
end)