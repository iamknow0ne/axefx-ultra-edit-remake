# NAM dependency

NeuralAmpModelerCore by Steven Atkinson and contributors, MIT licensed:
https://github.com/sdatkinson/NeuralAmpModelerCore

Pinned source revision: `1f42f88535884450104b8711d7595019afa0495b`. This directory includes the NAM source required by the helper and its Eigen/nlohmann dependencies; it is a vendored source snapshot, not a Git submodule. Original file notices are retained. Full distribution notices are in `Resources/ThirdPartyNotices.txt` and the repository's `THIRD_PARTY_NOTICES.md`.

Only the offline helper links this code. The Swift editor launches it as a separate process. NAM files are parsed as data; no model is uploaded to a service. Test NAM networks elsewhere in the repository have synthetic generated weights, not captured tones.
