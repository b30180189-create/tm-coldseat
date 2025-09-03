// c 2025-09-02
// m 2025-09-03

Player@      bestAverage;
Player@      bestBest;
Player@      bestLast;
const string blankTime = "\u2212:\u2212\u2212.\u2212\u2212\u2212";
uint         index     = 0;
Player@[]    players;

class Player {
    uint   average     = uint(-1);
    uint   best        = uint(-1);
    bool   editingName = false;
    string name;
    uint[] times;

    uint get_last() {
        return times.Length > 0 ? times[times.Length - 1] : uint(-1);
    }

    Player(const string&in name) {
        this.name = name;
    }

    void AddTime(const int time) {
        if (time <= 0) {
            return;
        }

        times.InsertLast(uint(time));

        if (uint(time) < best) {
            best = time;
        }

        uint64 total = 0;
        for (uint i = 0; i < times.Length; i++) {
            total += times[i];
        }
        average = total / times.Length;

        if (false
            or bestAverage is null
            or average < bestAverage.average
        ) {
            @bestAverage = this;

        } else if (this is bestAverage) {
            @bestAverage = null;

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or bestAverage is null
                    or players[i].average < bestAverage.average
                ) {
                    @bestAverage = players[i];
                }
            }
        }

        if (false
            or bestBest is null
            or best < bestBest.best
        ) {
            @bestBest = this;
        }

        if (false
            or bestLast is null
            or last < bestLast.last
        ) {
            @bestLast = this;

        } else if (this is bestLast) {
            @bestLast = null;

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or bestLast is null
                    or players[i].last < bestLast.last
                ) {
                    @bestLast = players[i];
                }
            }
        }
    }

    void ClearTimes(const bool clearAll = false) {
        average = uint(-1);
        best    = uint(-1);
        times   = {};

        if (clearAll) {
            return;
        }

        if (this is bestAverage) {
            @bestAverage = null;

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or bestAverage is null
                    or players[i].average < bestAverage.average
                ) {
                    @bestAverage = players[i];
                }
            }
        }

        if (this is bestBest) {
            @bestBest = null;

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or bestBest is null
                    or players[i].best < bestBest.best
                ) {
                    @bestBest = players[i];
                }
            }
        }

        if (this is bestLast) {
            @bestLast = null;

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or bestLast is null
                    or players[i].last < bestLast.last
                ) {
                    @bestLast = players[i];
                }
            }
        }
    }

    bool RenderRow(const uint i) {
        UI::PushID(i);

        UI::TableNextRow();

        // UI::TableNextColumn();
        // UI::AlignTextToFramePadding();
        // UI::Text(tostring(i));

        UI::TableNextColumn();
        bool changed;
        if (editingName) {
            name = UI::InputText("##name", name, changed, UI::InputTextFlags::EnterReturnsTrue);
            if (changed) {
                editingName = false;
            }
        } else {
            UI::AlignTextToFramePadding();
            UI::Text(name);
        }

        UI::TableNextColumn();
        if (this is bestLast) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        UI::AlignTextToFramePadding();
        UI::Text(times.Length > 0
            ? Time::Format(last)
            : blankTime
        );
        if (this is bestLast) {
            UI::PopFont();
        }

        UI::TableNextColumn();
        if (this is bestBest) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        UI::AlignTextToFramePadding();
        UI::Text(times.Length > 0
            ? Time::Format(best)
            : blankTime
        );
        if (this is bestBest) {
            UI::PopFont();
        }

        UI::TableNextColumn();
        if (this is bestAverage) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        UI::AlignTextToFramePadding();
        UI::Text(times.Length > 0
            ? Time::Format(average)
            : blankTime
        );
        if (this is bestAverage) {
            UI::PopFont();
        }

        UI::TableNextColumn();

        UI::BeginDisabled(inLimitedRun);

        UI::BeginDisabled(i == 0);
        if (UI::Button(Icons::ArrowUp)) {
            players.RemoveAt(i);
            players.InsertAt(i - 1, this);

            if (S_Mode != Mode::Limited) {
                if (i == index) {
                    Decrement();
                } else if (i - 1 == index) {
                    Increment();
                }
            }

            File::Save();
        }
        UI::EndDisabled();
        UI::SetItemTooltip("Move Up");

        UI::SameLine();
        UI::BeginDisabled(i == players.Length - 1);
        if (UI::Button(Icons::ArrowDown)) {
            players.RemoveAt(i);
            players.InsertAt(i + 1, this);

            if (S_Mode != Mode::Limited) {
                if (i == index) {
                    Increment();
                } else if (i + 1 == index) {
                    Decrement();
                }
            }

            File::Save();
        }
        UI::EndDisabled();
        UI::SetItemTooltip("Move Down");

        UI::EndDisabled();

        UI::SameLine();
        if (UI::Button(Icons::Pencil)) {
            editingName = !editingName;
        }
        UI::SetItemTooltip("Edit Name");

        UI::BeginDisabled(inLimitedRun);

        UI::SameLine();
        UI::BeginDisabled(times.Length == 0);
        if (UI::Button(Icons::Times)) {
            ClearTimes();
        }
        UI::EndDisabled();
        UI::SetItemTooltip("Clear Times");

        bool good = true;

        UI::SameLine();
        if (UI::Button(Icons::TrashO)) {
            ClearTimes();
            good = false;
        }
        UI::SetItemTooltip("Remove Player");

        UI::EndDisabled();

        UI::SameLine();
        UI::BeginDisabled();
        UI::Selectable(
            "##select",
            (true
                and i == index
                and (false
                    or S_Mode != Mode::Limited
                    or inLimitedRun
                )
            ),
            UI::SelectableFlags::SpanAllColumns
        );
        UI::EndDisabled();

        UI::PopID();

        return good;
    }
}

void AddPlayer(const string&in name, const bool fromFile = false) {
    players.InsertLast(Player(name));

    if (!fromFile) {
        File::Save();
    }
}

void ClearPlayers() {
    trace("clearing players");

    index        = 0;
    players      = {};
    @bestAverage = null;
    @bestBest    = null;
    @bestLast    = null;
}

void ClearPlayerTimes() {
    trace("clearing all players' times");

    for (uint i = 0; i < players.Length; i++) {
        players[i].ClearTimes(true);
    }

    @bestAverage = null;
    @bestBest    = null;
    @bestLast    = null;
}

void Decrement() {
    if (index > 0) {
        index--;
    } else {
        index = players.Length - 1;
    }
}

void Increment() {
    if (index < players.Length - 1) {
        index++;
    } else {
        index = 0;
    }
}
