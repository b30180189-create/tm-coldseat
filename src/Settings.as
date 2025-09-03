// c 2025-09-02
// m 2025-09-02

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Mode" description="Switching to 'Limited' mode clears all players' times"]
Mode S_Mode = Mode::Forever;

[Setting category="General" name="Rounds" if="S_Mode Limited"]
uint S_Rounds= 3;
