# B42 capacity: weight, not slots

The single most important thing to understand before configuring the mod.

## What changed in Build 42

In **B41**, `ContainerCapacity` was a **slot count**: the Cell Fridge of the B41
mod ("Methyl's Furniture (Expanded capacity)", Workshop `2814253005`) held 1000
items.

In **B42**, the capacity of a container became a **weight limit in kilograms**.
The engine computes:

- `ItemContainer.getCapacity()` returns `Math.min(capacity, 100)` for an object
  placed in the world. So **100 kg is the hard ceiling**, whatever value is
  configured.
- `getEffectiveCapacity(char)` multiplies that by **1.3** for a character with the
  **ORGANIZED** trait (130 kg effective), by **0.7** with **DISORGANIZED** (70 kg)
  and leaves it alone with neither.
- `hasRoomFor()` compares the **weight** of the contents against that capacity.

That is why the options go from 10 to 100 and not to 1000: **asking for more than
100 does nothing**, the engine silently clips it. Setting 100 asks for the real
maximum.

## In numbers

With a tin of beans weighing **0.8 kg**:

| | Capacity | Tins of beans |
|---|---|---|
| B41 Cell Fridge | 1000 slots | ~1000 |
| B42 Cell Fridge, no ORGANIZED | 100 kg | ~125 |
| B42 Cell Fridge, with ORGANIZED | 130 kg | ~162 |
| Vanilla shop fridge (B42) | 50 kg + 20 kg freezer | ~62 + ~25 |

So the mod **doubles** the fridge (50 → 100 kg) and **quintuples** the freezer
(20 → 100 kg). With the **ORGANIZED** trait the fridge reaches 130 kg.

## Can 1000 be reached at all?

No, not with the classic B42 containers: there is no way for an object placed in
the world to hold more than 100 kg. The only higher limit in the engine (1000)
belongs to **vehicle containers** (`VehiclePart`), which do not apply to a
standing fridge.

The other route would be the ECS `Resources` component, which counts **stacks**
instead of weight and would allow 1000, but B42 ships **no player interface for a
`Resources` group outside the crafting benches**. Using it would mean writing a
custom UI panel and losing the whole fridge semantics (temperature, freezer
compartment, food shelf life). This mod uses the native route so the cooler
behaves **exactly** like a fridge: it cools, it has a freezer, and the food
inside still goes bad and keeps.

## How it works

- The entity is declared in `mods/CellFridge/42/media/scripts/CellFridge.txt`
  with the four faces using the base tiles `appliances_refrigeration_01_16/17/18/19`
  (glass and light) and `_44/45/46/47` (metal lattice) for the N and W faces.
- The engine creates **one container per cell**: the two cell unit has two fridge
  compartments and two freezer compartments, and each door opens its own one.
  That is the same behaviour the shop fridge has when the map places it.
- `mods/CellFridge/42/media/lua/shared/CellFridgeCode.lua` hooks the `OnCreate`
  of the entity and applies the configured capacity when the cooler is built.

## Multiplayer synchronisation

The **server** is the authority: it writes the capacity into the `ItemContainer`
when the cooler is built, and that capacity travels with the object because
`IsoObject.save()` persists it (`ItemContainer.save()` writes the `int` of
`capacity`) and the client receives it when it creates the object from the
buffer. The client then shows exactly the same capacity as the server, and the
weight check the client does (`ISInventoryTransferAction.lua:889`) uses the same
value.

The fridges **already placed** in the world (the shop ones) are **not touched**:
they keep the vanilla capacity of 50 kg + 20 kg freezer. The mod only affects
the ones you build. Fridges built earlier with the mod are refreshed by the
server when the option changes (`CellFridgeCode.refreshExistingFridges`).
