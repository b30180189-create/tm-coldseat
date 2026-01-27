const vec3 colorChampion = vec3(1.0f,   0.267f, 0.467f);
const vec3 colorAuthor   = vec3(0.0f,   0.471f, 0.035f);
const vec3 colorGold     = vec3(0.871f, 0.737f, 0.259f);
const vec3 colorSilver   = vec3(0.537f, 0.604f, 0.604f);
const vec3 colorBronze   = vec3(0.604f, 0.4f,   0.259f);

vec3 GetMedalColor(const uint time) {
    if (false
        or int(time) <= 0
        or !InMap()
    ) {
        return vec3();
    }

#if DEPENDENCY_CHAMPIONMEDALS
    const uint cm = ChampionMedals::GetCMTime();
#endif

#if DEPENDENCY_WARRIORMEDALS
    const uint wm = WarriorMedals::GetWMTime();
#endif

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
    if (cm <= wm) {
        if (time <= cm) {
            return colorChampion;
        }

        if (time <= wm) {
            return WarriorMedals::GetColorWarriorVec();
        }

    } else {
        if (time <= wm) {
            return WarriorMedals::GetColorWarriorVec();
        }

        if (time <= cm) {
            return colorChampion;
        }
    }

#elif DEPENDENCY_CHAMPIONMEDALS
    if (time <= cm) {
        return colorChampion;
    }

#elif DEPENDENCY_WARRIORMEDALS
    if (time <= wm) {
        return WarriorMedals::GetColorWarriorVec();
    }
#endif

    CGameCtnChallenge@ Map = GetApp().RootMap;

    if (time <= Map.TMObjective_AuthorTime) {
        return colorAuthor;
    }

    if (time <= Map.TMObjective_GoldTime) {
        return colorGold;
    }

    if (time <= Map.TMObjective_SilverTime) {
        return colorSilver;
    }

    if (time <= Map.TMObjective_BronzeTime) {
        return colorBronze;
    }

    return vec3();
}

string GetMedalIcon(const uint time) {
    return S_MedalIcons
        ? Text::FormatOpenplanetColor(GetMedalColor(time)) + Icons::Circle
        : ""
    ;
}

bool InMap() {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.Editor is null
        and App.RootMap !is null
        and cast<CSmArenaClient>(App.CurrentPlayground) !is null
    ;
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
