# Signetics 2650 Ghidra Extension

This repository packages the Signetics 2650 processor language as a standard Ghidra extension project.

## Layout

- `extension.properties` and `Module.manifest` live at the project root.
- Language definition files live under `data/languages/`.
- Release archives are written to `dist/` using a standard Ghidra-style filename.

## Build

For a normal Ghidra installation:

```bash
export GHIDRA_INSTALL_DIR=/path/to/ghidra
gradle buildExtension
```

For Flatpak Ghidra, or when you want a simple wrapper that also compiles the SLEIGH spec:

```bash
./build.sh
```

The release archive will be created in `dist/` as:

```text
ghidra_<version>_PUBLIC_Signetics2650.zip
```

## Install

In Ghidra, open `File -> Install Extensions...`, click the green plus button, and select the zip file from `dist/`.