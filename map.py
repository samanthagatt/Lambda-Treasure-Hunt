map = {
    0: {
        "n": 10,
        "s": "?",
        "e": "?",
        "w": "?",
        "coord": (60, 60)
    },
    1: {
        "e": 0
    },
    10: {
        "n": 19,
        "s": 0,
        "e": None,
        "w": 43,
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

room_1 = {
    "room_id": 1,
    "title": "Darkness",
    "description": "It is too dark to see anything.",
    "coordinates": "(59,60)",
    "exits": [
        "e"
    ],
    "cooldown": 10,
    "errors": [],
    "messages": [
        "You have walked west.",
        "Wise Explorer: -50% CD"
    ]
}

path = ["s", "s", "w", "n", "w", "n", "w", "n", "n", "s", "w", "e", "s", "w", "w", "w", "w", "e", "e", "e", "e", "e", "s", "w", "w", "e", "e", "e", "s", "w", "w", "w", "e", "e", "e", "e", "n", "e", "s", "s", "w", "w", "s", "s", "w", "s", "n", "w", "w", "s", "n", "w", "s", "s", "s", "s", "s", "w", "s", "n", "w", "e", "e", "e", "s", "n", "w", "s", "s", "n", "n", "n", "n", "e", "w", "n", "w", "s", "s", "w", "e", "n", "w", "n", "w", "s", "n", "w", "e", "e", "s", "e", "n", "e", "n", "n", "w", "s", "w", "e", "n", "w", "w", "s", "w", "w", "e", "e", "n", "w", "w", "e", "e", "e", "e", "e", "e", "e", "n", "w", "w", "w", "n", "n", "n", "s", "s", "s", "w", "n", "n", "n", "s", "s", "w", "n", "n", "n", "s", "w", "e", "s", "w", "w", "e", "e", "s", "w", "e", "e", "s", "w", "w", "e", "e", "e", "e", "e", "e", "s", "s", "s", "e", "s", "w", "s", "s", "n", "w", "e", "n", "e", "n", "w", "w", "e", "n", "n", "e", "e", "n", "n", "w", "s", "n", "w", "w", "w", "n", "n", "s", "s", "e", "e", "e", "e", "e", "e", "e", "s", "s", "s", "s", "n", "n", "n", "e", "s", "s", "e", "s", "s", "s", "n", "e", "s", "s", "s", "s", "n", "e", "s", "n", "w", "n", "e", "e", "w", "w", "n", "e", "w", "n", "w", "n", "w", "s", "w", "s", "s", "w", "e", "n", "e", "s", "s", "w", "s", "n", "e", "e", "s", "s", "n", "n", "w", "s", "s", "n", "n", "n", "e", "w", "n", "w", "n", "e", "n", "e", "n", "e", "s", "e", "s", "e", "w", "n", "e", "n", "e", "e", "s", "e", "e", "s", "n", "e", "w", "w", "w", "n", "e", "n", "e", "e", "e", "w", "w", "w", "s", "e", "w", "w", "w", "w", "s", "e", "s", "s", "w", "e", "e", "w", "s", "s", "s", "s", "n", "n", "w", "s", "n", "e", "n", "e", "w", "n", "n", "e", "w", "n", "w", "w", "w", "n", "e", "w", "w", "w", "n", "e", "e", "e", "e", "e", "e", "w", "w", "w", "w", "w", "w", "n", "w", "n", "e", "w", "w", "s", "s", "s", "s", "s", "s", "w", "s", "n", "w", "s", "s", "w", "s", "s", "n", "w", "w", "e", "e", "n", "w", "e", "e", "e", "s", "s", "n", "n", "e", "s", "s", "n", "n", "w", "w", "s", "s", "s", "n", "n", "n", "n", "n", "w", "s", "n", "e", "e", "e", "n", "w", "w", "e", "e", "n", "n", "n", "w", "s", "s", "w", "e", "n", "w", "e", "n", "e", "n", "w", "e", "n", "n", "e", "e", "n", "s", "e", "s", "s", "n", "e", "s", "e", "e", "w", "w", "n", "e", "e", "n", "s", "e", "s", "n", "e", "s", "e", "e", "e", "e", "w", "w", "w", "w", "n", "e", "e", "e", "n", "e", "w", "s", "e", "w", "w", "w", "w", "w", "w", "w", "w", "w", "n", "e", "e", "w", "w", "n", "s", "w", "w", "w", "n", "e", "w", "w", "n", "e", "e", "e", "w", "w", "n", "e", "e", "w", "w", "s", "w", "n", "w", "w", "n", "s", "e", "e", "n", "w", "e", "n", "e", "e", "s", "e", "e", "s", "s", "e", "s", "e", "e", "e", "s", "e", "e", "e", "w", "w", "w", "n", "e", "e", "e", "w", "w", "n", "e", "w", "n", "e", "e", "s", "e", "s", "n", "e", "n", "w", "e", "s", "w", "w", "n", "w", "n", "s", "w", "n", "s", "s", "s", "w", "w", "w", "w", "n", "e", "e", "e", "w", "w", "n", "e", "e", "w", "w", "s", "w", "w", "n", "e", "w", "n", "e", "e", "w", "n", "e", "e", "s", "e", "w", "n", "e", "w", "w", "w", "s", "w", "w", "w", "n", "e", "e", "w", "n", "e", "e", "e", "e", "w", "n", "e", "w", "n", "e", "n", "e", "w", "n", "e", "e", "s", "n", "e", "w", "w", "w", "s", "s", "w", "n", "s", "s", "s", "w", "w", "n", "e", "n", "s", "w", "n", "n", "s", "s", "s", "w", "w", "e", "n", "w", "w", "n", "n", "w", "w", "e", "e", "n", "s", "s", "s", "e", "e", "n", "w", "n", "n", "s", "s", "e", "n", "n", "e", "e", "s", "n", "e", "n", "e", "w", "n", "e", "w", "s", "s", "w", "w", "w", "n", "e", "e", "w", "w", "w", "w", "w", "e", "n", "w", "w", "n", "w", "e", "n", "s", "s", "e", "n", "s", "e", "s", "e", "n", "n", "w", "n", "s", "e", "n", "n", "w", "w", "s", "n", "n", "s", "e", "n", "s", "e", "n", "s", "s", "s", "s", "s", "e", "n", "e", "e", "n", "e", "e", "w", "w", "s", "w", "n", "s", "w", "n", "n", "n", "e", "s", "e", "w", "n", "w", "n", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "s", "w", "w", "n", "s", "s", "n", "w", "w", "w", "w", "w", "w", "w", "w", "w", "w", "e", "n", "s", "s", "w", "e", "n", "e", "n", "n", "s", "s", "e", "n", "n", "s", "s", "s", "w", "e", "n", "e", "n", "s", "e", "n", "s", "s", "w", "s", "w", "w", "w", "w", "s", "n", "e", "e", "e", "e", "n", "e", "n", "e", "e", "n", "w", "n", "s", "e", "s", "e", "e", "n", "w", "e", "n", "w", "w", "e", "n", "e", "w", "w", "w", "w", "s", "w", "e", "n", "e", "e", "n", "w", "w", "w", "s", "n", "w", "w", "w", "w", "e", "e", "e", "n", "w", "w", "w", "e", "n", "s", "e", "e", "s", "s", "w", "w", "s", "n", "e", "e", "n", "e", "e", "n", "w", "n", "w", "w", "n", "w", "w", "s", "n", "n", "w", "e", "s", "e", "e", "s", "e", "n", "n", "w", "w", "n", "s", "e", "e", "n", "w", "e", "s", "s", "s", "e", "n", "n", "n", "n", "n", "s", "s", "s", "s", "s", "s", "e", "n", "s", "s", "e", "n", "s", "e", "n", "e", "e", "w", "w", "n", "e", "w", "w", "n", "e", "w", "w", "n", "n", "s", "s", "e", "n", "n", "e", "n", "s", "w", "n"]

print(len(path))
