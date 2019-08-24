if CLIENT then return end
if not SprayURL then return end
SprayURL.AllowedWebsites[#SprayURL.AllowedWebsites+1] = "gmod.xenora.net"