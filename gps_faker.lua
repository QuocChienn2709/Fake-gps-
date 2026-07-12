local fake_lat = 21.0285
local fake_lng = 105.8542

local function replace_json(body)
    body = string.gsub(body, '(["lat"]%s*:%s*)%d+%.%d+', '%1' .. tostring(fake_lat))
    body = string.gsub(body, '(["latitude"]%s*:%s*)%d+%.%d+', '%1' .. tostring(fake_lat))
    body = string.gsub(body, '(["lng"]%s*:%s*)%d+%.%d+', '%1' .. tostring(fake_lng))
    body = string.gsub(body, '(["longitude"]%s*:%s*)%d+%.%d+', '%1' .. tostring(fake_lng))
    body = string.gsub(body, '(["lon"]%s*:%s*)%d+%.%d+', '%1' .. tostring(fake_lng))
    body = string.gsub(body, '(%[%s*)%d+%.%d+(%s*,%s*)%d+%.%d+(%s*%])', '%1' .. tostring(fake_lng) .. '%2' .. tostring(fake_lat) .. '%3')
    return body
end

local function replace_xml(body)
    body = string.gsub(body, '(<lat>%s*)%d+%.%d+(%s*</lat>)', '%1' .. tostring(fake_lat) .. '%2')
    body = string.gsub(body, '(<latitude>%s*)%d+%.%d+(%s*</latitude>)', '%1' .. tostring(fake_lat) .. '%2')
    body = string.gsub(body, '(<lon>%s*)%d+%.%d+(%s*</lon>)', '%1' .. tostring(fake_lng) .. '%2')
    body = string.gsub(body, '(<longitude>%s*)%d+%.%d+(%s*</longitude>)', '%1' .. tostring(fake_lng) .. '%2')
    body = string.gsub(body, '(lat%s*=%s*")%d+%.%d+(")', '%1' .. tostring(fake_lat) .. '%2')
    body = string.gsub(body, '(lon%s*=%s*")%d+%.%d+(")', '%1' .. tostring(fake_lng) .. '%2')
    return body
end

function requestHandler(req)
    if req.body and #req.body > 0 then
        local ct = req.headers['Content-Type'] or ''
        if string.find(ct, 'json') then
            req.body = replace_json(req.body)
        elseif string.find(ct, 'xml') then
            req.body = replace_xml(req.body)
        end
    end
    return req
end

function responseHandler(res)
    if res.body and #res.body > 0 then
        local ct = res.headers['Content-Type'] or ''
        if string.find(ct, 'json') then
            res.body = replace_json(res.body)
        elseif string.find(ct, 'xml') then
            res.body = replace_xml(res.body)
        end
    end
    return res
end
