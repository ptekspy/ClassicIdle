# Right Action Rail

## Goal

Implement the exact two-column tile order.

## Create `ActionRail.luau`

Props:

```luau
export type Props = { onBuild: () -> () }
```

Create a two-column `UIGridLayout`. Insert tiles in this exact order:

| Order | Label | Icon | Badge | Callback |
|---:|---|---|---|---|
| 1 | Shop | Shop | `!` | nil |
| 2 | Build | Build | `!` | `props.onBuild` |
| 3 | Rocket | Rocket | `!` | nil |
| 4 | Pets | Pets | `2` | nil |
| 5 | Worlds | Worlds | none | nil |
| 6 | Rebirth | Rebirth | `!` | nil |
| 7 | Codes | Codes | none | nil |
| 8 | Settings | Settings | none | nil |

Every child is `ActionTile`; do not create special tile components.

## Behavior

- Build is the only selectable/active tile.
- Build calls the existing `factory.onToggleShop`.
- Disabled tiles retain full reference color and artwork.
- Disabled tiles have no activation callback and are not gamepad-selectable.

## Responsive behavior

- Desktop/tablet: preserve two columns.
- Landscape phone: show Build only.
- Portrait phone: show Build as a single floating tile above the hotbar.

## Validation

- Grid order matches the table exactly.
- Build opens and closes the existing factory shop.
- All seven placeholder tiles do nothing.

## Done when

The rail has one reusable tile implementation and exactly one functional action.
