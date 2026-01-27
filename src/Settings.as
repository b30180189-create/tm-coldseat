[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Mode" beforerender="DisableModeSwitch" afterrender="EnableModeSwitch"
description="Switching to 'Limited' or 'Redemption' mode clears all players' times"]
Mode S_Mode = Mode::Forever;

[Setting category="General" name="Rounds" if="S_Mode Limited"]
uint S_Rounds= 3;

[Setting category="General" name="Show medal icons"]
bool S_MedalIcons = true;

[Setting category="General" name="Show disclaimer"]
bool S_Disclaimer = false;

[Setting hidden]
bool S_DisclaimerShown = false;

void DisableModeSwitch() {
    UI::BeginDisabled(inRun);
}

void EnableModeSwitch() {
    UI::EndDisabled();
}
