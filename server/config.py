import os

from dotenv import load_dotenv

load_dotenv()

# Any OpenAI-compatible provider works. Change these in .env, not in code.
BASE_URL = os.environ.get("AI_BASE_URL", "https://api.groq.com/openai/v1")
MODEL = os.environ.get("AI_MODEL", "qwen/qwen3.8-27b")
API_KEY = os.environ.get("AI_API_KEY") or os.environ.get("GROQ_API_KEY")
