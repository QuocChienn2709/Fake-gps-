-- =============================================
-- GPS FAKER - THAY THẾ TỌA ĐỘ TRONG REQUEST/RESPONSE
-- HÀM XỬ LÝ JSON VÀ XML CƠ BẢN
-- TỌA ĐỘ MẶC ĐỊNH: 21.0285, 105.8542 (HÀ NỘI)
-- =============================================

local M = {}

-- Cấu hình tọa độ giả (có thể thay đổi)
local FAKE_LAT = 21.0285
local FAKE_LNG = 105.8542

-- Hàm thay thế trong chuỗi JSON
local function replace_json_coords(body)
    -- Xử lý key "latitude", "lat"
    body = string.gsub(body, '(["lat"]%s*:%s*)%d+%.%d+', '%1' .. tostring(FAKE_LAT))
    body = string.gsub(body, '(["latitude"]%s*:%s*)%d+%.%d+', '%1' .. tostring(FAKE_LAT))
    -- Xử lý key "longitude", "lng", "lon"
    body = string.gsub(body, '(["lng"]%s*:%s*)%d+%.%d+', '%1' .. tostring(FAKE_LNG))
    body = string.gsub(body, '(["longitude"]%s*:%s*)%d+%.%d+', '%1' .. tostring(FAKE_LNG))
    body = string.gsub(body, '(["lon"]%s*:%s*)%d+%.%d+', '%1' .. tostring(FAKE_LNG))
    -- Xử lý mảng tọa độ dạng [lng, lat] hoặc [lat, lng]
    -- Dạng [21.0, 105.0] -> thay thế số đầu tiên và thứ hai nếu nằm trong ngoặc vuông
    body = string.gsub(body, '(%[%s*)%d+%.%d+(%s*,%s*)%d+%.%d+(%s*%])', '%1' .. tostring(FAKE_LAT) .. '%2' .. tostring(FAKE_LNG) .. '%3')
    return body
end

-- Hàm thay thế trong chuỗi XML (áp dụng cho SOAP hoặc GPX)
local function replace_xml_coords(body)
    -- Thẻ <lat>...</lat>
    body = string.gsub(body, '(<lat>%s*)%d+%.%d+(%s*</lat>)', '%1' .. tostring(FAKE_LAT) .. '%2')
    body = string.gsub(body, '(<latitude>%s*)%d+%.%d+(%s*</latitude>)', '%1' .. tostring(FAKE_LAT) .. '%2')
    -- Thẻ <lon>...</lon>
    body = string.gsub(body, '(<lon>%s*)%d+%.%d+(%s*</lon>)', '%1' .. tostring(FAKE_LNG) .. '%2')
    body = string.gsub(body, '(<longitude>%s*)%d+%.%d+(%s*</longitude>)', '%1' .. tostring(FAKE_LNG) .. '%2')
    -- Thuộc tính lat="..." lon="..."
    body = string.gsub(body, '(lat%s*=%s*")%d+%.%d+(")', '%1' .. tostring(FAKE_LAT) .. '%2')
    body = string.gsub(body, '(lon%s*=%s*")%d+%.%d+(")', '%1' .. tostring(FAKE_LNG) .. '%2')
    return body
end

-- Xử lý request (sửa body request nếu cần)
function M.process_request(req)
    if req.body and #req.body > 0 then
        local content_type = req.headers['Content-Type'] or ''
        if string.find(content_type, 'json') then
            req.body = replace_json_coords(req.body)
        elseif string.find(content_type, 'xml') then
            req.body = replace_xml_coords(req.body)
        end
    end
    return req
end

-- Xử lý response (sửa body response)
function M.process_response(res)
    if res.body and #res.body > 0 then
        local content_type = res.headers['Content-Type'] or ''
        if string.find(content_type, 'json') then
            res.body = replace_json_coords(res.body)
        elseif string.find(content_type, 'xml') then
            res.body = replace_xml_coords(res.body)
        end
    end
    return res
end

-- Shadowrocket gọi các hàm này
function requestHandler(req)
    return M.process_request(req)
end

function responseHandler(res)
    return M.process_response(res)
end