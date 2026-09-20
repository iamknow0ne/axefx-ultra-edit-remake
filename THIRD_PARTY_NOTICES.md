# Third-party notices and source

Ultra Edit is independent of Fractal Audio Systems. Axe-Fx and Axe-Edit identify the supported hardware/software formats, not endorsement. The interoperability catalog was recovered from the user-supplied Axe-Edit 1.0.191 metadata. The proprietary installer, executable, manuals and factory banks are not distributed here. The UI artwork is original generic illustration.

No open-source license has been selected for original Ultra Edit code. This does not alter any third-party license below.

| Component | Source / revision | License and location |
| --- | --- | --- |
| NeuralAmpModelerCore | [Steven Atkinson and contributors](https://github.com/sdatkinson/NeuralAmpModelerCore), `1f42f88535884450104b8711d7595019afa0495b` | MIT; `Vendor/NeuralAmpModelerCore/LICENSE` |
| Eigen | Bundled source under `Vendor/NeuralAmpModelerCore/Dependencies/eigen`; [upstream](https://eigen.tuxfamily.org/) | MPL-2.0, with file-specific notices and additional COPYING files retained |
| JSON for Modern C++ | [nlohmann/json](https://github.com/nlohmann/json), header version 3.12.0 | MIT; Niels Lohmann, 2013–2025; full text in bundled notices |

**Complete license texts:** [Resources/ThirdPartyNotices.txt](Resources/ThirdPartyNotices.txt), also included inside the app bundle. All vendored source retains per-file notices. This code is used by the local `nam-ir` helper; no NAM captures or trained commercial models are bundled.

Corresponding third-party source is included in this repository's `Vendor/` directory and the release asset `Ultra-Edit-0.4.1-third-party-source.tar.gz`. Recipients of the binaries can obtain that asset from the same release page. Keep this source offering and the license notices with redistributed builds. No Eigen source modifications are introduced by Ultra Edit.

Developer-only packaging dependencies (`ds-store`, `mac-alias`, Python-Markdown) are installed into a local virtual environment and are not shipped inside the application. Their upstream package notices apply to their own distributions.
