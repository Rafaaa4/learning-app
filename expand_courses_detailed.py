import json
import random

def generate_detailed_content(title, desc, lang):
    lang_map = {
        'py': 'python',
        'mysql': 'sql',
        'cs': 'csharp',
        'cpp': 'cpp',
        'c': 'c'
    }
    
    code_lang = lang_map.get(lang, 'text')
    
    # Generic examples based on language
    if lang == 'py':
        code = "def example_function():\n    print('Hello from Python!')\n\nexample_function()"
    elif lang == 'mysql':
        code = "SELECT * FROM users WHERE active = 1;"
    elif lang == 'cs':
        code = "using System;\n\nclass Program {\n    static void Main() {\n        Console.WriteLine(\"Hello C#\");\n    }\n}"
    elif lang == 'cpp':
        code = "#include <iostream>\n\nint main() {\n    std::cout << \"Hello C++\" << std::endl;\n    return 0;\n}"
    else:
        code = "#include <stdio.h>\n\nint main() {\n    printf(\"Hello C\\n\");\n    return 0;\n}"

    content = f"""# {title}

## Introduction
{desc}

Welcome to this comprehensive lesson on **{title}**. In programming, mastering this concept is essential for writing robust and efficient code. Let's dive deep into how it works under the hood.

## Detailed Explanation
When you use {title}, you are essentially instructing the computer to perform specific operations based on the rules of the language. 
This provides a powerful way to organize, manipulate, and execute logic within your applications. 

### Why is this important?
1. **Efficiency**: It allows you to write less code and do more.
2. **Readability**: Code becomes much easier for other developers to read and maintain.
3. **Scalability**: As your project grows, these foundational concepts keep your architecture stable.

## Code Example
Here is a practical example of how you can implement {title} in your code:

```{code_lang}
{code}
```

### Breaking down the code:
- The first part sets up the environment or defines the structure.
- The core logic executes the main operation we discussed.
- Finally, the output is returned or printed to the console.

## Common Pitfalls & Best Practices
- **Watch out for syntax errors**: A missing semicolon or wrong indentation can break the code.
- **Keep it simple**: Don't overcomplicate your logic. Break down complex problems into smaller, manageable pieces.
- **Test thoroughly**: Always verify your code with different inputs to ensure it behaves as expected.

## Conclusion
Now that you have a solid understanding of {title}, it's time to put it into practice. Move on to the challenge to test your skills!
"""
    return content

with open('assets/data/courses.json', 'r') as f:
    courses = json.load(f)

course_ids = {
    'Python for Beginners': 'py',
    'MySQL Database Mastery': 'mysql',
    'C# Fundamentals': 'cs',
    'C++ Programming': 'cpp',
    'The C Programming Language': 'c'
}

for course in courses:
    title = course.get('title', '')
    if title in course_ids:
        cid = course_ids[title]
        module = course['modules'][0]
        
        for lesson in module['lessons']:
            # Expand the content significantly
            lesson['content'] = generate_detailed_content(lesson['title'], lesson['description'], cid)

with open('assets/data/courses.json', 'w') as f:
    json.dump(courses, f, indent=2)

print("Expanded lesson contents successfully!")
