# Signetics 2650 Ghidra Extension

This repository contains a Ghidra processor extension for the Signetics 2650 processor. It should support disassembly and decompilation semantics.

## Building

If you have a normal Ghidra installation available on disk, the project can be built with Ghidra's standard extension tooling:

```bash
export GHIDRA_INSTALL_DIR=/path/to/ghidra
gradle buildExtension
```

If you are using Flatpak Ghidra, or just want a small wrapper that compiles the SLEIGH spec and creates the release zip, use:

```bash
./build.sh
```

The release archive is written to `dist/` with a Ghidra-style name:

```text
ghidra_<version>_PUBLIC_Signetics2650.zip
```

## Installing

In Ghidra, open `File -> Install Extensions...`, click the green plus button, and select the zip file from `dist/`.

## Reference material

The file `docs/2650UM.guide` is included as reference material for the Signetics 2650 architecture. It is not my original work and should not be treated as part of the source code for this extension. Ownership and any rights associated with that document remain with its original author or publisher.

## License

Except for `docs/2650UM.guide` and any other clearly third-party reference material, the contents of this repository are licensed under the Apache License, Version 2.0, in line with Ghidra's licensing model.