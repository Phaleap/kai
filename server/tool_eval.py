import time

from openai import OpenAI

from coach_tools import SYSTEM_PROMPT, TOOLS
from config import API_KEY, BASE_URL, MODEL

client = OpenAI(base_url=BASE_URL, api_key=API_KEY)


def first_tools(user_message):
    for attempt in range(3):
        try:
            response = client.chat.completions.create(
                model=MODEL,
                max_tokens=400,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_message},
                ],
                tools=TOOLS,
            )
            message = response.choices[0].message
            return [call.function.name for call in (message.tool_calls or [])]
        except Exception as e:
            if "429" in str(e) or "401" in str(e) or attempt == 2:
                raise
            time.sleep(2 ** attempt * 2)


# RULE: the wanted tool must be in the list, and no forbidden tool may be.
def check_tools(called, expect=None, forbid=()):
    if expect and expect not in called:
        return False
    for name in forbid:
        if name in called:
            return False
    return True


CASES = [
    {
        "name": "Protein question uses the notes",
        "prompt": "How much protein should I eat?",
        "expect": "search_notes",
        "forbid": (),
    },
    {
        "name": "Planning checks history first",
        "prompt": "Plan my training week.",
        "expect": "get_workouts",
        "forbid": (),
    },
    {
        "name": "Workout report gets logged",
        "prompt": "I just did bench press, 3 sets of 8 at 80 kg.",
        "expect": "log_workout",
        "forbid": (),
    },
    {
        "name": "Off-topic question writes nothing",
        "prompt": "Who won the football world cup?",
        "expect": None,
        "forbid": ("log_workout", "save_plan"),
    },
]


def self_test():
    assert check_tools(["search_notes"], expect="search_notes") is True
    assert check_tools([], expect="search_notes") is False
    assert check_tools(["log_workout"], forbid=("log_workout",)) is False
    assert check_tools([], forbid=("log_workout",)) is True
    print("Checker self-test passed")


def main():
    score = 0
    for case in CASES:
        called = first_tools(case["prompt"])
        ok = check_tools(called, case["expect"], case["forbid"])
        score += ok
        print("PASS" if ok else "FAIL", case["name"], "| tools called:", called)
        time.sleep(10)
    print()
    print(f"Score: {score}/{len(CASES)}")


self_test()
main()