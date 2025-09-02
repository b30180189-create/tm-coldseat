// c 2025-09-02
// m 2025-09-02

bool InMap() {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.Editor is null
        and App.RootMap !is null
        and cast<CSmArenaClient>(App.CurrentPlayground) !is null
    ;
}
