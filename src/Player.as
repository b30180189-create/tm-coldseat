Player@      bestAverage;
Player@      bestBest;
Player@      bestLast;
const string blankTime = "\u2212:\u2212\u2212.\u2212\u2212\u2212";
const vec4   colorElim = vec4(0.7f, 0.0f, 0.0f, 1.0f);
uint         index     = 0;
Player@[]    players;

class Player {
    uint   average     = uint(-1);
    uint   best        = uint(-1);
    bool   dormant     = false;
    bool   editingName = false;
    bool   eliminated  = false;
    string name;
    uint[] times;

    uint get_last() {
        return times.Length > 0 ? times[times.Length - 1] : uint(-1);
    }

    bool get_skip() {
        return false
            or dormant
            or eliminated
        ;
    }

    Player(const string&in name) {
        this.name = name;
    }

    bool AddTime(const int time) {
        if (time <= 0) {
            return true;
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

        if (Redemption::InRun()) {
            bool shouldEliminate = true;

            if (true
                and Redemption::round == 1
                and index == 0
            ) {
                dormant = true;
                return true;
            }

            for (uint i = 0; i < players.Length; i++) {
                if (false
                    or players[i] is this
                    or players[i].eliminated
                ) {
                    continue;
                }

                if (true
                    and players[i].best != uint(-1)
                    and best < players[i].best
                ) {
                    dormant            = true;
                    players[i].dormant = false;
                    shouldEliminate    = false;
                    print("player '" + name + "' overtook player '" + players[i].name + "'");
                }
            }

            if (true
                and Redemption::round > 1
                and shouldEliminate
            ) {
                trace("player '" + name + "' eliminated");
                eliminated = true;

                Player@ newWorst;
                for (uint i = 0; i < players.Length; i++) {
                    if (true
                        and !players[i].eliminated
                        and (false
                            or newWorst is null
                            or players[i].best > newWorst.best
                        )
                    ) {
                        if (newWorst is null) {
                            trace("new worst is null, setting to player '" + players[i].name + "'");
                        } else {
                            trace("player '" + players[i].name + "' has a worse time than player '" + newWorst.name + "'");
                        }
                        @newWorst = players[i];
                    }
                }
                if (newWorst !is null) {
                    newWorst.dormant = false;
                } else {
                    warn("didn't find new worst player");
                }
            }

            uint elimCount = 0;
            Player@ alive;

            for (uint i = 0; i < players.Length; i++) {
                if (players[i].eliminated) {
                    elimCount++;
                } else {
                    @alive = players[i];
                }
            }

            if (elimCount == players.Length - 1) {
                Redemption::Stop();
                const string msg = "Player '" + alive.name + "' is the winner!";
                print(msg);
                UI::ShowNotification(pluginTitle, msg, vec4(0.0f, 0.8f, 0.0f, 0.8f));
                return false;
            }
        }

        return true;
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
            RenderRowText(name);
        }

        UI::TableNextColumn();
        if (this is bestLast) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        RenderRowText(times.Length > 0
            ? GetMedalIcon(last) + "\\$G " + Time::Format(last)
            : GetMedalIcon(0) + "\\$G " + blankTime
        );
        if (this is bestLast) {
            UI::PopFont();
        }

        UI::TableNextColumn();
        if (this is bestBest) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        RenderRowText(times.Length > 0
            ? GetMedalIcon(best) + "\\$G " + Time::Format(best)
            : GetMedalIcon(0) + "\\$G " + blankTime
        );
        if (this is bestBest) {
            UI::PopFont();
        }

        UI::TableNextColumn();
        if (this is bestAverage) {
            UI::PushFont(UI::Font::DefaultBold);
        }
        RenderRowText(times.Length > 0
            ? GetMedalIcon(average) + "\\$G " + Time::Format(average)
            : GetMedalIcon(0) + "\\$G " + blankTime
        );
        if (this is bestAverage) {
            UI::PopFont();
        }

        UI::TableNextColumn();

        UI::BeginDisabled(inRun);

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

        UI::BeginDisabled(inRun);

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
                    or inRun
                )
            ),
            UI::SelectableFlags::SpanAllColumns
        );
        UI::EndDisabled();

        UI::PopID();

        return good;
    }

    void RenderRowText(const string&in text) {
        UI::AlignTextToFramePadding();

        if (dormant) {
            UI::TextDisabled(text);
        } else if (eliminated) {
            UI::PushStyleColor(UI::Col::Text, colorElim);
            UI::Text(text);
            UI::PopStyleColor();
        } else {
            UI::Text(text);
        }
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
        players[i].dormant    = false;
        players[i].eliminated = false;
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

void Increment(const uint start = 0) {
    if (start > players.Length) {
        error("too many increments");
        return;
    }

    if (index < players.Length - 1) {
        index++;
    } else {
        index = 0;

        if (Redemption::InRun()) {
            Redemption::round++;
        }
    }

    if (Redemption::InRun()) {
        if (players[index].skip) {
            Player@ last;
            uint remaining = 0;

            for (uint i = 0; i < players.Length; i++) {
                if (!players[i].skip) {
                    remaining++;
                    @last = players[i];
                }
            }

            if (false
                or players[index].skip
                or remaining > 1
            ) {
                Increment(start + 1);
            } else {
                if (last !is null) {
                    trace("last player is '" + last.name + "'");
                }
                Redemption::Stop();
            }

        } else {
            trace("player '" + players[index].name + "' is now active");
        }
    }
}
