// c 2025-09-02
// m 2025-09-13

const string  pluginColor = "\\$8DF";
const string  pluginIcon  = Icons::SnowflakeO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

string     newName;
const vec4 rowBgColor = vec4(vec3(), 0.5f);

void Main() {
    File::Load();

    bool inMap    = InMap();
    bool wasInMap = inMap;

    bool newRun = false;

    Mode lastMode = S_Mode;

    while (true) {
        yield();

        if (lastMode != S_Mode) {
            lastMode = S_Mode;
            switch (S_Mode) {
                case Mode::Limited:
                case Mode::Redemption:
                    ClearPlayerTimes();
                    index = 0;
            }
        }

        if (!S_Enabled) {
            inMap = false;
            wasInMap = false;
            continue;
        }

        inMap = InMap();

        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap) {
                // print("enter map");
            } else {
                // print("exit map");
                ClearPlayerTimes();

                if (inRun) {
                    Limited::Stop();
                    Redemption::Stop();
                }
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

    if (inRun) {
        if (S_Mode == Mode::Limited) {
            if (index == players.Length - 1) {
                Limited::roundsLeft--;
            }

            if (Limited::roundsLeft == 0) {
                Limited::Stop();
            }

        } else {
            if (!Redemption::active) {
                ;
            }
        }

    } else {
        if (false
            or S_Mode == Mode::Limited
            or S_Mode == Mode::Redemption
        ) {
            return;
        }
    }

    if (players[index].AddTime(time)) {
        Increment();
    }
}

void RenderWindow() {
    const float scale = UI::GetScale();

    UI::BeginDisabled(inRun);
    if (UI::BeginCombo("Mode", tostring(S_Mode), UI::ComboFlags::HeightLargest)) {
        for (int i = 0; i < 3; i++) {
            Mode mode = Mode(i);
            if (UI::Selectable(tostring(mode), S_Mode == mode)) {
                S_Mode = mode;
            }
        }

        UI::EndCombo();
    }
    UI::EndDisabled();

    UI::SameLine();
    UI::AlignTextToFramePadding();
    UI::TextDisabled(Icons::QuestionCircle);
    UI::SetItemTooltip("Switching to 'Limited' or 'Redemption' mode clears all players' times");

    switch (S_Mode) {
        case Mode::Forever:
            UI::BeginDisabled(players.Length < 2);

            if (UI::Button(Icons::ArrowLeft + " Previous")) {
                Decrement();
            }

            UI::SameLine();
            if (UI::Button(Icons::ArrowRight + " Next")) {
                Increment();
            }

            UI::EndDisabled();

            break;

        case Mode::Limited:
            if (!inRun) {
                UI::BeginDisabled(!InMap());
                if (UI::Button(Icons::Play + " Start Run")) {
                    Limited::Start();
                }
                UI::EndDisabled();

                UI::SameLine();
                UI::SetNextItemWidth(scale * 120.0f);
                S_Rounds = Math::Clamp(UI::InputInt("Round" + (S_Rounds == 1 ? "" : "s") + "###rounds", S_Rounds), 1, 10000);

            } else {
                if (UI::Button(Icons::Stop + " End Run")) {
                    Limited::Stop();
                }

                UI::SameLine();
                UI::TextDisabled("(" + Limited::roundsLeft + " Round" + (Limited::roundsLeft == 1 ? "" : "s") + " Left)");
            }

            break;

        case Mode::Redemption:
            if (!inRun) {
                UI::BeginDisabled(!InMap());
                if (UI::Button(Icons::Play + " Start Run")) {
                    Redemption::Start();
                }
                UI::EndDisabled();

            } else {
                if (UI::Button(Icons::Stop + " End Run")) {
                    Redemption::Stop();
                }

                UI::SameLine();
                UI::TextDisabled("(Round " + Redemption::round + ")");
            }

            break;
    }

    UI::BeginChild("##child-table-players", UI::GetContentRegionAvail() - vec2(0.0f, scale * 60.0f));

    if (UI::BeginTable("##table-players", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgColor);

        UI::TableSetupScrollFreeze(0, 1);
        // UI::TableSetupColumn("#",       UI::TableColumnFlags::WidthFixed, scale * 30.0f);
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
            File::Save();

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

    UI::EndChild();

    UI::SeparatorText("Add New Player");

    UI::BeginDisabled(inRun);

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

    UI::EndDisabled();
}
