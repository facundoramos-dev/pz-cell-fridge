# Cell Fridge

A Project Zomboid (Build 42) mod that adds a craftable **Cell Fridge**: the two
door glass display cooler you see in shops, with an **expandable capacity** set
from the World Options.

The mod reuses the vanilla `appliances_refrigeration_01` tiles, so it ships no
textures at all. It is the Build 42 equivalent of the B41 mod *"Methyl's Furniture
(Expanded capacity)"* (Workshop `2814253005`), whose Cell Fridge held 1000 items.

- Workshop: <https://steamcommunity.com/sharedfiles/filedetails/?id=3823803784>
- Mod id: `CellFridge` (the value that goes in a server `Mods=` list)
- Requires Build 42 or newer. No other mods needed.

## What it adds

- **Cell Fridge**: a craftable entity in the **Furniture** category, two cells
  wide, the same size as the shop cooler. It has a **fridge** compartment and a
  **freezer** compartment, both with a configurable capacity.
- Crafted with 8 sheets of metal, 4 electric wire, 2 electronics scrap, 4 screws
  and a hammer. Requires **MetalWelding 3**.

Two new entries appear in the World Options, on a **Cell Fridge** page:

| Option | Range | Default | What it does |
|---|---|---|---|
| `Capacity` | 10 – 100 | 100 | Capacity (kg) of the fridge compartment |
| `FreezerCapacity` | 5 – 100 | 100 | Capacity (kg) of the freezer compartment |

> **In Build 42 the capacity is a weight in kilograms, and 100 kg is the hard
> ceiling** the engine allows for a placed container. The shop fridge holds
> 50 kg + 20 kg, so this mod doubles the fridge and quintuples the freezer (or
> 130 + 130 with the ORGANIZED trait). The full explanation, with numbers, is in
> [`docs/b42-capacity.md`](docs/b42-capacity.md).

## Layout

```
mods/CellFridge/42/          the mod published to the Workshop
docs/b42-capacity.md         why the capacity is weight, and what the limits are
workshop/listing.json        listing data: title, descriptions per language
workshop/preview.png         cover image, 256x256
workshop/gallery/            carousel images, 1280x720
```

The listing images and the upload itself are handled by
[pz-mod-toolbox](https://github.com/facundoramos-dev/pz-mod-toolbox).

## License

GPL-3.0, see [`LICENSE`](LICENSE).
