# dial_az

High-precision 0° to 360° Azimuth Degree Dial & Navigation Reader written in Qt 6 Quick (QML) and C++.

## Features
- **0° to 360° Degree Dial Reader**: Vector rendered dial scale with major ticks, minor ticks, and 4 primary cardinal points highlighted: **N (0°)**, **E (90°)**, **S (180°)**, and **W (270°)**.
- **Ethernet UDP Receiver Backend**: Background `NetworkReceiver` C++ socket class listening on UDP Port 5000 for incoming azimuth degree packets (JSON, CSV text, or binary float payloads).
- **Interactive Pointer Needle & Target Bug**: Touch/drag interaction, animated vector needle, target bearing bug marker, and glassmorphic HUD digital readout.

## Project Structure
```text
HMI_Design/
├── qml/
│   ├── AzimuthDial.qml   # Reusable Azimuth Dial component
│   └── Main.qml          # Full-screen HMI display
├── networkreceiver.h     # UDP Ethernet Receiver C++ header
├── networkreceiver.cpp   # UDP Ethernet Receiver C++ source
├── CMakeLists.txt        # CMake build configuration
└── main.cpp              # Application entry point
```

## Build Instructions
```bash
cmake -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:/Qt/6.8.3/mingw_64"
cmake --build build
./build/appHMI_Design.exe
```
