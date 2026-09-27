#!/usr/bin/env python3
"""
Learnpg — Supabase Course Seeder (Python version)
Seeds all 6 courses from assets/data/courses.json to Supabase courses_db table.
"""

import json
import urllib.request
import urllib.error

SUPABASE_URL = "https://bcyhuhnnokmssvcjibwd.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjeWh1aG5ub2ttc3N2Y2ppYndkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0OTY3MDcsImV4cCI6MjEwNjA3MjcwN30.WNFJQSjy1TjA_7rkY_OL0AZCQ0K4RptDIia4AkYdS_Y"

def seed_course(course: dict) -> bool:
    course_id = course.get("id", "?")
    course_title = course.get("title", "?")

    payload = {
        "id": course_id,
        "title": course_title,
        "description": course.get("description"),
        "level": course.get("level"),
        "estimated_hours": course.get("estimated_hours"),
        "language": course.get("language"),
        "tags": course.get("tags"),
        "modules": course.get("modules"),
    }

    data = json.dumps(payload, ensure_ascii=False).encode("utf-8")

    url = f"{SUPABASE_URL}/rest/v1/courses_db"
    req = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            status = resp.status
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"   ⚠️  HTTP {e.code}: {body[:300]}")
        return False

    if status in (200, 201, 204):
        modules = course.get("modules", [])
        total_lessons = sum(len(m.get("lessons", [])) for m in modules)
        print(f"   ✅ Done! ({len(modules)} modules, {total_lessons} lessons)")
        return True
    else:
        print(f"   ⚠️  Unexpected status: {status}")
        return False


def main():
    print("🚀 Learnpg — Supabase Course Seeder")
    print("=====================================")
    print(f"📡 Target: {SUPABASE_URL}")

    with open("assets/data/courses.json", encoding="utf-8") as f:
        raw = json.load(f)

    courses = raw if isinstance(raw, list) else [raw]
    print(f"📂 Found {len(courses)} courses to seed.\n")

    seeded = 0
    failed = 0

    for course in courses:
        cid = course.get("id", "?")
        ctitle = course.get("title", "?")
        print(f"⬆️  Seeding: {ctitle} ({cid})...")
        if seed_course(course):
            seeded += 1
        else:
            failed += 1

    print("\n=====================================")
    print("📊 Seeding Summary:")
    print(f"   ✅ Seeded: {seeded} / {len(courses)} courses")
    if failed:
        print(f"   ❌ Failed: {failed} courses")
    print("\n🎉 All done! Check your Supabase Table Editor → courses_db")


if __name__ == "__main__":
    main()
