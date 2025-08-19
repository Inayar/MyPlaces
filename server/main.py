from __future__ import annotations

import json
import uuid
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


DATA_FILE = Path(__file__).parent / "notes.json"


def now_iso() -> str:
    # Use second precision to improve cross-platform ISO8601 parsing compatibility
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


@dataclass
class Note:
    id: str
    text: str
    createdAt: str
    updatedAt: str


class NoteCreate(BaseModel):
    text: str


class NoteUpdate(BaseModel):
    text: str


def load_all() -> List[Note]:
    if not DATA_FILE.exists():
        return []
    try:
        with DATA_FILE.open("r", encoding="utf-8") as f:
            raw = json.load(f)
        notes = [Note(**item) for item in raw]
        return notes
    except Exception:
        return []


def save_all(notes: List[Note]) -> None:
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    with DATA_FILE.open("w", encoding="utf-8") as f:
        json.dump([asdict(n) for n in notes], f, ensure_ascii=False, indent=2)


app = FastAPI(title="Notes API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/notes")
def list_notes() -> List[Note]:
    return load_all()


@app.post("/notes", status_code=201)
def create_note(payload: NoteCreate) -> Note:
    notes = load_all()
    note = Note(id=str(uuid.uuid4()), text=payload.text, createdAt=now_iso(), updatedAt=now_iso())
    notes.append(note)
    save_all(notes)
    return note


@app.put("/notes/{note_id}")
def update_note(note_id: str, payload: NoteUpdate) -> Note:
    notes = load_all()
    for n in notes:
        if n.id == note_id:
            n.text = payload.text
            n.updatedAt = now_iso()
            save_all(notes)
            return n
    raise HTTPException(status_code=404, detail="Note not found")


@app.delete("/notes/{note_id}", status_code=204, response_class=Response)
def delete_note(note_id: str) -> Response:
    notes = load_all()
    new_notes = [n for n in notes if n.id != note_id]
    if len(new_notes) == len(notes):
        raise HTTPException(status_code=404, detail="Note not found")
    save_all(new_notes)
    return Response(status_code=204)

