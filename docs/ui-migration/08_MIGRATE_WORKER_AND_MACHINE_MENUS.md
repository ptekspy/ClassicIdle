# Migrate Worker And Machine Menus

## Goal

Replace the two similar imperative modal menus with shared React presentation while preserving their existing remote actions.

## Files to create

```txt
src/ReplicatedStorage/UI/Components/ActionButton.luau
src/ReplicatedStorage/UI/Components/ModalPanel.luau
src/ReplicatedStorage/UI/Components/WorkerMenuContent.luau
src/ReplicatedStorage/UI/Components/MachineMenuContent.luau
src/ReplicatedStorage/UI/Screens/WorkerScreen.luau
src/ReplicatedStorage/UI/Screens/MachineScreen.luau
```

## Worker controller changes

Replace `showMenu` visual mutation with:

```luau
UIState.Set("workerMenu", payload)
```

Pass callbacks from `WorkerScreen` that use the existing `WorkerRequest` remote:

```luau
requestEvent:FireServer("Buy", role)
requestEvent:FireServer("Upgrade", npcId, "Speed")
requestEvent:FireServer("Upgrade", npcId, "Amount")
```

Close sets `workerMenu` to `nil`.

## Machine controller changes

Replace `show` visual mutation with:

```luau
UIState.Set("machineMenu", payload)
```

Keep the existing `MachineRequest` calls.

Add the missing startup in `ClientBootstrap.client.luau`:

```luau
local MachineController = require(script.Parent.Controllers.MachineController)
MachineController.Start()
```

## Preserve exact visuals

Both screens must retain:

- display order `30`
- full-screen black shade at transparency `0.45`
- centered panel, height `390`, min width `300`, max width `520`
- Gotham typography
- current button colors, sizes, wrapping, and text

## Validation

- Hire each available NPC role.
- Open and close worker management.
- Upgrade worker speed and amount.
- Open every machine menu.
- Test processor upgrades, standard upgrades, and collection.
- Confirm disabled/locked worker choices cannot fire remotes.

## Done when

Worker and machine menus are React-owned and the old `WorkerGui`/`MachineGui` construction is removed.
