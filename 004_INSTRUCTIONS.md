I want to replace the current ProximityPrompt-based interaction UX with a custom device-compatible targeting interaction system.

Current behaviour:

* The game currently uses Roblox ProximityPrompt instances on interactable objects.
* Roblox shows the built-in ProximityPrompt UI.
* Triggering the prompt runs the interaction logic.
* Existing ProximityPrompts may still exist in Workspace while this task is being implemented.

Important migration note:

* The current ProximityPrompts are temporary and will be deleted from Workspace after this task is complete.
* You may inspect the current ProximityPrompts using Roblox MCP if helpful, especially to understand:

  * Which objects are interactable.
  * Existing prompt text/action labels.
  * Interaction ranges.
  * Any object-specific metadata.
* Do not rely on ProximityPrompt instances as the long-term source of truth.
* Any interaction labels, action text, range values, or UI hints currently coming from ProximityPrompt should be moved into suitable config, attributes, or replacement UI components.

Desired behaviour:

* Built-in ProximityPrompt UI should no longer be required.
* When an interactable is in scope and within range, it should receive a white outline using Highlight.
* A suitable custom UI prompt should appear for the focused interactable.
* The custom prompt can be implemented with BillboardGui, ScreenGui, or the existing UI framework, depending on what best matches the current repo.
* When the player activates the interaction, the existing interaction logic should fire.

Device compatibility:

* This system must support mouse, touch, and gamepad.

Mouse:

* Targeting should use the mouse cursor position.
* Raycast from the camera through the mouse position.
* Activation should support mouse click and/or the existing keyboard interact key.

Gamepad:

* Targeting should use the centre of the screen / crosshair.
* Raycast from the camera viewport centre.
* Activation should use a suitable gamepad button, preferably R2 if that matches the project’s input conventions.
* Gamepad targeting should be forgiving and should not require pixel-perfect aiming.

Touch:

* Targeting should use centre-screen / crosshair targeting, or the best nearby interactable in front of the player.
* Show a clear on-screen interact button when a valid target is available.
* Tapping the button should activate the focused target.
* Still show the white outline for consistency, even if touch players mainly use the button.

Targeting behaviour:

* Use one shared client-side targeting controller.
* The targeting controller should choose the correct targeting method based on the current input device.
* Only one interactable should be focused at a time.
* Only the focused interactable should receive the Highlight.
* Highlight should be white outline only.
* No fill colour.
* Highlight should disappear when the player looks away, moves away, or the target becomes invalid.
* For gamepad/touch, use forgiving targeting:

  * First try the centre-screen raycast.
  * If that misses, consider nearby interactables within range.
  * Prefer objects closest to the centre of the screen.
  * Prefer closer objects when scores are similar.

Custom prompt UI:

* Replace the old ProximityPrompt UI with a custom prompt display.
* Use BillboardGui or an existing project UI pattern if appropriate.
* The prompt should show the interaction label/action text where available.
* The prompt should be visible only for the currently focused interactable.
* The prompt should support different input devices:

  * Mouse/keyboard: show key or click hint.
  * Gamepad: show gamepad button hint.
  * Touch: show/use touch button UI.
* Keep the UI simple and consistent with the existing game style.

Architecture requirements:

* Client:

  * Create or update an InteractionController client module/script.
  * Detect active input mode using UserInputService or existing input utilities.
  * Perform targeting.
  * Manage Highlight.
  * Manage custom prompt visibility.
  * Fire a RemoteEvent when the focused target is activated.
* Server:

  * Create or update an InteractionService server module/script.
  * Receive interaction requests.
  * Validate the request.
  * Run the correct interaction handler.
* Shared:

  * Add shared config/types if useful.
  * Use CollectionService tags, attributes, or existing project config to identify interactable objects.

Security requirements:

* Do not trust the client.
* The server must verify:

  * The target exists.
  * The target is registered/tagged/configured as interactable.
  * The player is within the allowed interaction range.
  * The player is allowed to perform that interaction.
* If validation fails, reject silently or log using the project’s existing logger pattern.

Migration requirements:

* Preserve existing interaction logic where possible.
* If interaction logic is currently inside ProximityPrompt.Triggered callbacks, extract it into reusable server-side handlers.
* Do not leave important logic coupled only to ProximityPrompt.Triggered.
* Existing interactables should be easy to migrate one at a time.
* After this task, the current Workspace ProximityPrompts should be safe to delete.

Code standards:

* Follow the existing repo conventions.
* Inspect nearby files before implementing.
* Match existing naming, folder structure, module style, typing style, logging style, and service/controller patterns.
* Keep the implementation small, readable, and maintainable.
* Prefer clear modules with single responsibilities.
* Avoid broad rewrites.
* Do not introduce new dependencies unless clearly necessary.
* Do not change generated files.
* Do not make unrelated formatting changes.
* Preserve existing public APIs unless there is a strong reason to change them.
* Use strict typing where the repo already uses it.
* Handle nil/invalid instances defensively.
* Avoid duplicated logic between mouse, touch, and gamepad paths.
* Prefer shared helpers for common targeting/scoring/range checks.

Validation:

* Mouse:

  * Moving the mouse over an interactable within range highlights it.
  * Moving the mouse away removes the highlight.
  * Clicking or pressing the interact key activates the focused target.
* Gamepad:

  * Looking at an interactable with centre-screen targeting highlights it.
  * Pressing the configured gamepad button activates it.
  * Slightly imperfect aim still works when the object is clearly intended.
* Touch:

  * A valid nearby/in-front interactable shows the custom touch interaction UI.
  * Tapping the touch button activates it.
  * The white outline still appears where appropriate.
* General:

  * Only one target is highlighted at once.
  * Moving out of range removes the highlight and prompt.
  * Activating with no focused target does nothing.
  * Manually firing the RemoteEvent from too far away is rejected by the server.
  * Deleting the old Workspace ProximityPrompts does not break the new interaction system.

Final response:

* Summarise what changed.
* List the main files touched.
* Explain how the new interaction flow works.
* Mention any old ProximityPrompt behaviour that still needs manual migration.
* Mention what validation was run and any issues found.
