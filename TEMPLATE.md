# Coding & Documentation Standard for this project

##

### 1. File Header (Doxygen Style)

Use a standard block at the very top of every script to identify ownership and purpose.

* **Syntax:** `#` followed by `*` border.
* **Tags:** `@file`, `@author`, `@date`, `@brief`.

```gdscript
# ******************************************************************************
# * @file    <filename>
# * @author  Javier
# * @date    <date>
# * @brief   <description>
# ******************************************************************************

```

### 2. Section Dividers

Divide the file into high-level categories using uppercase blocks.

```gdscript
# ************************************
# * INCLUDES
# ************************************

# e.g. extends NodeX

# ------------------------------------

# ************************************
# * PRIVATE MACROS AND DEFINES
# ************************************
# (optional)

# ------------------------------------

# ************************************
# * VARIABLES
# ************************************




```

### 3. Variable Organization

Inside the `VARIABLES` section, group related properties using "Three Equals" headers.
**example below:**

```gdscript
# === Node References ===
@onready var sprite = $Sprite2D

# === Configuration: Movement ===
const SPEED = 100.0

# === State Variables ===
var current_health = 10

```

### 4. Function Documentation (Godot + Doxygen)

We use the **Double Hash (`##`)** syntax so Godot creates tooltips in the editor. We use Doxygen-Style tags for parameters and returns.

* **Description:** Short summary first. Detailed explanation (if needed) after a break.
* **@param:** usage: `name: description`
* **@return:** usage: `Type: description`

**example below:**

```gdscript
# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Calculates the isometric projection of a vector.
## Squashes the Y-axis to create the 2.5D depth effect.
##
## @param input_vector: The Cartesian input (e.g., Input.get_vector).
## @return Vector2: The adjusted vector for isometric movement.
func to_isometric(input_vector: Vector2) -> Vector2:
    return Vector2(input_vector.x - input_vector.y, (input_vector.x + input_vector.y) * 0.5)

```

---

### Notes

1. **`##` vs `#`:** `##` shows up in the Godot Inspector when you hover over the function name in other scripts. Standard `#` does not.
2. **Organization:** The `=== Header ===` style makes scrolling through long files (like Player controllers) much faster visually.

#### Full Template

```gdscript
# ******************************************************************************
# * @file    <filename>
# * @author  Javier
# * @date    <date>
# * @brief   <description>
# ******************************************************************************

# ************************************
# *         INCLUDES
# ************************************

# ************************************
# *     PRIVATE MACROS AND DEFINES
# ************************************

# ************************************
# *         VARIABLES
# ************************************

# ************************************
# *     FUNCTION DEFINITIONS
# ************************************

```
