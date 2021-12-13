# qb-postopjob
PostOp Job for QB-Core Framework
The job allows to order things and receive items in docks
The docks can load the vehicle trunk to get back to the warehouse
40 tons warehouse is avaialble
Stocks of all stores can be verified from the warehouse to prepare delivery
Stores must be filled at the delivery point, the store fill itselfs his stocks depending of the trunk
Stores pay deliveries on the company account

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>


## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) - 
- [qb-sna-shops](https://github.com/Sna-aaa/qb-sna-shops) - 

## Screenshots
![Platform](https://imgur.com/KzmXIaY.png)
![Vehicle Spawner](https://imgur.com/bDYiFoG.png)
![Stash](https://imgur.com/8fvy9FA.png)
![On Duty/Off Duty](https://i.imgur.com/CM34EsL.png)

## Features
- 

## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure qb-core
ensure qb-inventory
ensure qb-sna-postopjob
```

## Configuration
```
Add this to shared.lua to add new job
	['postop'] = {
		label = 'PostOp',
		defaultDuty = true,
		grades = {
            ['0'] = {
                name = 'Recruit',
                payment = 50
            },
			['1'] = {
                name = 'Novice',
                payment = 75
            },
			['2'] = {
                name = 'Experienced',
                payment = 100
            },
			['3'] = {
                name = 'Advanced',
                payment = 125
            },
			['4'] = {
                name = 'Manager',
				isboss = true,
                payment = 150
            },
        },
	},


Config.Locations = {                                        Locations for all
    ["stash"] = vector3(-348.36, -169.72, 39.01),         
    ["duty"] = vector3(-329.23, -163.39, 44.59),        
    ["computer"] = vector3(-329.23, -163.39, 44.59),
    ["delivery"] = vector3(-329.23, -163.39, 44.59)
}

Config.Products = {                                         List of products to buy
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


## ToDo
```



