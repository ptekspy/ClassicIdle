# Color

Roblox `Color3` helpers used by design-system packages.

- `Alpha(color, alpha)` returns `{ Color, Transparency }`.
- `Lighten(color, amount)` and `Darken(color, amount)` return adjusted colors.
- `GetLuminance(color)` returns WCAG relative luminance.
- `GetContrastRatio(first, second)` returns the WCAG contrast ratio.
