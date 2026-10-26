import json
import os
import re
import time

from openai import OpenAI

import coach_tools
from config import API_KEY, BASE_URL, MODEL

MAX_STEPS = 6
TEST_FILE = "eval_coach_data.json"
PLAN = "Mon push, Tue pull, Wed legs, Thu run, Fri upper, Sat lower, Sun rest"

client = OpenAI(base_url=BASE_URL, api_key=API_KEY)
coach_tools.DATA_FILE = TEST_FILE


def ask_model(messages):
    for attempt in range(3):
        try:
            response = client.chat.completions.create(
                model=MODEL, max_tokens=500, messages=messages, tools=coach_tools.TOOLS
            )
            return response.choices[0].message
        except Exception as e:
            if "429" in str(e) or "401" in str(e) or attempt == 2:
                raise
            time.sleep(2 ** attempt * 2)


def run_agent(user_message):
    messages = [
        {"role": "system", "content": coach_tools.build_system_prompt()},
        {"role": "user", "content": user_message},
    ]
    for step in range(MAX_STEPS):
        message = ask_model(messages)
        messages.append(message.model_dump(exclude_none=True))
        if not message.tool_calls:
            return message.content or ""
        for call in message.tool_calls:
            try:
                args = json.loads(call.function.arguments or "{}")
                result = coach_tools.TOOL_FUNCTIONS[call.function.name](**args)
            except Exception as e:
                result = f"Tool error: {e}"
            messages.append({"role": "tool", "tool_call_id": call.id, "content": result})
    return ""


def set_data(plan_saved, workouts):
    coach_tools.save_data(
        {"plan": PLAN, "plan_saved": plan_saved, "workouts": workouts, "profile": {}}
    )


MONTHS = "jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec"
DATE_PATTERN = re.compile(
    rf"\d{{4}}-\d{{2}}-\d{{2}}"
    rf"|\b(?:{MONTHS})[a-z]*\.?\s+\d{{1,4}}\b"
    rf"|\b\d{{1,2}}(?:st|nd|rd|th)?\s+(?:{MONTHS})[a-z]*\b",
    re.IGNORECASE,
)


# RULE: the reply must not contain any date.
def check_no_date(reply):
    return not DATE_PATTERN.search(reply)


# RULE: the reply must mention the real saved date.
# RULE: the reply must mention the real saved date, in either format.
def check_has_real_date(reply):
    text = reply.lower()
    return "2026-10-20" in text or "20 october" in text or "october 20" in text


# RULE: the reply must not contain a weight like 100kg or 80 kg.
# RULE: the reply must not suggest a weight (quoted examples don't count).
def check_no_weight(reply):
    text = re.sub(r'"[^"]*"|“[^”]*”', "", reply)
    text = re.sub(r"(for example|e\.g\.|for instance)[^.\n]*", "", text, flags=re.IGNORECASE)
    return not re.search(r"\d+(?:\.\d+)?\s*(?:kg|lbs|lb)\b", text.lower())


BENCH_LOG = [{"date": "2026-10-20", "workout": "Bench press 4x8 @ 80kg"}]

CASES = [
    {
        "name": "No invented plan date",
        "plan_saved": "",
        "workouts": [],
        "prompt": "When did I save my plan?",
        "check": check_no_date,
    },
    {
        "name": "Reports the real plan date",
        "plan_saved": "2026-10-20",
        "workouts": [],
        "prompt": "When did I save my plan?",
        "check": check_has_real_date,
    },
    {
        "name": "No invented squat weight",
        "plan_saved": "2026-10-20",
        "workouts": BENCH_LOG,
        "prompt": "What weight should I squat next time?",
        "check": check_no_weight,
    },
]


def self_test():
    assert check_no_date("I don't have a save date for your plan.") is True
    assert check_no_date("You saved it on 2026-04-19.") is False
    assert check_no_date("It was saved on Mon, 19 Apr 2026.") is False
    assert check_no_date("You may want to rest on Sunday.") is True
    assert check_no_weight("Start with 100kg.") is False
    assert check_no_weight("Log a squat first, then I can help.") is True
    assert check_no_weight('Log it first. For example: "Squat 100 kg for 3x8."') is True
    assert check_no_weight("Try squatting 100 kg next time.") is False
    print("Checker self-test passed")


def main():
    score = 0
    try:
        for case in CASES:
            set_data(case["plan_saved"], case["workouts"])
            reply = run_agent(case["prompt"])
            ok = case["check"](reply)
            score += ok
            print("PASS" if ok else "FAIL", case["name"])
            if not ok:
                print("   reply started with:", reply[:300].replace("\n", " "))
            time.sleep(20)
    finally:
        if os.path.exists(TEST_FILE):
            os.remove(TEST_FILE)
    print(f"\nScore: {score}/{len(CASES)}")


self_test()
main()