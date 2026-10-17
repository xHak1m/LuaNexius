local cjson = require("cjson")

local function library(title, fields)
	return
	{
		form = {
			title = title,
			fields = fields
		}
	}
end

local function textbox(name, label, required, initial)
	return
	{
		type = "text",
		name = name,
		label = label,
		required = required,
		initial = initial
	}
end

local function number(name, label, required, initial)
	return
	{
		type = "numeric",
		name = name,
		label = label,
		required = required,
		initial = initial
	}
end

local function dropdown(name, label, required, initial)
	return
	{
		type = "choice",
		name = name,
		label = label,
		required = required,
		options = initial
	}
end

local function checkbox(name, label, initial)
	return
	{
		type = "checkbox",
		name = name,
		label = label,
		initial = initial
	}
end

local function divider()
	return
	{
		type = "divider"
	}
end

local function build(menu)
	local main = app.jsonForm(cjson.encode(menu))
	if (not main or (main == "")) then
		return nil
	end
	local result = cjson.decode(main)
	for _, field in ipairs(menu.form.fields) do
		if field.type == "numeric" then
			local value = tonumber(result[field.name]) or 0
			if value % 1 == 0 then
				result[field.name] = math.tointeger and math.tointeger(value) or value
			else
				result[field.name] = value
			end
		end
	end
	return result
end

function scan(api)
	local server = {url=api}
	local statuscode, content = app.httprequest(server)
	if statuscode == 200 then
		local data = cjson.decode(content)
		print("IP Address:", data.ip)
		print("Network:", data.network)
		print("Version:", data.version)
		print("City:", data.city)
		print("Region:", data.region)
		print("Region Code:", data.region_code)
		print("Country:", data.country)
		print("Country Name:", data.country_name)
		print("Country Code:", data.country_code)
		print("Country Code ISO3:", data.country_code_iso3)
		print("Country Capital:", data.country_capital)
		print("Country TLD:", data.country_tld)
		print("Continent Code:", data.continent_code)
		print("Postal:", data.postal)
		print("Latitude:", data.latitude)
		print("Longitude:", data.longitude)
		print("Timezone:", data.timezone)
		print("UTC Offset:", data.utc_offset)
		print("Country Calling Code:", data.country_calling_code)
		print("Currency:", data.currency)
		print("Currency Name:", data.currency_name)
		print("Languages:", data.languages)
		print("Country Area:", data.country_area)
		print("Country Population:", data.country_population)
		print("ASN:", data.asn)
		print("ORG:", data.org)
	else
		app.toast("Request failed.\nPlease enable your network!")
	end
end

LuaNexius = build(library("LuaNexius", {
	dropdown("scanType", "Choose Scan Type:", true, "Custom Scan|Random Scan|Scan My Network"),
}))

if not LuaNexius then
	app.toast("User has cancelled the session.")
	return
end

if LuaNexius.scanType == "Custom Scan" then
	LuaNexiusCustomScan = build(library("LuaNexius", {
		textbox("ip", "Enter IP Address:", true, ""),
	}))
	if not LuaNexiusCustomScan then
		app.toast("User has cancelled the session.")
		return
	end
	scan("https://ipapi.co/" .. LuaNexiusCustomScan.ip .. "/json/")
elseif LuaNexius.scanType == "Random Scan" then
	scan("https://ipapi.co/" .. string.format("%d.%d.%d.%d", math.random(180, 199), math.random(1, 255), math.random(1, 255), math.random(1, 255)) .. "/json/")
elseif LuaNexius.scanType == "Scan My Network" then
	scan("https://ipapi.co/json/")
end
