local duperestrictions = {
	["duplicator"] = true
}

hook.Add("CanTool","Dupe Restrictions",function(ply,trace,tool)
	if ply.Unrestricted then return end
	
	if duperestrictions[tool] and not ply:CheckUserGroupLevel("designers") then
		return false
	end
end)