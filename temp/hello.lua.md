function main(  )
    local function run(x, y)
        ngx.say('run', x, y)
    end
    
    local function attack(targetId)
        ngx.say('targetId', targetId)
    end
    
    local function doAction(method, ...)
        local args = {...} or {}
        method(unpack(args, 1, table.maxn(args)))
    end
    
    doAction(run, 1, 2)
    doAction(attack, 1111)
end

main()