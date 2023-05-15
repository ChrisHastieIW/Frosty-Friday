import re

def extract_class_value(input_string):
    match = re.search('class="([^"]*)', input_string)
    return match.group(1) if match else None