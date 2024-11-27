-- STRING HELPER FUNCTIONS

---@param inputstr string
---@param at integer
---@return string
function strCharAt(inputstr, at)
	return inputstr:sub(at, at)
end

---@param inputstr string
---@param of string
---@return boolean
function strContains(inputstr, of)
	return strCountOcurrences(inputstr, of) > 0
end

---@param inputstr string
---@param of string
---@return integer
function strCountOcurrences(inputstr, of)
	local _, count = inputstr:gsub(of, '')
	return count
end

---@param inputstr string
---@param at integer?
---@param replaceWith string
---@return string
function strReplaceAt(inputstr, at, replaceWith)
	return inputstr:sub(1, at - 1) .. replaceWith .. inputstr:sub(at + 1)
end

---@param inputstr string
---@param tofind string
---@return integer?
function strFirstIndexOf(inputstr, tofind)
	return inputstr:find(tofind, 1, true)
end

---@param inputstr string
---@param tofind string
---@return integer?
function strLastIndexOf(inputstr, tofind)
	return inputstr:find(tofind .. '[^' .. tofind .. ']*$')
end

---@param inputstr string
---@param sep string
---@return string[]
function strSplit(inputstr, sep)
	local t = {}
	for str in str.gmatch(inputstr, '([^' .. sep .. ']+)') do
		table.insert(t, str)
	end
	return t
end

---@param inputstr string
---@param regexp string
---@return string[]
function gmatchAsArray(inputstr, regexp)
	local t = {}
	for str in str.gmatch(inputstr, regexp) do
		table.insert(t, str)
	end
	return t
end

---@param inputstrarr string[]
---@param joinStr string
---@return string
function strJoin(inputstrarr, joinStr)
	local finalStr = ''

	for i = 1, #inputstrarr do
		finalStr = finalStr .. inputstrarr[i]

		if i < #inputstrarr then
			finalStr = finalStr .. joinStr
		end
	end

	return finalStr
end

---@param inputstr string
---@param target string
---@param replacement string
---@return string
function strReplace(inputstr, target, replacement)
	local str, _ = string.gsub(inputstr, target, replacement)
	return str
end

--ARRAY HELPER FUNCTIONS

---@param arr any[]
---@param f function
---@return any[]
function arrMap(arr, f)
	local t = {}
	for k, v in pairs(arr) do
		t[k] = f(v)
	end
	return t
end

---@param arr any[]
---@return any[]
function arrFlip(arr)
	local t = {}
	for i = 1, #arr do
		t[#arr - i + 1] = arr[i]
	end
	return t
end

---@param arr any[]
---@param f function
---@return any[]
function arrFilter(arr, f)
	local t = {}
	for i = 1, #arr do
		if f(arr[i]) then
			table.insert(t, arr[i])
		end
	end
	return t
end

---@param arr any[]
---@return boolean
function arrContains(arr, val)
	for _, value in ipairs(arr) do
		if value == val then
			return true
		end
	end

	return false
end

---@return any[]
function arrConcat(...)
	local args = { ... }

	local finalArr = {}

	for _, v in ipairs(args) do
		for i = 1, #v do
			table.insert(finalArr, v[i])
		end
	end

	return finalArr
end

---@param arr any[]
---@param value any
---@return integer
function arrIndexOf(arr, value)
	for i, v in ipairs(arr) do
		if v == value then
			return i
		end
	end
	return -1
end

---@param arr any[]
---@param f fun(a: any): boolean
---@return any?
function arrFindFirst(arr, f)
	for i = 1, #arr do
		if f(arr[i]) then
			return arr[i]
		end
	end

	return nil
end

---@param arr any[]
---@param f fun(a: any): boolean
---@return integer
function arrFindFirstIndex(arr, f)
	for i = 1, #arr do
		if f(arr[i]) then
			return i
		end
	end

	return -1
end

---@param arr any[]
---@param f function
function arrForEach(arr, f)
	for i = 1, #arr do
		f(arr[i])
	end
end

---@param arr any[]
---@param initial any?
---@param f function
function arrReduce(arr, initial, f)
	local ret = initial
	for i = 1, #arr do
		ret = f(ret, arr[i])
	end
	return ret
end

---@param arr any[]
---@param f fun(a: any): boolean
---@return boolean
function arrSome(arr, f)
	for i = 1, #arr do
		if f(arr[i]) then
			return true
		end
	end

	return false
end

--path
---@param str string
---@param sep string?
function getPath(str, sep)
	sep = sep or '/'
	return str:match('(.*' .. sep .. ')')
end
