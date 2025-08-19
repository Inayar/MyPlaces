## SwiftUI + Combine Notes App (Client) and FastAPI (Server)

This repository contains:

- iOS client (SwiftUI + Combine) for managing text notes
- Simple REST server (FastAPI) that persists notes to a local JSON file

### 1) Run the server

Requirements: Python 3.9+

```
cd server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

The server exposes:

- GET `http://127.0.0.1:8000/notes`
- POST `http://127.0.0.1:8000/notes` {"text": "..."}
- PUT `http://127.0.0.1:8000/notes/{id}` {"text": "..."}
- DELETE `http://127.0.0.1:8000/notes/{id}`

Notes are stored in `server/notes.json`.

### 2) Open the iOS app in Xcode

This repo includes Swift source files ready to be added to a new Xcode iOS project.

Steps:

1. Open Xcode and create a new project: iOS > App, Interface: SwiftUI, Language: Swift.
2. In the Project Navigator, create folders to mirror `iOS/NotesApp` structure:
   - `Models`, `API`, `Store`, `Views`, `Utilities`, `Config`
3. Drag & drop all Swift files from `iOS/NotesApp` into your Xcode project (copy items if needed).
4. Replace the auto-generated `App` file with `NotesAppApp.swift`.
5. Build & run on Simulator.

Configuration:

- Base API URL is defined in `Config/AppConfig.swift`. Default is `http://127.0.0.1:8000` which works from the Simulator on the same Mac.
- If running on a real device, ensure your device can reach your machine over the network and replace the host with your computer's LAN IP (e.g., `http://192.168.1.10:8000`).

### 3) Features

- List notes, create new notes, edit existing notes, delete notes
- Combine-based networking with `URLSession`
- Codable models and ISO8601 date handling

### 4) Endpoints Contract

Model (JSON):

```
{
  "id": "UUID",
  "text": "string",
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

### 5) Troubleshooting

- If decoding errors occur, confirm the server is running and the `baseURL` matches your environment.
- For device testing, replace `127.0.0.1` with your Mac's IP, and ensure firewall allows inbound connections to the Python server.

