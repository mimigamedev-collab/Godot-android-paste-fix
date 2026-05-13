@tool
extends Control

# ─── Tunable constants ───────────────────────────────────────────────
const CHUNK_SIZE        := 200   # chars read per frame from clipboard
const INDENT_SPACES     := "\t"  # Godot default = tab; change to "    " if you prefer 4-spaces

# ─── Internal state ──────────────────────────────────────────────────
var editor_interface: EditorInterface
var _raw_code   := ""
var _status_timer: SceneTreeTimer

# ─── Node refs (assigned in _ready) ──────────────────────────────────
@onready var preview_edit : TextEdit  = $VBox/Preview
@onready var status_label : Label     = $VBox/StatusBar/StatusLabel
@onready var char_count   : Label     = $VBox/StatusBar/CharCount
@onready var paste_btn    : Button    = $VBox/Buttons/PasteBtn
@onready var apply_btn    : Button    = $VBox/Buttons/ApplyBtn
@onready var clear_btn    : Button    = $VBox/Buttons/ClearBtn

# ════════════════════════════════════════════════════════════════════
func _ready() -> void:
 paste_btn.pressed.connect(_on_paste_pressed)
 apply_btn.pressed.connect(_on_apply_pressed)
 clear_btn.pressed.connect(_on_clear_pressed)
 apply_btn.disabled = true
 _set_status("Ready", false)

# ════════════════════════════════════════════════════════════════════
# STEP 1 – Read clipboard in chunks to avoid Android drop bug
# ════════════════════════════════════════════════════════════════════
func _on_paste_pressed() -> void:
 paste_btn.disabled = true
 _set_status("Reading clipboard…", false)
 await get_tree().process_frame          # let UI refresh

 var full := DisplayServer.clipboard_get()

 if full.is_empty():
  _set_status("⚠ Clipboard is empty", true)
  paste_btn.disabled = false
  return

 # Chunk-reassemble to detect truncation (safe no-op on desktop)
 var rebuilt := ""
 var offset  := 0
 while offset < full.length():
  rebuilt += full.substr(offset, CHUNK_SIZE)
  offset  += CHUNK_SIZE
  await get_tree().process_frame

 _raw_code = rebuilt

 var formatted := _format_code(_raw_code)
 preview_edit.text = formatted
 char_count.text   = "%d chars" % formatted.length()
 apply_btn.disabled = false
 paste_btn.disabled = false
 _set_status("✓ Loaded – review then Apply", false)

# ════════════════════════════════════════════════════════════════════
# STEP 2 – Format: normalise indent, strip BOM / weird whitespace
# ════════════════════════════════════════════════════════════════════
func _format_code(raw: String) -> String:
 # 1. Remove BOM (U+FEFF) and carriage returns
 var bom := char(0xFEFF)
 var code := raw.replace(bom, "").replace("\r\n", "\n").replace("\r", "\n")

 # 2. Split into lines
 var lines := code.split("\n")
 var out   : PackedStringArray = []

 for line in lines:
  # 3. Detect leading whitespace type and normalise
  var stripped := line.lstrip(" \t")
  var leading  := line.left(line.length() - stripped.length())

  # Count logical indent level (treat 4 spaces OR 2 spaces as 1 level)
  var level := _detect_indent_level(leading)

  # Rebuild with preferred indent char
  out.append(INDENT_SPACES.repeat(level) + stripped)

 # 3. Re-join, trim trailing blank lines
 var result := "\n".join(out).strip_edges()
 return result

func _detect_indent_level(leading: String) -> int:
 if leading.is_empty():
  return 0
 # Already using tabs
 if "\t" in leading:
  return leading.count("\t")
 # Spaces – figure out unit (2 or 4)
 var spaces := leading.length()
 if spaces % 4 == 0:
  return spaces / 4
 if spaces % 2 == 0:
  return spaces / 2
 return spaces   # fallback: 1 space = 1 level (unusual)

# ════════════════════════════════════════════════════════════════════
# STEP 3 – Apply: replace active script content
# ════════════════════════════════════════════════════════════════════
func _on_apply_pressed() -> void:
 if not editor_interface:
  _set_status("⚠ No editor_interface", true)
  return

 var script_editor := editor_interface.get_script_editor()
 if not script_editor:
  _set_status("⚠ Script editor not open", true)
  return
 var current := script_editor.get_current_script()
 if not current:
  _set_status("⚠ No script open – open a .gd file first", true)
  return

 var formatted := preview_edit.text   # use whatever user sees (they may have edited)

 # Write to the resource and save
 current.source_code = formatted
 ResourceSaver.save(current)

 # Reload in editor so the view refreshes
 editor_interface.edit_resource(current)

 apply_btn.disabled = true
 _set_status("✓ Applied to %s" % current.resource_path.get_file(), false)

# ════════════════════════════════════════════════════════════════════
func _on_clear_pressed() -> void:
 preview_edit.text  = ""
 char_count.text    = "0 chars"
 _raw_code          = ""
 apply_btn.disabled = true
 _set_status("Cleared", false)

func _set_status(msg: String, is_error: bool) -> void:
 status_label.text            = msg
 status_label.modulate        = Color.RED if is_error else Color.WHITE
