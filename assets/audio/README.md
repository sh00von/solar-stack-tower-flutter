# Audio assets

Drop real sound files here. The game looks for:

- `click.wav`  — played on every block drop.
- `perfect.wav` — played on a perfect (fully-aligned) stack.

The game runs fine if these files are missing (audio is wrapped in try/catch),
so you can wire in real assets at any time without touching code.

TODO: replace these placeholders with real short SFX (mono, 44.1kHz, < 1s).
