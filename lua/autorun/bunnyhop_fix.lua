hook.Add("Initialize", "bunnyhop_fix", function()
	hook.Remove("Initialize", "bunnyhop_fix")

	function GAMEMODE:StartMove() end
	function GAMEMODE:FinishMove() end
end)

if SERVER then
	game.ConsoleCommand("sv_sticktoground 0\n")
end

