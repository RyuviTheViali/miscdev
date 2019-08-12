function Say(...)
    local first = true
    local msg = ""
    for k,v in pairs{...} do
      if first then
           first = false
       else
           msg = msg..' '
       end
       msg = msg..tostring(v)
    end
    msg = msg:gsub("\n",""):gsub(";",":"):gsub("\"","'")
    if SERVER then
        game.ConsoleCommand("say "..msg.."\n")
    elseif XChat and XChat.SendMessage then
        XChat:SendMessage(msg)
    else
        RunConsoleCommand("say",msg)
    end
end