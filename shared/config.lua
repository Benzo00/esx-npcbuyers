Config = {}

Config.ox_target = false -- Set to false if you don't want to use qtarget

Config.peds = {
  {
    Name = "Shady Mcgrady",
    location = vector4(-1166.452759, -1584.909912, 3.4, 31.181103),
    SpawnName = "a_f_m_beach_01",
    description = "Sits Alone and Listens to Pumped Up Kicks, but, gives decent rates.",
    TimeRandomOpen = math.random(1, 10),
    TimeRandomClose = math.random(10, 23),
    OpenTime = 1, -- dont change this
    CloseTime = 4, -- dont change this
    item = {
      name = "bread",
      price = math.random(20, 40),
      MaxSell = 10, -- Max amount of items you can sell at once
      MinSell = 1, -- Min amount of items you can sell at once
    }
  }
}

--- Dont touch Bellow this line

function PickTimes()
  for i = 1, #Config.peds do
    Config.peds[i].OpenTime = Config.peds[i].TimeRandomOpen
    Config.peds[i].CloseTime =  Config.peds[i].TimeRandomClose
  end
end

CreateThread(function()
  PickTimes()
end)
