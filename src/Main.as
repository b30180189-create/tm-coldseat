// c 2025-09-02
// m 2025-09-02

const string  pluginColor = "\\$8DF";
const string  pluginIcon  = Icons::SnowflakeO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

string     newName;
const vec4 rowBgColor = vec4(vec3(), 0.5f);

void Main() {
    bool inMap    = InMap();
    bool wasInMap = inMap;

    bool newRun = false;

    while (true) {
        yield();

        if (!S_Enabled) {
            inMap = false;
            wasInMap = false;
            continue;
        }

        inMap = InMap();

        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap) {
                print("enter map");
            } else {
                print("exit map");
                ClearPlayerTimes();
            }
        }

        if (!inMap) {
            continue;
        }

        const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
        if (false
            or raceData is null
            or raceData.LocalPlayer is null
        ) {
            continue;
        }

        if (true
            and newRun
            and raceData.LocalPlayer.IsFinished
            and raceData.LocalPlayer.LastCpTime > 0
        ) {
            newRun = false;
            OnFinishedRun(raceData.LocalPlayer.LastCpTime);
        } else if (!raceData.LocalPlayer.IsFinished) {
            newRun = true;
        }
    }
}

void Render() {
    if (false
        or !S_Enabled
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    if (UI::Begin(pluginTitle + "###main-" + pluginMeta.ID, S_Enabled, UI::WindowFlags::None)) {
        RenderWindow();
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void OnFinishedRun(const int time) {
    if (false
        or time <= 0
        or players.Length == 0
    ) {
        return;
    }

    players[index].AddTime(time);
    Increment();
}

void RenderWindow() {
    const float scale = UI::GetScale();

    UI::SetNextItemWidth((UI::GetContentRegionAvail().x - 15.0f) / scale - scale * 25.0f);
    bool changed;
    newName = UI::InputText("##new", newName, changed, UI::InputTextFlags::EnterReturnsTrue);

    UI::SameLine();
    UI::BeginDisabled(newName.Length == 0);
    if (false
        or UI::Button(Icons::Plus)
        or changed
    ) {
        AddPlayer(newName);
        newName = "";
    }
    UI::EndDisabled();
    UI::SetItemTooltip("Add New Player");

    UI::BeginDisabled(players.Length < 2);

    if (UI::Button(Icons::ArrowLeft + " Previous")) {
        Decrement();
    }

    UI::SameLine();
    if (UI::Button(Icons::ArrowRight + " Next")) {
        Increment();
    }

    UI::EndDisabled();

    if (UI::BeginTable("##table-players", 6, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("#",       UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("last",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("best",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("average", UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("actions", UI::TableColumnFlags::WidthFixed, scale * 200.0f);
        UI::TableHeadersRow();

        int removeAt = -1;

        UI::ListClipper clipper(players.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                if (!players[i].RenderRow(i)) {
                    removeAt = i;
                }
            }
        }

        if (removeAt != -1) {
            players.RemoveAt(removeAt);

            if (true
                and index > 0
                and removeAt <= int(index)
            ) {
                Decrement();
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }
}
