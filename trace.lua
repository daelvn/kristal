local args = {...}

if not args[1] then
	print("Usage:")
	print(shell.getRunningProgram() .. " <program> [program arguments, ...]")
	return
end

local path = shell.resolveProgram(args[1]) or shell.resolve(args[1])

-- here be dragons
local function buildStackTrace(rootErr)
	local trace = {}
	local i, hitEnd, _, e = 4, false

	repeat
		_, e = pcall(function() error("<tracemarker>", i) end)
		i = i + 1
		if e == "xpcall: <tracemarker>" or e == "pcall: <tracemarker>" then
			hitEnd = true
			break
		end
		table.insert(trace, e)
	until i > 10

	table.remove(trace)
	table.remove(trace, 1)

	if rootErr:match("^" .. trace[1]:match("^(.-:%d+)")) then table.remove(trace, 1) end

	local out = {}

	table.insert(out, rootErr)
	
	for i, v in ipairs(trace) do
		table.insert(out, "  at " .. v:match("^(.-:%d+)"))
	end

	if not hitEnd then
		table.insert(out, "  ...")
	end

	return table.concat(out, "\n")
end

if fs.exists(path) then
	local eshell = setmetatable({getRunningProgram=function() return path end}, {__index = shell})
	local env = setmetatable({shell=eshell}, {__index=_ENV})
	
	env.pcall = function(f, ...)
		local args = { ... }
		return xpcall(function() f(unpack(args)) end, buildStackTrace)
	end

	env.xpcall = function(f, e)
		return xpcall(function() f() end, function(err) e(buildStackTrace(err)) end)
	end

	local f = fs.open(path, "r")
	local d = f.readAll()
	f.close()
	
	local func, e = load(d, fs.getName(path), nil, env)
	if not func then
		printError("Syntax error:")
		printError("  " .. e)
	else
		table.remove(args, 1)
		xpcall(function() func(unpack(args)) end, function(err)
			local stack = buildStackTrace(err)
			printError("\nProgram has crashed! Stack trace:")
			printError(stack)
		end)
	end
else
	printError("program not found")
end