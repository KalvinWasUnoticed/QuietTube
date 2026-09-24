# Make it your own

[← QuietTube](../README.md)

Open **You → Settings → General → Quiet controls**. Every switch saves a preference for the **next guest launch**. The small notice disappears without confirmation; the footer keeps showing pending changes until you restart. The master switch pauses modifications without clearing your individual choices.

## Presets

| Preset | Saves | Preserves |
| --- | --- | --- |
| Ads & essentials | Master, video ads, feed ads, additional ad formats, extended matching and classic logo ON; detailed activity/template capture OFF | Existing feed-cleanup choices, background audio, automatic-next-video preference |
| Focused feed | Ads & essentials, plus all available feed cleanup ON | Background audio and automatic-next-video preference |

The preview shows all affected settings before Apply. Backing out changes nothing. Presets are additive bundles, not resets: switching from Focused feed to Ads & essentials does not undo feed cleanup. Basic bounded support counters still work with detailed tracing off.

## Ads

- **Block video ads:** enables the tested native player workaround. Also enables the dynamic feed-insertion fix when Block feed ads is on.
- **Block feed ads:** filters recognized explicitly marked feed items. The tested post-minimize insertion fix needs both this and Block video ads enabled.
- **Additional ad formats:** broader image/display-template matching. Also enables feed ads and extended matching. Nested promotional content may match.

The insertion fix rejects explicitly marked entries only during a scoped synchronous native insertion transaction. It does not block every item following a swipe or use a generic “Sponsored” text rule. Other paths and formats may escape filtering. If YouTube reports a playback error, the safety latch reverts future calls to native behavior and saves the profile OFF; it does not repair an existing player or restore already-withheld feed entries. Restart or roll back if needed. There is no anti-detection or universal playback guarantee.

## Feed

Optional controls hide recognized Shorts shelves, Mixes, Watch it again shelves, topic suggestions, Playables, promotional shelves and large portrait cards. Most enable extended matching automatically when turned on. Disabling extended matching preserves these saved selections and pauses dependent rules; their descriptions explain the dependency.

Important limits:
- Shorts shelves are not the Shorts tab, and not every Shorts surface is covered.
- Watch it again uses English shelf-title matching and a bounded template fallback. It does not delete history.
- Topic matching can affect other chip shelves; portrait-card matching can affect smaller portrait cards too.
- Mix detection can match nested Mix destinations. These rules do not search arbitrary video titles.

## Playback and appearance

**Background audio** and **Stop the next video** are separate controls. The latter affects supported next-video actions, not in-feed previews. **Classic YouTube logo** removes seasonal/event header artwork. Use YouTube's native PiP control; there is no duplicate QuietTube PiP switch.

## Advanced and support

- **Extended feed matching:** shared prerequisite for broader cleanup.
- **Troubleshooting:** optional local feed activity/template capture, short support report, full diagnostics and clearing template capture. Prepare a support test enables the current diagnostic prerequisites and requires restart; it preserves unrelated settings.
- **Disable all options:** deliberately clears all QuietTube toggles for the next launch and asks for confirmation. It does not delete your YouTube account/history.

Diagnostics distinguish requested preferences, installed hooks, actual calls and withheld entries. None alone proves all ads are gone. Detailed captures are bounded; missing events can mean an unmonitored path or a capture limit, not necessarily no activity. [Privacy →](PRIVACY.md)
