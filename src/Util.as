// c 2025-09-02
// m 2025-09-13

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
