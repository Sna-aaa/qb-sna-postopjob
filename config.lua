Conf = {}
Conf.DeliveryTime = 2       --In minutes
Conf.Locations = {
    ["stash"] = vector3(-416.98, -2789.81, 6.0),         
    ["duty"] = vector3(-424.33, -2789.82, 6.53),        
    ["computer"] = vector3(-426.13, -2787.41, 6.0),
    ["delivery"] = vector3(-432.83, -2765.45, 6.0)
}

Conf.Products = {
    ["food"] = {
        [1] = {
            name = "tosti",
            price = 2,
            max = 500,
        },
        [2] = {
            name = "water_bottle",
            price = 2,
            max = 500,
        },
    },
    ["leisure"] = {
        [1] = {
            name = "parachute",
            price = 2,
            max = 50,
        },
        [2] = {
            name = "diving_gear",
            price = 2,
            max = 50,
        },
    },
    ["hardware"] = {
        [1] = {
            name = "phone",
            price = 2,
            max = 500,
        },
        [2] = {
            name = "repairkit",
            price = 2,
            max = 500,
        },
    },
}



