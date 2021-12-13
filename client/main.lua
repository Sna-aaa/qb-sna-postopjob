local QBCore = exports['qb-core']:GetCoreObject()

local menu  = MenuV:CreateMenu(false, 'Menu Principal', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
local menu1 = MenuV:CreateMenu(false, 'Menu Commande', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
--local menu2 = MenuV:CreateMenu(false, 'Menu Stocks', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
local menu3 = MenuV:CreateMenu(false, 'Nourriture', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
local menu4 = MenuV:CreateMenu(false, 'Amusement', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
local menu5 = MenuV:CreateMenu(false, 'Hardware', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')


local PlayerJob = {}
local DeliveriesList = {}

local onDuty = false


    --Menu principal
local menu_button = menu:AddButton({
    icon = '😃',
    label = 'Commande',
    value = menu1,
    description = "Commander des biens a l'etranger"
})
local menu_button1 = menu:AddButton({
    icon = '😃',
    label = 'Stocks',
    value = nil,
    description = "Visualiser les stocks magasins"
})
menu_button1:On('select', function(item)
    TriggerEvent('qb-postopjob:client:openStocksMenu')
end)
    --Menu Commande
local menu_button2 = menu1:AddButton({
    icon = '😃',
    label = 'Nourriture',
    value = menu3,
    description = "Commander de la nourriture/boisson"
})
local menu_button3 = menu1:AddButton({
    icon = '😃',
    label = 'Amusement',
    value = menu4,
    description = "Commander des amusements"
})
local menu_button4 = menu1:AddButton({
    icon = '😃',
    label = 'Hardware',
    value = menu5,
    description = "Commander du matériel"
})

local MenuList = {}
local OrderList = {}

    --Menu Nourriture
local FoodMenu = {}
local order_food_button = menu3:AddButton({
    label = 'Commander',
    value = nil,
    description = 'Commander la selection'
})
order_food_button:On('select', function(item)
    TriggerEvent('qb-postopjob:client:Order', MenuList, "food")
end)
for list, _ in pairs(Conf.Products) do
    if list == "food" then
        for _, item in pairs(Conf.Products[list]) do
            local i = #FoodMenu+1
            local val = item.max / 5
            FoodMenu[i] = menu3:AddSlider({ label = QBCore.Shared.Items[item.name]["label"], value = 0, values = {
                { label = '0', value = 0, description = '' },
                { label = val, value = val, description = '' },
                { label = val*2, value = val*2, description = '' },
                { label = val*3, value = val*3, description = '' },
                { label = val*4, value = val*4, description = '' },
                { label = val*5, value = val*5, description = '' }
            }})
            FoodMenu[i]:On('select', function(item, value) 
                MenuList[i] = value
                QBCore.Functions.Notify("Objet ajouté a la commande")
            end)
        end
    end 
end

    --Gestion commande et payement
RegisterNetEvent('qb-postopjob:client:Order', function(items, list)
    --Get items and quantities + total
    local total = 0
    for item, _ in pairs(items) do
        if items[item] then
            total = total + (Conf.Products[list][item].price * items[item])
            OrderList[#OrderList+1] = { 
                name = Conf.Products[list][item].name,
                amount = items[item],
                info = {},
                type = "item",
                slot = #OrderList+1}
        end
    end
    --Check payment
    TriggerServerEvent('qb-postopjob:server:attemptPurchase', total)
end)

RegisterNetEvent("qb-postopjob:client:purchaseSuccessful", function()
    --Delivery timer
    QBCore.Functions.Notify("Achat effectué, livraison dans "..Conf.DeliveryTime.." minutes au port")
    Wait(1000 * 60 * ( Conf.DeliveryTime - 1 ))
    QBCore.Functions.Notify("Livraison dans 1 minute")
    Wait(1000 * 60 * 1)
    DeliveriesList[#DeliveriesList+1] = OrderList
    MenuList = {}
    OrderList = {}
    QBCore.Functions.Notify("Votre commande vous attend au port")
end)

RegisterNetEvent("qb-postopjob:client:purchaseFailed", function()
    QBCore.Functions.Notify("Pas assez d'argent", "error")
end)
    --Ouverture menu principal
RegisterNetEvent('qb-postopjob:client:openComputerMenu', function()
    MenuV:OpenMenu(menu)
end)

    --Ouverture menu livraison
RegisterNetEvent('qb-postopjob:client:openDeliveryMenu', function()
    local menu10 = MenuV:CreateMenu(false, 'Menu Livraison', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
    --Menu Livraison
    local DeliveryMenu = {}
    local Todeliver = false
    for order, _ in pairs(DeliveriesList) do
        for item, _ in pairs(DeliveriesList[order]) do
            if DeliveriesList[order][item].amount > 0 then
                Todeliver = true
            end
        end
        if Todeliver then
            local i = #DeliveryMenu+1
            DeliveryMenu[i] = menu10:AddButton({
                label = 'Commande',
                value = nil,
                description = 'Livrer la commande selectionnée'
            })
            DeliveryMenu[i]:On('select', function(item)
                TriggerEvent('qb-postopjob:client:Deliver', order, menu10)
                MenuV:CloseMenu(menu10)
            end)
            
        end
    end
    MenuV:OpenMenu(menu10)
end)

    --Gestion livraison
RegisterNetEvent('qb-postopjob:client:Deliver', function(order)
    local todeliver = {}
    --Find vehicle near marker
    local vehicle = QBCore.Functions.GetClosestVehicle()
    --Check car is owned
    QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
        if owned then
            --Check if trunk is empty
            QBCore.Functions.TriggerCallback('qb-postopjob:server:checkTrunkEmpty', function(empty)
                if empty then
                    --Get trunk space
                    local vehicleClass = GetVehicleClass(vehicle)
                    local maxweight = 0
                    local partial = true
                    if vehicleClass == 0 then
                        maxweight = 38000
                    elseif vehicleClass == 1 then
                        maxweight = 50000
                    elseif vehicleClass == 2 then
                        maxweight = 75000
                    elseif vehicleClass == 3 then
                        maxweight = 42000
                    elseif vehicleClass == 4 then
                        maxweight = 38000
                    elseif vehicleClass == 5 then
                        maxweight = 30000
                    elseif vehicleClass == 6 then
                        maxweight = 30000
                    elseif vehicleClass == 7 then
                        maxweight = 30000
                    elseif vehicleClass == 8 then
                        maxweight = 15000
                    elseif vehicleClass == 9 then
                        maxweight = 60000
                    elseif vehicleClass == 12 then
                        maxweight = 120000
                    elseif vehicleClass == 13 then
                        maxweight = 0
                    elseif vehicleClass == 14 then
                        maxweight = 120000
                    elseif vehicleClass == 15 then
                        maxweight = 120000
                    elseif vehicleClass == 16 then
                        maxweight = 120000
                    else
                        maxweight = 60000
                    end
                    for item, _ in pairs(DeliveriesList[order]) do
                        --Fill trunk by weight and Update delivery
                        if DeliveriesList[order][item].amount ~= 0 then
                            local itemdb = QBCore.Shared.Items[DeliveriesList[order][item].name]
                            local i = #todeliver+1
                            if (itemdb.weight * DeliveriesList[order][item].amount) <= maxweight then
                                todeliver[i] = { 
                                    name = DeliveriesList[order][item].name,
                                    amount = DeliveriesList[order][item].amount,
                                    info = {},
                                    type = "item",
                                    slot = i}
                                DeliveriesList[order][item].amount = 0
                                partial = false
                            else
                                todeliver[i] = { 
                                    name = DeliveriesList[order][item].name,
                                    amount = maxweight // itemdb.weight,
                                    info = {},
                                    type = "item",
                                    slot = i}
                                DeliveriesList[order][item].amount = DeliveriesList[order][item].amount - todeliver[i].amount
                                if DeliveriesList[order][item].amount ~=0 then
                                    partial = true
                                else
                                    partial = false
                                end
                            end
                            maxweight = maxweight - itemdb.weight * todeliver[i].amount
                        end
                    end
                    --Fill trunk with items 
                    TriggerServerEvent("inventory:server:addTrunkItems", QBCore.Functions.GetPlate(vehicle), todeliver)
                    if partial then
                        QBCore.Functions.Notify("Coffre chargé, revenez pour le reste")
                    else
                        QBCore.Functions.Notify("Livraison effectuée, commande close")
                    end
                else
                    QBCore.Functions.Notify("Le coffre doit etre vide", "error")
                end
            end, QBCore.Functions.GetPlate(vehicle))
        else
            QBCore.Functions.Notify("Le véhicule ne peut etre volé", "error")
        end
    end, QBCore.Functions.GetPlate(vehicle))
end)

    --Ouverture menu stocks
RegisterNetEvent('qb-postopjob:client:openStocksMenu', function()
    local menu2 = MenuV:CreateMenu(false, 'Menu Stocks', 'topleft', 155, 0, 0, 'size-125', 'none', 'menuv')
    --Menu Stocks
    local StockMenu = {}
    QBCore.Functions.TriggerCallback('qb-sna-shops:server:getGlobalStock', function(stocks)
        if stocks[1] then
            for stock, _ in pairs(stocks) do
                StockMenu[#StockMenu+1] = menu2:AddSlider({ label = QBCore.Shared.Items[stocks[stock].item]["label"], value = 0, values = {
                    { label = stocks[stock].amount, value = 0, description = QBCore.Shared.Items[stocks[stock].item]["label"] }
                }})
            end
        end
    end)
    MenuV:OpenMenu(menu2)
end)

--Creation Markers and actions
local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

CreateThread(function()
    Wait(1000)
    while true do
        Wait(5)
        local inRange = false
        if PlayerJob.name == "postop" then
            local pos = GetEntityCoords(PlayerPedId())

            if onDuty then
                local StashDistance = #(pos - Conf.Locations["stash"])
                if StashDistance < 20 then
                    inRange = true
                    DrawMarker(2, Conf.Locations["stash"].x, Conf.Locations["stash"].y, Conf.Locations["stash"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                    if StashDistance < 1 then
                        DrawText3Ds(Conf.Locations["stash"].x, Conf.Locations["stash"].y, Conf.Locations["stash"].z, "[E] Ouvre l'inventaire")
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent("inventory:client:SetCurrentStash", "postopstash")
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", "postopstash", {
                                maxweight = 40000000,
                                slots = 500,
                            })
                        end
                    end
                end
                local ComputerDistance = #(pos - Conf.Locations["computer"])
                if ComputerDistance < 20 then
                    inRange = true
                    DrawMarker(2, Conf.Locations["computer"].x, Conf.Locations["computer"].y, Conf.Locations["computer"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                    if ComputerDistance < 1 then
                        DrawText3Ds(Conf.Locations["computer"].x, Conf.Locations["computer"].y, Conf.Locations["computer"].z, "[E] Ordinateur")
                        if IsControlJustReleased(0, 38) then
                            --Open computer menu
                            TriggerEvent('qb-postopjob:client:openComputerMenu')
                        end
                    end
                end
                local DeliveryDistance = #(pos - Conf.Locations["delivery"])
                if DeliveryDistance < 20 then
                    inRange = true
                    DrawMarker(2, Conf.Locations["delivery"].x, Conf.Locations["delivery"].y, Conf.Locations["delivery"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                    if DeliveryDistance < 1 then
                        DrawText3Ds(Conf.Locations["delivery"].x, Conf.Locations["delivery"].y, Conf.Locations["delivery"].z, "[E] Livraison")
                        if IsControlJustReleased(0, 38) then
                            --Open delivery menu
                            TriggerEvent('qb-postopjob:client:openDeliveryMenu')
                        end
                    end
                end
            end

            local OnDutyDistance = #(pos - Conf.Locations["duty"])
            if OnDutyDistance < 20 then
                inRange = true
                DrawMarker(2, Conf.Locations["duty"].x, Conf.Locations["duty"].y, Conf.Locations["duty"].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)

                if OnDutyDistance < 1 then
                    if onDuty then
                        DrawText3Ds(Conf.Locations["duty"].x, Conf.Locations["duty"].y, Conf.Locations["duty"].z, "[E] Off Duty")
                    else
                        DrawText3Ds(Conf.Locations["duty"].x, Conf.Locations["duty"].y, Conf.Locations["duty"].z, "[E] On Duty")
                    end
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent("QBCore:ToggleDuty")
                    end
                end
            end

        end
        if not inRange then
            Wait(1000)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        if PlayerData.job.onduty then
            if PlayerData.job.name == "postop" then
                TriggerServerEvent("QBCore:ToggleDuty")
            end
        end
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = PlayerJob.onduty
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)
