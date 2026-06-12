# Zone Progress Bar

## Goal

Implement the exact centered Earth-to-Moon progress bar.

## Create `ZoneProgressBar.luau`

Compose:

```txt
Earth icon | EARTH ZONE | 20-segment progress bar | MOON ZONE | Moon icon
```

Use `HUD.Demo.ZoneProgress` and pass `segmented = 20` to `ProgressBar` with the `Zone` variant. Place `68% COMPLETE` centered beneath the filled segments.

Required props:

```luau
export type Props = { visible: boolean }
```

The component is display-only and receives no callbacks.

## Styling

- Wrap the entire region in `Panel("Status")`.
- Use `Icon("Large")` for Earth and Moon.
- Use `Text("Label")` for zone names.
- Filled segments use the approved green-to-yellow progress gradient.
- Empty segments use `Colors.Progress.Track`.
- Preserve a dark border between every segment.

## Validation

- Exactly 14 of 20 segments appear filled for the configured 68%.
- Text reads `68% COMPLETE`.
- Earth is left and Moon is right.

## Done when

The region matches the reference directly beneath the top bar.
