QuickTradeskill is a World of Warcraft addon to expedite the process of crafting tradeskill items. Similar to the programs Launchy (for Windows) and QuickSilver (for Mac), QuickTradeskill consists of a simple text box interface. When text is entered and the Enter key is pressed, QuickTradeskill will search the player's tradeskills for matches to the input text and display the results in clickable frames which can be used to create the item or copy a craft recipe link into chat. In addition to searching recipes the user knows, QuickTradeskill will also search through all of the in-game recipes provided by LibPeriodicTable for reference. (LibPeriodicTable does not currently have direct support for Inscription recipes. I will try to keep my eye on it and update as soon as possible after it is available!)

Usage:
A keybind to open/close the QuickTradeskill window can be set from the default keybindings menu.  Alternatively, the QuickTradeskill window can be opened and closed via the /qts show and /qts hide commands.

/qts will open the configuration options.

The main QuickTradeskill frame can be moved by dragging the edges, and the width can be changed by ctrl+dragging on the right edge.

When results are found from the tradeskill search, the new frames have the following properties:

Left click: create a single copy
Ctrl + left click: batch-craft multiple copies of the item
Shift + left click: paste the recipe link for the item into chat

There are three search modes:

    * Title Only
    * Title and Tooltip (Known Recipes)
    * Title and Tooltip (Everything)


To search by recipe title only, simply enter text into the edit box and hit the Enter key. To search through the titles of all recipes, plus the tooltips of recipes your character knows, prefix your search text with a '+' (ie. +netherweave will search for anything with the word 'netherweave' somewhere in the recipe's tooltip). To instead search all titles and all tooltips (even recipes you do not know), prefix your search with '++' (ie. ++netherweave).

There are numerous advantages to searching through tooltips, and the information returned can be quite exhaustive. For instance, with '+minor glyph' you can search for all of the minor glyphs you can create. There are also other possibilities, such as searching for recipes by materials, and so on.

Important:
The major drawback with doing tooltip searches is the time required. The exhaustive search is extremely CPU intensive, and will likely freeze WoW for a handful of seconds while it performs the search. However, it is unlikely that you will need to do these in a quick manner, so hopefully this is acceptable behavior.

Localization support:
QuickTradeskill should work for all locales. If anyone experiences problems with this, please let me know! 

Changelog:
--- 2008/05/19:
Localization support for Chinese (simplified) "zhCN" added.
Fixed a bug that would cause batch crafting to fail mid-cast if the QuickTradeskill 
 frame was re-opened during crafting.
 
--- 2008/09/16:
Support for the Inscription profession.
Added keybinding option to open/close the QuickTradeskill frame.
Temporarily disabled support for "zhCN" localization.
Informative tooltips added for ALL result frames.
Alphabetized result frames.

--- 2008/10/14:
Support for patch 3.0/WotLK expansion.

--- 2008/10/27:
Ability to search only recipes user knows, or all recipes in game (via LibPeriodicTable).
Addition of button to close the QTS window.

--- 2008/11/10:
Result frame throttling ability added.  Default is max of 5 result frames, changeable
 by using /qts [number] (failsafe set to 1 if [number] does not evaluate to a number).
"Scrolling" feature implemented to navigate through throttled list.
Former result lists combined (user and LibPeriodicTable).
Search action changed.  Now responds to OnEnterPressed for the edit box, instead of
 searching in response to OnTextChanged.
Close button changed to simple templated Close button.

--- 2008/11/27:
Automatic localization for all game locales.
Updated LibPeriodicTable to r75 (still no Inscription).

--- 2009/01/30:
Scroll-wheel support for browsing results list.
Search result acknowledgement.
Support for batch-crafting any number of copies of an item.
Blizzard Interface Options support.
Cleaned up the source a bit.
