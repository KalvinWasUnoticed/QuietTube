# 0.3 settings update

Removes redundant PiP controls and hooks. Presents Quiet controls from the native General entry in an isolated UIKit navigation sheet, with Done and standard back navigation. Preserves 0.2 preferences when the existing data container is retained. No new player-ad mutation.

# 0.2 recovery

Removed model-getter and layout-hiding hooks after an empty-array crash. Introduced opt-in launch-time flags and narrow presentation-boundary feed filtering. User subsequently reported successful feed filtering, Shorts shelves, background audio and native PiP tests. Native PiP showed no demonstrated benefit from our optional eligibility hooks.
