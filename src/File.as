// c 2025-09-02
// m 2025-09-02

namespace File {
    const string file = IO::FromStorageFolder("data.json");

    void Load() {
        Json::Value@ json;

        try {
            @json = Json::FromFile(file);
        } catch {
            error("error loading json file: " + getExceptionInfo());
            return;
        }

        if (json.GetType() != Json::Type::Array) {
            error("wrong json type: " + Json::Write(json));
            return;
        }

        ClearPlayers();

        for (uint i = 0; i < json.Length; i++) {
            try {
                AddPlayer(string(json[i]));
            } catch {
                error("error adding player from file: " + getExceptionInfo());
            }
        }
    }

    void Save() {
        Json::Value@ json = Json::Array();

        for (uint i = 0; i < players.Length; i++) {
            json.Add(players[i].name);
        }

        try {
            Json::ToFile(file, json);
        } catch {
            error("error saving file: " + getExceptionInfo());
        }
    }
}
