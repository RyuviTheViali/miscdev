AddCSLuaFile()
XNC = XNC or {}
CNX = CNX or {}
XNC.XSDC = function(str,num,key)
	if not num then return "No Enumerator" end
	if not key then return "No Key" end
	local kle = string.byte(str:sub(1,1))
	str = base64.decode(str:sub(2))
	local kas = base64.decode(str:sub(1,kle))
	str = str:sub(kle+1)
	local nbits,ntq,del = {},{},0
	for k,v in pairs(string.Explode("",str)) do
		if string.byte(v) == 0x0ff then del = k end
	end
	local sts,ntq = string.Explode("",str:sub(0,del-1)),string.Explode("",str:sub(del+1))
	for k,v in pairs(sts) do
		local q,n = string.byte(v),string.byte(ntq[k])
		for i=1,n do q = q+num*8 end
		nbits[#nbits+1] = string.char(math.abs(bit.ror(q,num)) <= 0x0ff and bit.ror(q,num) or math.random(1,192))
	end
	if kas ~= key then
		local nr = {}
		for k,v in RandomPairs(sts) do nr[#nr+1] = string.char(math.random(1,192)) end
		return table.concat(nr)
	else
		return base64.decode(table.concat(nbits))
	end
end
XNC.XSEC = function(str,num,key)
	if not num then return "No Enumerator" end
	if not key then return "No Key" end
	str = base64.encode(str)
	local bits,nbits,ntq = {},{},{}
	for k,v in pairs(string.Explode("",str)) do
		bits[k] = string.byte(v)
	end
	for k,v in pairs(bits) do
		local q,n = bit.rol(v,num),0
		while q > 0x096 do q,n = math.floor(q-num*8),n+1 end
		nbits[#nbits+1] = string.char(q)
		ntq[#ntq+1] = string.char(n)
	end
	return string.char(#base64.encode(key))..base64.encode(base64.encode(key)..table.concat(nbits).."\xff"..table.concat(ntq))
end
CNX.NID = tonumber(base64.decode("Ng=="))
CNX.CID = base64.decode("NDYzOTgzNDQ0")