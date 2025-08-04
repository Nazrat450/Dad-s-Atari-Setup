Dad's Atari Setup 🚀
Welcome, Dad!
This simple setup lets you pick and play your Atari games (ROMs) easily. No messing with folders yourself—the launcher does everything for you.

🎯 What It Does
Organizes your ROMs in folders by game system (e.g., 2600, 5200, XL/XE, etc.).

Shows a simple menu of games you’ve loaded.

Lets you launch any ROM with just a double‑click or menu select.

Optional: automatically opens the emulator so you don’t need to find it.

🛠️ Initial Setup (One-Time)
Install the emulator (follow included instructions or README in the emulator/ folder).

Put your ROM files into the matching subfolders:

roms/
  ├── 2600/
  ├── 5200/
  ├── XL_XE/
Open the launcher script:

On Windows: double‑click Start Atari Launcher.bat

On macOS/Linux: open Terminal and run ./start_atari.sh

Once that’s done, the menu will display all available games automatically.

🎮 How to Use (Every Time)
Launch the “Atari Launcher” (double‑click or run the script).

You’ll see a game menu, look like:

Atari 2600
  • Pac-Man.rom
  • Pitfall.rom
Atari XL/XE
  • Boulder Dash.rom
Use the arrow keys or mouse to pick a game.

Press Enter (or click) to start – the emulator opens and loads the game.

✏️ Adding New Games
Simply copy new .rom files into the matching folder (e.g. roms/2600/).

Relaunch the menu — it will automatically detect and list them.

⚙️ Changing Settings
If you want to:

Change emulator options (graphics, sound, controls),

Or customize the theme of the launcher,

open the config/launchersettings.json file and make updates there. Default settings are set for smooth play; only change them if you know what you’re doing.

🧩 Troubleshooting
Problem	What to Try
Launcher doesn’t open	Make sure the script is executable or you’re using the correct OS version
Game doesn't run	Check the .rom file isn’t corrupted and is in the correct folder
Emulator window is blank	Shut down, reopen the launcher, or try a different ROM

If any step seems weird or something doesn’t work, feel free to ping me and I'll help sort it out! Enjoy your retro gaming setup! 🎮
