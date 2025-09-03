// c 2025-09-02
// m 2025-09-03

enum Mode {
    Forever,
    Limited
}

bool inLimitedRun = false;
uint roundsLeft   = 0;

void StartLimitedRun() {
    index        = 0;
    inLimitedRun = true;
    roundsLeft   = S_Rounds;

    ClearPlayerTimes();
}

void StopLimitedRun(const bool finished = false) {
    ;

    inLimitedRun = false;
}
