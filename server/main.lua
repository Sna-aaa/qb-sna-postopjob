local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-postopjob:server:attemptPurchase', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    local balance = nil
    balance = exports['qb-bossmenu']:GetAccount(Player.PlayerData.job.name)
    if balance >= amount then
        TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, amount)
        TriggerClientEvent('qb-postopjob:client:purchaseSuccessful', source)
    else
        TriggerClientEvent('qb-postopjob:client:purchaseFailed', source)
    end
end)

QBCore.Functions.CreateCallback('qb-postopjob:server:checkTrunkEmpty', function(source, cb, plate)
    local empty = true
    local resulttrunk = exports.oxmysql:scalarSync('SELECT items FROM trunkitems WHERE plate = ?', {plate})
    if resulttrunk then
        local trunkItems = json.decode(resulttrunk)
        for k = 1, #trunkItems do
            if trunkItems[k].amount ~= 0 then
                empty = false
            end
        end
    end
    cb(empty)
end)
