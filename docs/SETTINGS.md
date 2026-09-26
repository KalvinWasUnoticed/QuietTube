# Settings

[← QuietTube](../README.md)

Open **You → Settings → General → Quiet controls**.

Switches save choices for the next launch. Close and reopen the app to apply them. The short save notice disappears by itself; the footer keeps the restart reminder until the saved settings match the launch state.

The master switch pauses modifications without clearing individual choices. On a fresh install, master/video/feed blocking start on. An update does not replace an existing off choice with the new defaults.

## Presets

Both presets show a preview. Backing out changes nothing.

| Preset | What Apply saves | What it leaves alone |
| --- | --- | --- |
| Ads & essentials | Master, video/feed blocking, additional ad formats, extended matching and classic logo ON; detailed activity/template capture OFF | Existing feed-cleanup selections, background audio and automatic-next preference |
| Focused feed | The above, plus all available feed-cleanup options ON | Background audio and automatic-next preference |

Presets add settings; they are not resets. Switching from Focused feed to Ads & essentials does not undo the feed cleanup. Basic support counters still run when detailed capture is off. These presets do not control a temporary manual diagnostic session.

## Ads

- **Block video ads** enables the native player workaround. It also enables the scoped dynamic feed-insertion workaround when **Block feed ads** is on.
- **Block feed ads** filters recognized, explicitly marked feed items. The observed post-minimize insertion path needs both switches.
- **Additional ad formats** adds broader image/display-template matching and enables feed ads plus extended matching. It can match nested promotional content too.

### What the player workaround does

QuietTube substitutes YouTube’s native `YTNoOpAdsPlaybackCoordinator` at the inspected factory, using the existing service-registry scope and delegate. Signature/constructor failures fall back to the original factory. It does not replace the content player or run a refresh/retry loop.

This is not an App Attest or PO-token implementation. “Something went wrong” is a generic error, not proof of one cause or proof that this workaround fixes it.

If the existing error observer sees a playback error while the ad profile is active, the safety latch pauses future player substitutions and protected scoped insertion for that session. The saved switch stays unchanged. The pause does not repair a player that already exists, restore withheld feed entries or switch off every independent feed-cleanup rule. Settings and the support report show the pause. A new launch retries the saved choice.

The insertion filter operates inside a scoped synchronous native transaction. It checks explicit markers; it does not remove every item after a swipe or match generic “Sponsored” text. Other paths can still show ads.

## Feed cleanup

There are separate controls for Shorts shelves, Mixes, Watch it again, topic suggestions, Playables, promotional shelves and large portrait cards. Most require extended matching, which enabling the dependent option also enables. Turning extended matching off pauses those rules without deleting their saved choices.

Limits worth knowing:

- Hiding Shorts shelves does not remove the Shorts tab or every Shorts surface.
- Watch it again uses English shelf titles and a bounded template fallback. It does not delete watch history.
- Topic matching can catch other chip shelves; portrait-card matching can catch smaller portrait cards.
- Mix detection can match nested Mix destinations. It does not search arbitrary video titles.

## Playback and appearance

**Background audio** and **Stop the next video** are separate. The latter affects supported automatic-next actions, not in-feed previews.

**Classic YouTube logo** replaces seasonal/event logo artwork. PiP stays in YouTube’s own settings; there is no duplicate QuietTube PiP switch.

## Advanced

**Extended feed matching** is the shared prerequisite for broader cleanup.

**Troubleshooting** contains reports, the older activity/template capture switches, and manual diagnostic sessions. **Prepare a support test** enables its documented ad/matching/capture prerequisites for the next launch, leaving unrelated choices alone. [What each logging control does](DIAGNOSTICS.md).

**Disable all options** asks for confirmation, then saves all toggles off for the next launch. It does not delete your account or history. To stop a currently running manual diagnostic session immediately, use its **Stop** action.

## Saved choices

Ordinary restarts and updates keep local preferences. Toggling a switch, applying a preset/support setup, or confirming Disable all options deliberately changes them. Deleting app data, using a new container or changing app identity can lose them. There is no cloud backup.

### Upgrading from 1.0.0

The old error latch could save video blocking off. If that happened, enable it once after updating and restart. The updater cannot distinguish the old automatic off from a deliberate off, so it leaves either alone.

Manual recording is different: it is temporary session state and starts off after relaunch. It does not reset a saved switch. Recent log files can remain available for export; [storage and expiry limits](DIAGNOSTICS.md#storage-and-deletion) still apply.
