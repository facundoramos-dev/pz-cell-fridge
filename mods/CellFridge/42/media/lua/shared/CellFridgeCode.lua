-- Cell Fridge (B42)
--
-- Adds a craftable "Cell Fridge": the two-door glass showcase cooler that
-- appears in shops (base-game tiles appliances_refrigeration_01_16..19 and
-- _44..47). No new textures are needed; the vanilla sprite sheet is reused.
--
-- The fridge is built as a 2-cell entity, so each of the two cells becomes its
-- own IsoThumpable with its own "fridge" container plus a secondary "freezer"
-- container. That mirrors how the same object behaves when the map places it
-- in the world.
--
-- B42 capacity note: ItemContainer.capacity is a WEIGHT limit in kg (not a slot
-- count), and the engine clamps a world object container to
-- Math.min(capacity, 100). getEffectiveCapacity() then multiplies by 1.3 for a
-- character with the ORGANIZED trait (0.7 with DISORGANIZED). The sandbox
-- options below are therefore expressed in kilograms and capped at the 100 kg
-- the engine actually allows.

CellFridgeCode = CellFridgeCode or {}

-- Maximum capacity the B42 engine honours for a world object container.
-- ItemContainer.getCapacity() returns Math.min(capacity, 100) for a container
-- whose parent is not a vehicle part and that is not inside an InventoryItem.
local CELL_FRIDGE_MAX_CAPACITY = 100

-- Reads a sandbox option, falling back to a default when the mod's option
-- namespace is missing (e.g. a client that has not received the options yet).
local function getOption(name, default)
    local vars = SandboxVars and SandboxVars.CellFridge
    if not vars then return default end
    local value = vars[name]
    if value == nil then return default end
    return value
end

local function clampCapacity(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback end
    if value < 1 then return 1 end
    if value > CELL_FRIDGE_MAX_CAPACITY then return CELL_FRIDGE_MAX_CAPACITY end
    return math.floor(value)
end

local function getCapacities()
    return clampCapacity(getOption("Capacity", CELL_FRIDGE_MAX_CAPACITY), CELL_FRIDGE_MAX_CAPACITY),
           clampCapacity(getOption("FreezerCapacity", CELL_FRIDGE_MAX_CAPACITY), CELL_FRIDGE_MAX_CAPACITY)
end

-- Called from the entity's OnCreate hook, once per cell of the 2-cell build.
-- params.thumpable is the IsoThumpable of the cell that was just created; by
-- the time this runs, IsoObject.addToWorld() has already created the
-- containers from the sprite properties (fridge + freezer).
--
-- The server is the authority here: the capacity it writes is serialised by
-- IsoObject.save() and reaches the clients with the object, so both sides end
-- up with the same value.
function CellFridgeCode.onCreate(params)
    local thumpable = params and params.thumpable
    if not thumpable then return end

    local capacity, freezerCapacity = getCapacities()

    local container = thumpable:getContainer()
    if container then
        container:setCapacity(capacity)
    end

    local freezer = thumpable:getContainerByType("freezer")
    if freezer then
        freezer:setCapacity(freezerCapacity)
    end
end

-- Re-apply the configured capacity to the fridges that already exist in the
-- world, so that changing the sandbox option also affects fridges built
-- earlier instead of leaving them at their old capacity.
--
-- Server-side only: the server owns the container contents, and the change is
-- pushed to the clients with IsoObjectChange.CONTAINERS.
function CellFridgeCode.refreshExistingFridges()
    if not isServer() then return end

    local cell = getCell()
    if not cell then return end

    local capacity, freezerCapacity = getCapacities()
    local changed = false

    for x = cell:getMinX(), cell:getMaxX() do
        for y = cell:getMinY(), cell:getMaxY() do
            for z = 0, 8 do
                local square = cell:getGridSquare(x, y, z)
                if square then
                    local objects = square:getObjects()
                    for i = 0, objects:size() - 1 do
                        local object = objects:get(i)
                        if object and object.getContainerByType then
                            local container = object:getContainer()
                            if container and container:getType() == "fridge" then
                                if container:getCapacity() ~= capacity then
                                    container:setCapacity(capacity)
                                    changed = true
                                end
                                local freezer = object:getContainerByType("freezer")
                                if freezer and freezer:getCapacity() ~= freezerCapacity then
                                    freezer:setCapacity(freezerCapacity)
                                    changed = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return changed
end
