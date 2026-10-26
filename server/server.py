import json
import time

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel

from coach_tools import TOOL_FUNCTIONS, TOOLS, build_system_prompt
from config import API_KEY, BASE_URL, MODEL

MAX_STEPS = 8
MAX_HISTORY = 6

client = OpenAI(api_key=API_KEY, base_url=BASE_URL)
app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    messages: list[Message]


def run_tool(call):
    name = call.function.name
    if name not in TOOL_FUNCTIONS:
        return f"Unknown tool: {name}"
    try:
        args = json.loads(call.function.arguments or "{}")
        return TOOL_FUNCTIONS[name](**args)
    except Exception as e:
        return f"Tool error: {e}"


def ask_model(messages):
    for attempt in range(4):
        try:
            return client.chat.completions.create(model=MODEL, messages=messages, tools=TOOLS)
        except Exception as e:
            if "429" in str(e) or "401" in str(e) or attempt == 3:
                raise
            time.sleep(2 ** attempt * 2)


@app.get("/")
def health():
    return {"status": "coach is running"}


@app.post("/chat")
def chat(request: ChatRequest):
    history = [m.model_dump() for m in request.messages][-MAX_HISTORY:]
    messages = [{"role": "system", "content": build_system_prompt()}] + history
    try:
        for step in range(MAX_STEPS):
            message = ask_model(messages).choices[0].message
            if not message.tool_calls:
                return {"reply": message.content or ""}
            messages.append(
                {
                    "role": "assistant",
                    "content": message.content or "",
                    "tool_calls": [
                        {
                            "id": call.id,
                            "type": "function",
                            "function": {"name": call.function.name, "arguments": call.function.arguments},
                        }
                        for call in message.tool_calls
                    ],
                }
            )
            for call in message.tool_calls:
                messages.append({"role": "tool", "tool_call_id": call.id, "content": run_tool(call)})
        return {"reply": "Sorry, that took too many steps. Please try again."}
    except Exception as e:
        print(e)
        if "429" in str(e):
            return {"reply": "The coach is busy right now (rate limit). Please try again in a minute."}
        return {"reply": "Something went wrong. Please try again."}