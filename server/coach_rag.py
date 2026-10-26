import re

STOP_WORDS = {
    "the", "and", "for", "are", "you", "your", "how", "what", "does", "can",
    "should", "with", "that", "this", "about", "from", "per", "day", "much",
    "many", "when", "why", "who", "not", "but", "have", "has", "was", "were",
}


def words(text):
    found = set()
    for w in re.findall(r"[a-z]+", text.lower()):
        if len(w) <= 2 or w in STOP_WORDS:
            continue
        if w.endswith("s") and len(w) > 3:
            w = w[:-1]
        found.add(w)
    return found


def load_notes(path="coach_notes.txt"):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    return [n.strip() for n in text.split("\n\n") if n.strip()]


def find_notes(question, notes, top=2):
    q_words = words(question)
    scored = []
    for note in notes:
        scored.append((len(q_words & words(note)), note))
    scored.sort(key=lambda pair: pair[0], reverse=True)
    return [note for score, note in scored[:top] if score > 0]


if __name__ == "__main__":
    notes = load_notes()
    print("Loaded", len(notes), "notes")
    for q in [
        "How much protein should I eat?",
        "How long should I rest between sets?",
        "Who won the football world cup?",
    ]:
        print()
        print("Q:", q)
        for n in find_notes(q, notes):
            print("  ->", n[:70])
        print("  (nothing found)" if not find_notes(q, notes) else "")