local utils = {}

function utils.extract_sinks_and_sources(pacmd_output)
    local sinks = {}
    local sources = {}

    for line in pacmd_output:gmatch("[^\r\n]+") do
        if string.find(line, 'output') ~= nil then
            table.insert(sinks, line)
        end
        if string.match(line, 'input') ~= nil then
            table.insert(sources, line)
        end
    end

    return sinks, sources
end

return utils
