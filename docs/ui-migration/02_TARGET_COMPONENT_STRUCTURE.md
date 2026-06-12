# Target Component Structure

## Create this structure

```txt
src/ReplicatedStorage/UI/
  Components/
    ActionButton.luau
    ModalPanel.luau
    ProgressBar.luau
    FeedbackToast.luau
    QuestCard.luau
    InteractionPrompt.luau
    TouchInteractButton.luau
    Crosshair.luau
    Hotbar.luau
    HotbarSlot.luau
    BuildControls.luau
    BuildShop.luau
    BuildShopItem.luau
    WorkerMenuContent.luau
    MachineMenuContent.luau
    FactoryManageContent.luau
  Context/
    PlayerDataContext.luau
  Screens/
    App.luau
    FeedbackScreen.luau
    QuestScreen.luau
    InteractionScreen.luau
    WorkerScreen.luau
    MachineScreen.luau
    FactoryScreen.luau
  World/
    WorldLabel.luau
    SellBillboard.luau
    SellSurfaceDisplay.luau
    RespawnProgress.luau
  Theme.luau
  Types.luau
```

Create this client-side bridge structure:

```txt
src/StarterPlayer/StarterPlayerScripts/UI/
  UIRoot.luau
  UIState.luau
```

Create this server-side Replica service:

```txt
src/ReplicatedStorage/Services/PlayerDataReplicaService/
  init.luau
```

## Ownership rules

- `UIRoot` mounts and unmounts React exactly once.
- `PlayerDataContext` is the only module that subscribes to the player-data replica.
- Screens may call `usePlayerData()` and pass plain values into components.
- Leaf components accept props and never require remotes, controllers, or Replica.
- Controllers own gameplay input and publish transient UI state to `UIState`.
- Existing server services remain authoritative.

## Core props

```luau
export type QuestCardProps = {
	title: string,
	description: string,
	progressText: string,
	visible: boolean,
}

export type InteractionPromptProps = {
	actionText: string,
	objectText: string,
	inputHint: string,
	visible: boolean,
}

export type ActionButtonProps = {
	text: string,
	enabled: boolean?,
	size: UDim2?,
	onActivated: () -> (),
}
```

## Parent relationships

| Screen | Components | Data |
|---|---|---|
| `App` | all screens | providers and transient state |
| `QuestScreen` | `QuestCard` | quest presentation state |
| `InteractionScreen` | prompt, touch button, crosshair | controller state |
| `FactoryScreen` | shop, hotbar, controls, manage content | player context plus factory transient state |
| `WorkerScreen` | modal and worker content | worker menu payload |
| `MachineScreen` | modal and machine content | machine menu payload |

## Done when

- Every meaningful visual piece has one owning component file.
- Leaf components receive props.
- No leaf component accesses `Players`, Replica, or `RemoteManager`.
