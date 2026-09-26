import json

with open('assets/data/courses.json', 'r') as f:
    courses = json.load(f)

for course in courses:
    title = course.get('title', '')
    if title in ['Python Programming', 'C++ Programming', 'C# Development', 'C Programming', 'MySQL Database']:
        total_lessons = sum(len(m.get('lessons', [])) for m in course.get('modules', []))
        print(f"{title}: {total_lessons} lessons")

