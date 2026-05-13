📋 godot-android-paste-fix
AIPasteDock — Paste code from AI into Godot on Android without missing characters or indent errors.
Made by Mimi Studio 🎮
🐛 Problem
When using the Godot editor on Android and pasting code from AI (ChatGPT, Claude, etc.) or other sources:
❌ Characters get cut off or lost mid-paste
❌ Indentation errors appear after pasting
❌ Long code blocks (100+ lines) are especially unreliable
This happens because Android has limitations on clipboard reads in a single call, and Godot's built-in paste doesn't handle indent normalization.
✅ Solution
AIPasteDock is an editor plugin that:
Reads clipboard in safe chunks (200 chars at a time) to avoid character loss
Detects and normalizes indentation (tabs ↔ spaces) to match your script
Provides a dedicated dock panel so you can preview and apply code safely
Works with any script in your project
📦 Installation
Download or clone this repository
Copy the addons/ai_paste folder into your Godot project
Go to Project → Project Settings → Plugins
Enable AIPasteDock
The dock will appear on the right side of your editor
🚀 Usage
Copy code from your AI tool (Claude, ChatGPT, etc.)
Open the AIPasteDock panel on the right
Tap Read Clipboard — the plugin reads it safely in chunks
Preview the code and check char count
Tap Apply to Script — code is inserted with correct indentation
⚙️ Configuration
In the dock panel you can tune:
Constant
Default
Description
CHUNK_SIZE
200
Characters read per frame from clipboard
INDENT_SPACES
\t
Godot default is tab; change to "    " for 4-spaces
🔧 Requirements
Godot 4.6+
Android (this plugin targets Android editor usage)
📄 License
MIT License — see LICENSE
Free to use, modify, and distribute. Credit to Mimi Studio appreciated but not required.
💬 Credits
Created by Mimi team
If this plugin helped you, consider sharing it with other Godot Android users! 🙌