LW Creative Tools
	by loosewheel


Licence
=======
Code licence:
LGPL 2.1

Media licence:
CC BY-SA 3.0


Version
=======
0.1.4


Minetest Version
================
This mod was developed on version 5.4.0


Dependencies
============


Optional Dependencies
=====================
lwdrops


Installation
============
Copy the 'lwcreative_tools' folder to your mods folder.


Bug Report
==========
https://forum.minetest.net/viewtopic.php?f=9&t=27537


Description
===========
Tools for creative mode. These tools can only be used in creative mode,
and the 'lwcreative_tools' privilege is required. This privilege is
automatically granted to admins and singleplayer.

The tools that require a reference item use the item to the left of the
tool in the player's inventory in the operation. If the slot is blank then
air is used (nodes are just removed).

The stack size of the tool is the length/radius limit for the tool.
Left click to increase the length/radius by 1.
Left click + aux to decrease the length/radius by 1.
Left click + sneak to increase the length/radius by 10.
Left click + sneak + aux to decrease the length/radius by 10.

Use the tool by right clicking.

The chat command 'lwctundo' can be used to undo the tool's actions. Undo
actions are remembered per player.

The chat command 'lwctclear' can be used to clear the last undo action.
This frees the memory for it, useful after performing an operation on a
large volume. The action cannot be undone if cleared. Note that when an
action is undone (with lwctundo) it is automatically cleared. Undo actions
are remembered per player.


Linear Fill
Places nodes to the given length in the direction the player is facing.
This tool fills empty spaces and replaceable nodes, such as grass. The
space clicked must be empty to start. Filling stops when the full length
is placed or a node is met.


Linear Replace
Places nodes to the given length in the direction the player is facing.
This tool replaces nodes, whether the space is empty or not. The space
clicked must have a node to start. Replacing stops when the full length
is placed.


Linear Substitute
Places nodes to the given length in the direction the player is facing.
This tool replaces currently filled spaces. Replacing stops when the full
length is placed or a node different to the one clicked is met.


Area Fill
Places nodes to the given radius on the surface the player is pointing at.
This tool fills empty spaces and replaceable nodes, such as grass. The
space clicked must be empty to start. Filling stops when the full radius
is placed or a node is met. If the aux key is held while placing a square
area is affected (side = radius * 2 + 1).


Area Replace
Places nodes to the given radius in the surface the player is pointing at.
This tool replaces nodes, whether the space is empty or not. The space
clicked must have a node to start. Replacing stops when the full radius
is placed or an empty space is met. If the aux key is held while placing
a square area is affected (side = radius * 2 + 1).


Area Substitute
Places nodes to the given radius in the surface the player is pointing at.
This tool replaces currently filled spaces. Replacing stops when the full
radius is placed or a node different to the one clicked is met. If the aux
key is held while placing a square area is affected (side = radius * 2 + 1).


Copy Cube
Copies a cube of nodes the length of the stack size. The cube extends
forward, right and up from the node clicked, including that node as the
bottom, left corner. Each player has their own clipboard.


Copy
Copies a block volume. First right click the lower left corner closest to
the player. Then the top right corner the furthest forward. This orientation
is always assumed. If the second height is less than the first they are
switched. A chat message is sent to the player when the first position is
set, and the again when the second is set. If the volume of the copied
region is greater than the Maximum copy volume setting a message is sent
to the player, and the copy operation is cancelled. Each player has their
own clipboard.


Paste Fill
Pastes the contents of the clipboard to the node clicked. The placement
is the same relative position to the player from when it was copied, ie.
the node space clicked is the bottom, left corner closest to the player.
This paste operation only fills empty spaces and replaceable nodes, such
as grass. The space clicked must be empty to start.


Paste Replace
Pastes the contents of the clipboard to the node clicked. The placement
is the same relative position to the player from when it was copied, ie.
the node space clicked is the bottom, left corner closest to the player.
This paste operation replaces nodes, whether the space is empty or not
(exact copy). The space clicked must have a node to start.


Save
Saves the current copy buffer to a file. When right clicked a form opens
asking for the name for the save. A chat message is sent to the player
stating whether the save was successful or not. Each player has their own
saves. The location of the saved file is:

<world folder>/lwcreative_tools/<player name>/<save name>

* Any of the characters ? * / \ : in any name are replaced with _
* The files can be copied to other player folders or other worlds to
  make them available.


Load
Loads a saved buffer into the copy buffer. When right clicked a form opens
asking for the name of the save. A chat message is sent to the player
stating whether the load was successful or not. Each player has their own
saves.


Measure
The measure tool measures block distances and angle between two block
positions. Lift click a node to set the measures reference position; the
position the measurements are taken from. When a node is right clicked
a chat message is sent to the player as:

NS: n EW: n H: n A: f.f L f.f

NS is followed by the distance from the reference position in the North/South
(z) direction.
EW is followed by the distance from the reference position in the East/West
(x) direction.
H is followed by the distance from the reference position in height (y)
direction.
A is followed by the angle from the reference position in degrees. 0 degrees
is straight North. Positive degrees is rotating to the right, negative to
the left.
L is the length of direct line from the reference position.



The mod supports the following settings:

Maximum block radius (int)
	Maximum block radius for circular tool actions.
	Default: 20

Maximum block length (int)
	Maximum block length for linear tool actions.
	Default: 50

Maximum copy cube (int)
	Maximum one side block length for copy cube.
	Default: 40

Maximum copy volume (int)
	Maximum block volume for a copy operation.
	Default: 64000

Maximum undo limit (int)
	Maximum undo actions remembered per player.
	Default: 10

Use save/load (bool)
	Use the save and load tools.
	Default: true

* Note - the Maximum copy cube and Maximum copy volume settings act
independently of each other.


------------------------------------------------------------------------
