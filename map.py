map = {
    0: {
        "n": 10,
        "s": "?",
        "e": "?",
        "w": "?",
        "coord": (60, 60)
    },
    10: {
        "n": 19,
        "s": 0,
        "e": None,
        "w": "?",
        "coord": (60, 61)
    },
    19: {
        "n": "?",
        "s": 10,
        "e": None,
        "w": "?",
        "coord": (60, 62)
    }
}

status = {
    "name": "player5",
    "cooldown": 12,
    "encumbrance": 0,
    "strength": 10,
    "speed": 10,
    "gold": 0,
    "inventory": [],
    "status": [],
    "errors": [],
    "messages": []
}

# 1:30 pm
move_north = {
    "room_id": 10,
    "title": "Darkness",
    "description": "It is too dark to see anything.",
    "coordinates": "(60,61)",
    "players": [
        "ghost"
    ],
    "items": [],
    "exits": [
        "n",
        "s",
        "w"
    ],
    "cooldown": 60,
    "errors": [],
    "messages": [
        "You have walked north."
    ]
}

move_north = {
    "room_id": 19,
    "title": "Darkness",
    "description": "It is too dark to see anything.",
    "coordinates": "(60,62)",
    "players": [
        "ghost"
    ],
    "items": [],
    "exits": [
        "n",
        "s",
        "w"
    ],
    "cooldown": 60,
    "errors": [],
    "messages": [
        "You have walked north."
    ]
}

# 1:59
status = {"room_id": 10,
"title": "Darkness",
"description": "It is too dark to see anything.",
"coordinates": "(60,61)",
"players": ["ghost"],
"items": [],
"exits": ["n", "s", "w"],
"cooldown": 30.0,
"errors": [],
"messages": ["You have walked south.", "Wise Explorer: -50% CD"]
}
