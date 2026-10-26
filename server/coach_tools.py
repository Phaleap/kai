import json
import os
import re
from datetime import datetime

from coach_rag import find_notes, load_notes

DATA_FILE = "coach_data.json"
SYSTEM_PROMPT = (
    "You are a friendly, concise fitness coach. The user trains 5 days a week plus "
    "one run and wants to build muscle and get leaner. Give practical training and "
    "food basics. Never diagnose injuries or give medical advice; for pain, suggest "
    "seeing a doctor. Never criticise someone's body, and never present guesses "
    "about body fat as fact. You have tools: call get_workouts before planning a "
    "week, call save_plan when the user agrees to a plan, and call log_workout "
    "when the user tells you what they trained. For questions about training, "
    "nutrition or recovery, call search_notes first and answer from the notes it "
    "returns, and say which note you used. If it finds nothing, say you don't have "
    "that in your notes and keep any general advice short and cautious. "
    "The end of this message shows the user's saved profile. If a fact that would "
    "change your advice is missing (goal, days, equipment, injuries, level), ask "
    "for it, one or two questions at a time, and call save_profile when they "
    "answer. If an injury was noted a while ago, ask if it still bothers them "
    "before choosing exercises for that area. When you suggest weights, call "
    "suggest_progression and use its numbers exactly. Only state facts that come "
    "from your tools or the profile. If a date or detail is missing, say you don't know. "
    "For any question about the saved plan or its date, call get_workouts first."
)


def load_data():
    data = {"plan": "", "plan_saved": "", "workouts": [], "profile": {}}
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            data.update(json.load(f))
    return data

PROFILE_FIELDS = ["goal", "days_per_week", "equipment", "injuries", "level"]


def save_profile(field: str, value: str) -> str:
    field = field.strip().lower()
    value = value.strip()
    if field not in PROFILE_FIELDS:
        return f"Refused: field must be one of {PROFILE_FIELDS}."
    if not value or len(value) > 300:
        return "Refused: value must be between 1 and 300 characters."
    if looks_like_injection(value):
        return "Refused: that text looks like instructions, not a profile fact."
    data = load_data()
    data["profile"][field] = {"value": value, "updated": datetime.now().strftime("%Y-%m-%d")}
    save_data(data)
    return f"Profile updated: {field}."


def profile_text() -> str:
    profile = load_data()["profile"]
    if not profile:
        return "No profile saved yet."
    return "\n".join(f"- {name}: {item['value']} (noted {item['updated']})" for name, item in profile.items())


def build_system_prompt() -> str:
    today = datetime.now().strftime("%Y-%m-%d")
    return SYSTEM_PROMPT + f"\n\nToday's date: {today}\n\nUser profile:\n" + profile_text()



def save_data(data):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

INJECTION_PATTERN = re.compile(
    r"ignore (all |your |previous |the )*(rules|instructions)|system prompt|you are now",
    re.IGNORECASE,
)


def looks_like_injection(text):
    return bool(INJECTION_PATTERN.search(text))


def has_extreme_calories(text):
    for number in re.findall(r"(\d{3,4})\s*(?:kcal|calories|cal)\b", text.lower()):
        if int(number) < 1200:
            return True
    return False

def save_plan(plan: str) -> str:
    plan = plan.strip()
    if len(plan) < 30:
        return "Refused: the plan is too short to be a real weekly plan. Ask the user for more detail."
    if len(plan) > 5000:
        return "Refused: the plan is too long. Make it shorter."
    if looks_like_injection(plan):
        return "Refused: that text looks like instructions, not a plan."
    if has_extreme_calories(plan):
        return "Refused: the plan has an unsafe calorie level (under 1200). Suggest a doctor or dietitian."
    data = load_data()
    data["plan"] = plan
    data["plan_saved"] = datetime.now().strftime("%Y-%m-%d")
    save_data(data)
    return "Plan saved."


def log_workout(workout: str) -> str:
    workout = workout.strip()
    if len(workout) < 5:
        return "Refused: no workout details. Ask the user what they did."
    if len(workout) > 500:
        return "Refused: the workout text is too long."
    if looks_like_injection(workout):
        return "Refused: that text looks like instructions, not a workout."
    for number, unit in re.findall(r"(\d+(?:\.\d+)?)\s*(kg|lbs|lb)\b", workout.lower()):
        kilos = float(number) * 0.4536 if unit.startswith("lb") else float(number)
        if kilos > 400:
            return f"Refused: {number} {unit} is not a realistic weight. Ask the user to confirm."
    data = load_data()
    data["workouts"].append({"date": datetime.now().strftime("%Y-%m-%d"), "workout": workout})
    save_data(data)
    return "Workout logged."


def get_workouts() -> str:
    data = load_data()
    return json.dumps({"plan": data["plan"], "plan_saved": data["plan_saved"], "last_workouts": data["workouts"][-10:]})

TARGET_REPS = 8
STEP_KG = 2.5


def parse_session(text):
    text = text.lower()
    weight = re.search(r"(\d+(?:\.\d+)?)\s*(kg|lbs|lb)\b", text)
    if not weight:
        return None
    kilos = float(weight.group(1))
    if weight.group(2).startswith("lb"):
        kilos = kilos * 0.4536
    both = re.search(r"(\d+)\s*x\s*(\d+)", text)
    if both:
        sets, reps = int(both.group(1)), int(both.group(2))
    else:
        reps_found = re.search(r"(\d+)\s*reps", text)
        sets_found = re.search(r"(\d+)\s*sets", text)
        if not reps_found or not sets_found:
            return None
        reps, sets = int(reps_found.group(1)), int(sets_found.group(1))
    return {"kg": round(kilos, 1), "sets": sets, "reps": reps}


def suggest_progression(exercise: str) -> str:
    exercise = exercise.strip().lower()
    if not exercise:
        return "Refused: no exercise name. Ask the user which exercise."
    for entry in reversed(load_data()["workouts"]):
        for part in re.split(r"[,;\n]", entry["workout"]):
            if exercise not in part.lower():
                continue
            session = parse_session(part)
            if session is None:
                continue
            last = f"{session['kg']} kg, {session['sets']} sets of {session['reps']} (on {entry['date']})"
            if session["reps"] >= TARGET_REPS:
                new_kg = session["kg"] + STEP_KG
                return f"Last time: {last}. Suggestion: {new_kg} kg, aim for {TARGET_REPS} reps per set."
            return f"Last time: {last}. Suggestion: keep {session['kg']} kg and aim for {session['reps'] + 1} reps per set."
    return "No logged sets with a weight for that exercise. Ask the user to log it first."


def search_notes(question: str) -> str:
    found = find_notes(question, load_notes())
    if not found:
        return "No matching notes found. Tell the user you don't have that in your notes."
    return "\n\n".join(found)


def make_tool(name, description, properties=None, required=None):
    parameters = {"type": "object", "properties": properties or {}}
    if required:
        parameters["required"] = required
    return {
        "type": "function",
        "function": {"name": name, "description": description, "parameters": parameters},
    }


TOOL_FUNCTIONS = {
    "save_plan": save_plan,
    "log_workout": log_workout,
    "get_workouts": get_workouts,
    "search_notes": search_notes,
    "save_profile": save_profile,
    "suggest_progression": suggest_progression,
}

TOOLS = [
    make_tool(
        "save_plan",
        "Save the user's weekly training plan, replacing the old one.",
        {"plan": {"type": "string", "description": "The full weekly plan as text"}},
        ["plan"],
    ),
    make_tool(
        "log_workout",
        "Record a workout the user did today.",
        {"workout": {"type": "string", "description": "What they trained, with sets/reps/weights if known"}},
        ["workout"],
    ),
    make_tool("get_workouts", "Get the saved plan and the user's last 10 logged workouts."),
    make_tool(
        "search_notes",
        "Search the coach's own training and nutrition notes. Use it before answering questions about training, food, recovery or pain.",
        {"question": {"type": "string", "description": "The user's question in plain words"}},
        ["question"],
    ),
        make_tool(
        "save_profile",
        "Save one fact about the user (goal, days_per_week, equipment, injuries or level). Call it when the user tells you one of these.",
        {
            "field": {"type": "string", "description": "One of: goal, days_per_week, equipment, injuries, level"},
            "value": {"type": "string", "description": "What the user said, in short plain words"},
        },
        ["field", "value"],
    ),
        make_tool(
        "suggest_progression",
        "Get the next weight and reps to try for one exercise, calculated from the user's last logged session. Use it whenever you suggest weights.",
        {"exercise": {"type": "string", "description": "Exercise name, for example bench press"}},
        ["exercise"],
    ),
]