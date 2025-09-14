// c 2025-09-02
// m 2025-09-13

enum Mode {
    Forever,
    Limited,
    Redemption
}

bool inRun = false;

namespace Limited {
    uint roundsLeft = 0;

    void Start() {
        index      = 0;
        inRun      = true;
        roundsLeft = S_Rounds;

        ClearPlayerTimes();
    }

    void Stop() {
        inRun = false;
    }
}

namespace Redemption {
    uint round = 1;

    bool InRun() {
        return true
            and inRun
            and S_Mode == Mode::Redemption
        ;
    }

    void Start() {
        index = 0;
        inRun = true;
        round = 1;

        ClearPlayerTimes();
    }

    void Stop() {
        inRun = false;
    }
}
