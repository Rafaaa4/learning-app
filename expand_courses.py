import json
import copy

def create_lesson(course_id, module_index, lesson_index, title, desc, content):
    return {
        "id": f"l_{course_id}_{module_index}_{lesson_index}",
        "title": title,
        "description": desc,
        "content": content,
        "challenge": {
            "title": f"Challenge: {title}",
            "description": f"Write a simple code to demonstrate {title}.",
            "initialCode": "// Write your code here",
            "validation": {
                "type": "javascript",
                "rules": [
                    {
                        "type": "text_contains",
                        "value": "print" if course_id == "py" else ("Console" if course_id == "cs" else "printf" if course_id == "c" else "cout" if course_id == "cpp" else "SELECT"),
                        "description": "Output a result"
                    }
                ]
            },
            "solution": "// A basic solution",
            "hints": ["Review the lesson content.", "Try running it first."],
            "points": 25
        },
        "quiz": [
            {
                "question": f"What is a key feature of {title}?",
                "options": ["Option A", "Option B", "Option C", "Option D"],
                "correctAnswerIndex": 0,
                "explanation": f"Option A is the correct characteristic for {title}."
            }
        ]
    }

course_topics = {
    'Python for Beginners': [
        ('Variables & Data Types', 'Learn about Python variables.'),
        ('Control Flow (if/else)', 'Conditionals in Python.'),
        ('Lists and Tuples', 'Working with arrays.'),
        ('Loops (for/while)', 'Iterating over data.'),
        ('Functions', 'Creating reusable blocks of code.'),
        ('Dictionaries', 'Key-value data structures.'),
        ('File I/O', 'Reading and writing files.'),
        ('Error Handling', 'Using try/except blocks.'),
        ('Object-Oriented Basics', 'Classes and objects.'),
        ('Modules and Packages', 'Importing libraries.')
    ],
    'MySQL Database Mastery': [
        ('Introduction to SQL', 'What is SQL?'),
        ('CREATE & DROP Tables', 'Defining schema.'),
        ('INSERT Data', 'Adding records.'),
        ('SELECT Queries', 'Reading data.'),
        ('WHERE Clause', 'Filtering results.'),
        ('UPDATE & DELETE', 'Modifying data.'),
        ('JOINS (Inner, Left)', 'Combining tables.'),
        ('Aggregate Functions', 'COUNT, SUM, AVG.'),
        ('GROUP BY & HAVING', 'Grouping data.'),
        ('Indexes and Performance', 'Speeding up queries.')
    ],
    'C# Fundamentals': [
        ('Variables and Types', 'Basic C# types.'),
        ('Operators and Expressions', 'Math and logic.'),
        ('Control Statements', 'If, switch, loops.'),
        ('Arrays and Collections', 'Lists and arrays.'),
        ('Methods', 'Functions in C#.'),
        ('Classes and Objects', 'OOP Basics.'),
        ('Inheritance', 'Class hierarchy.'),
        ('Interfaces', 'Defining contracts.'),
        ('Exception Handling', 'Try-catch blocks.'),
        ('LINQ Basics', 'Querying collections.')
    ],
    'C++ Programming': [
        ('Basic Syntax', 'Hello World in C++.'),
        ('Data Types and Variables', 'Memory and types.'),
        ('Control Structures', 'Loops and conditions.'),
        ('Functions', 'Pass by value vs reference.'),
        ('Arrays and Strings', 'Handling sequences.'),
        ('Pointers', 'Memory addresses.'),
        ('Classes and Objects', 'OOP in C++.'),
        ('Constructors', 'Object initialization.'),
        ('Inheritance', 'Reusing code.'),
        ('Polymorphism', 'Virtual functions.')
    ],
    'The C Programming Language': [
        ('Hello C', 'First C program.'),
        ('Variables and Data Types', 'Basic types.'),
        ('Operators', 'Arithmetic and logic.'),
        ('Control Flow', 'If, else, loops.'),
        ('Functions', 'Modular programming.'),
        ('Arrays', 'Contiguous memory.'),
        ('Pointers', 'Direct memory access.'),
        ('Strings', 'Character arrays.'),
        ('Structures (structs)', 'Custom data types.'),
        ('File Handling', 'Reading and writing files.')
    ]
}

course_ids = {
    'Python for Beginners': 'py',
    'MySQL Database Mastery': 'mysql',
    'C# Fundamentals': 'cs',
    'C++ Programming': 'cpp',
    'The C Programming Language': 'c'
}

with open('assets/data/courses.json', 'r') as f:
    courses = json.load(f)

for course in courses:
    title = course.get('title', '')
    if title in course_topics:
        # Generate 1 module with 10 lessons for simplicity, or modify the first module
        module = course['modules'][0]
        cid = course_ids[title]
        module['lessons'] = []
        
        topics = course_topics[title]
        for i, (ltitle, ldesc) in enumerate(topics):
            content = f"# {ltitle}\n\n{ldesc}\n\nHere is some detailed explanation about {ltitle}. Make sure to practice this concept thoroughly!"
            lesson = create_lesson(cid, 1, i+1, ltitle, ldesc, content)
            module['lessons'].append(lesson)
        
        # update total lessons count
        course['totalLessons'] = len(module['lessons'])

with open('assets/data/courses.json', 'w') as f:
    json.dump(courses, f, indent=2)

print("Updated courses.json successfully!")
