const string  pluginColor = "\\$8DF";
const string  pluginIcon  = Icons::SnowflakeO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

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

    RenderDisclaimer();

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

void RenderDisclaimer() {
    if (true
        and S_DisclaimerShown
        and !S_Disclaimer
    ) {
        return;
    }

    const string id = pluginTitle + " Disclaimer";
    const int flags = 0
        | UI::WindowFlags::NoMove
        | UI::WindowFlags::NoResize
        | UI::WindowFlags::NoSavedSettings
    ;

    const int2 size = int2(500, 360);
    UI::SetNextWindowSize(size.x, size.y);
    const float scale = UI::GetScale();
    UI::SetNextWindowPos(int(Display::GetWidth() / scale - size.x) / 2, int(Display::GetHeight() / scale - size.y) / 2);

    UI::OpenPopup(id);

    bool open;

    if (UI::BeginPopupModal(id, open, flags)) {
        UI::Markdown(
            "Coldseat is similar to the standard hotseat mode, but playable anywhere and comes with a few different "
            "modes of its own. Its purpose is to let you track recent runs on a map in different \"categories.\" What "
            "this means is up to you - maybe you like to try different strategies one after the other, maybe you have "
            "multiple personalities or fursonas, or maybe you just like to imagine you have in-person friends to play "
            "with when you don't. I'm not here to judge - I'm just here to turn calories into lines of code."
        );

        UI::NewLine();

        UI::PushStyleColor(UI::Col::Text, vec4(1.0f, 0.8f, 0.1f, 1.0f));
        UI::Markdown(
            "This plugin is for your own **personal** use only - it is against the game's terms of service to share "
            "your account with someone else. By using this plugin, you understand that you as an **individual human** "
            "are the only one doing so on your account. If you have other poeple you'd like to play with, you should "
            "use the hotseat mode provided by the game or the \"Better Hotseat\" plugin."
        );
        UI::PopStyleColor();

        UI::NewLine();

        UI::Markdown("You may show this window again at any time from the settings.");

        UI::EndPopup();
    }

    if (!open) {
        UI::CloseCurrentPopup();
        S_Disclaimer = false;
        S_DisclaimerShown = true;
    }
}

void RenderWindow() {
    if (!S_DisclaimerShown) {
        S_Disclaimer = true;
    }

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

    if (UI::BeginTable("##table-players", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("last",    UI::TableColumnFlags::WidthFixed, scale * (S_MedalIcons ? 98.0f : 80.0f));
        UI::TableSetupColumn("best",    UI::TableColumnFlags::WidthFixed, scale * (S_MedalIcons ? 98.0f : 80.0f));
        UI::TableSetupColumn("average", UI::TableColumnFlags::WidthFixed, scale * (S_MedalIcons ? 98.0f : 80.0f));
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

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::BeginDisabled(inRun);
        if (UI::Button(Icons::Plus)) {
            AddPlayer("p" + (players.Length + 1));
        }
        UI::EndDisabled();

        UI::PopStyleColor();
        UI::EndTable();
    }
}
