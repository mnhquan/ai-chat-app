import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")  # Lấy từ https://aistudio.google.com/apikey
GEMINI_MODEL = "gemini-2.0-flash"              # Model nhanh, free tier rộng rãi
