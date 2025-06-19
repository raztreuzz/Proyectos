import json
import re

class SimpleParser:
    def __init__(self, intents_file):
        with open(intents_file, "r", encoding="utf-8") as f:
            self.intents = json.load(f)["intents"]

    def match_intent(self, user_input):
        user_input = user_input.lower()
        for intent in self.intents:
            for pattern in intent["patterns"]:
                if re.search(rf"\b{re.escape(pattern.lower())}\b", user_input):
                    return intent
        return None
