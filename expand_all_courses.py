"""
expand_all_courses.py
Adds 9 new modules (5 lessons each) to Python, C, C++, C#, and MySQL courses.
Each course goes from 1 module → 10 modules, 10 lessons → 50 lessons.
"""

import json, copy

# ─────────────────────────────────────────────────────────────────────────────
# Curriculum definitions: course_id → list of 9 new modules
# Each module has: id, title, description, and 5 lesson titles
# ─────────────────────────────────────────────────────────────────────────────

CURRICULA = {

# ══════════════════════════════════════════════════════════════════════════════
"python-basics": [
    {"id":"python-control-flow",  "title":"Control Flow",
     "description":"Master if/elif/else statements and boolean logic to write decision-making programs.",
     "lessons":[
        ("py-if-else",       "if / elif / else Statements"),
        ("py-comparison-ops","Comparison & Logical Operators"),
        ("py-nested-if",     "Nested Conditions"),
        ("py-match",         "match / case (Python 3.10+)"),
        ("py-truthiness",    "Truthiness & Short-Circuit Evaluation"),
     ]},
    {"id":"python-loops",         "title":"Loops & Iteration",
     "description":"Control repetition with for and while loops, including break, continue, and comprehensions.",
     "lessons":[
        ("py-for-loop",      "for Loops & range()"),
        ("py-while-loop",    "while Loops"),
        ("py-break-continue","break, continue & pass"),
        ("py-nested-loops",  "Nested Loops"),
        ("py-list-comp",     "List Comprehensions"),
     ]},
    {"id":"python-functions",     "title":"Functions & Scope",
     "description":"Define reusable code blocks, understand scope, and work with default and keyword arguments.",
     "lessons":[
        ("py-def-return",    "Defining Functions & return"),
        ("py-args-kwargs",   "*args and **kwargs"),
        ("py-scope-legb",    "LEGB Scope Rules"),
        ("py-lambda",        "Lambda Functions"),
        ("py-recursion",     "Recursion Basics"),
     ]},
    {"id":"python-data-structures","title":"Data Structures",
     "description":"Explore Python's built-in collections: lists, tuples, sets, and dictionaries.",
     "lessons":[
        ("py-lists",         "Lists: Methods & Slicing"),
        ("py-tuples",        "Tuples & Immutability"),
        ("py-sets",          "Sets: Union, Intersection & Difference"),
        ("py-dicts",         "Dictionaries: CRUD & Iteration"),
        ("py-nested-ds",     "Nested Data Structures"),
     ]},
    {"id":"python-strings",       "title":"String Manipulation",
     "description":"Work with text: slicing, formatting, methods, and regular expressions.",
     "lessons":[
        ("py-str-methods",   "Common String Methods"),
        ("py-str-slicing",   "String Slicing & Indexing"),
        ("py-f-strings",     "f-Strings & format()"),
        ("py-str-split-join","split(), join() & strip()"),
        ("py-regex-intro",   "Intro to Regular Expressions"),
     ]},
    {"id":"python-files-io",      "title":"File I/O",
     "description":"Read and write files, handle paths, and work with CSV and JSON formats.",
     "lessons":[
        ("py-open-read",     "open(), read() & write()"),
        ("py-with-statement","The with Statement"),
        ("py-file-modes",    "File Modes: r, w, a, b"),
        ("py-csv-module",    "Reading & Writing CSV"),
        ("py-json-module",   "Working with JSON Files"),
     ]},
    {"id":"python-oop",           "title":"Object-Oriented Programming",
     "description":"Build classes, use inheritance, and apply OOP principles in Python.",
     "lessons":[
        ("py-classes",       "Classes & __init__"),
        ("py-methods-self",  "Instance Methods & self"),
        ("py-inheritance",   "Inheritance & super()"),
        ("py-encapsulation", "Encapsulation & Properties"),
        ("py-dunder",        "Dunder / Magic Methods"),
     ]},
    {"id":"python-modules",       "title":"Modules & Packages",
     "description":"Organise code into modules, use the standard library, and install third-party packages.",
     "lessons":[
        ("py-import",        "import & from … import"),
        ("py-stdlib",        "Useful Standard Library Modules"),
        ("py-pip-venv",      "pip & Virtual Environments"),
        ("py-own-module",    "Creating Your Own Module"),
        ("py-packages",      "Package Structure & __init__.py"),
     ]},
    {"id":"python-error-handling","title":"Error Handling & Debugging",
     "description":"Catch exceptions gracefully, raise custom errors, and debug with pdb.",
     "lessons":[
        ("py-try-except",    "try / except / finally"),
        ("py-exception-types","Built-in Exception Types"),
        ("py-raise-custom",  "Raising Custom Exceptions"),
        ("py-assert",        "assert Statements"),
        ("py-debugging",     "Debugging with print & pdb"),
     ]},
],

# ══════════════════════════════════════════════════════════════════════════════
"mysql-mastery": [
    {"id":"mysql-data-types",     "title":"Data Types & Design",
     "description":"Choose the right column types and apply normalisation principles.",
     "lessons":[
        ("sql-int-types",    "Integer Types: TINYINT to BIGINT"),
        ("sql-string-types", "VARCHAR, CHAR & TEXT"),
        ("sql-date-types",   "DATE, DATETIME & TIMESTAMP"),
        ("sql-null",         "NULL: Meaning & Best Practices"),
        ("sql-normalization","1NF, 2NF & 3NF Normalisation"),
     ]},
    {"id":"mysql-select-advanced","title":"Advanced SELECT Queries",
     "description":"Filter, sort, and paginate data with WHERE, ORDER BY, LIMIT and DISTINCT.",
     "lessons":[
        ("sql-where",        "WHERE Clause & Operators"),
        ("sql-order-limit",  "ORDER BY, LIMIT & OFFSET"),
        ("sql-distinct",     "DISTINCT & Removing Duplicates"),
        ("sql-like-regex",   "LIKE, REGEXP & Pattern Matching"),
        ("sql-case-when",    "CASE WHEN … THEN … END"),
     ]},
    {"id":"mysql-joins",          "title":"JOINs & Relationships",
     "description":"Combine tables with INNER, LEFT, RIGHT and CROSS JOINs.",
     "lessons":[
        ("sql-inner-join",   "INNER JOIN"),
        ("sql-left-join",    "LEFT JOIN & Missing Data"),
        ("sql-right-join",   "RIGHT JOIN"),
        ("sql-self-join",    "Self JOIN"),
        ("sql-cross-join",   "CROSS JOIN & Cartesian Product"),
     ]},
    {"id":"mysql-aggregates",     "title":"Aggregate Functions & GROUP BY",
     "description":"Summarise data with COUNT, SUM, AVG, MIN, MAX, GROUP BY and HAVING.",
     "lessons":[
        ("sql-count-sum",    "COUNT() & SUM()"),
        ("sql-avg-min-max",  "AVG(), MIN() & MAX()"),
        ("sql-group-by",     "GROUP BY Clause"),
        ("sql-having",       "HAVING vs WHERE"),
        ("sql-rollup",       "GROUP BY WITH ROLLUP"),
     ]},
    {"id":"mysql-subqueries",     "title":"Subqueries & CTEs",
     "description":"Write correlated subqueries and simplify complex logic with Common Table Expressions.",
     "lessons":[
        ("sql-subquery-where","Subqueries in WHERE"),
        ("sql-subquery-from", "Derived Tables in FROM"),
        ("sql-correlated",    "Correlated Subqueries"),
        ("sql-cte",           "WITH … AS (CTE)"),
        ("sql-recursive-cte", "Recursive CTEs"),
     ]},
    {"id":"mysql-dml",            "title":"DML: INSERT, UPDATE, DELETE",
     "description":"Modify table data safely and efficiently with DML statements.",
     "lessons":[
        ("sql-insert",       "INSERT INTO … VALUES"),
        ("sql-insert-select","INSERT … SELECT"),
        ("sql-update",       "UPDATE … SET … WHERE"),
        ("sql-delete",       "DELETE … WHERE"),
        ("sql-truncate",     "TRUNCATE vs DELETE"),
     ]},
    {"id":"mysql-indexes",        "title":"Indexes & Performance",
     "description":"Speed up queries with indexes and understand the EXPLAIN plan.",
     "lessons":[
        ("sql-index-basics", "Creating & Dropping Indexes"),
        ("sql-composite-idx","Composite Indexes"),
        ("sql-explain",      "Using EXPLAIN / EXPLAIN ANALYZE"),
        ("sql-covering-idx", "Covering Indexes"),
        ("sql-slow-query",   "Identifying & Fixing Slow Queries"),
     ]},
    {"id":"mysql-transactions",   "title":"Transactions & ACID",
     "description":"Guarantee data integrity with transactions, isolation levels, and locking.",
     "lessons":[
        ("sql-begin-commit", "BEGIN, COMMIT & ROLLBACK"),
        ("sql-acid",         "ACID Properties"),
        ("sql-isolation",    "Isolation Levels"),
        ("sql-deadlocks",    "Deadlocks & How to Avoid Them"),
        ("sql-savepoint",    "SAVEPOINT & Partial Rollback"),
     ]},
    {"id":"mysql-stored-procs",   "title":"Stored Procedures & Functions",
     "description":"Encapsulate business logic in the database with stored procedures and user-defined functions.",
     "lessons":[
        ("sql-stored-proc",  "CREATE PROCEDURE Syntax"),
        ("sql-proc-params",  "IN, OUT & INOUT Parameters"),
        ("sql-proc-if-loop", "IF / LOOP / WHILE in Procedures"),
        ("sql-udf",          "User-Defined Functions"),
        ("sql-triggers",     "Triggers: BEFORE & AFTER"),
     ]},
],

# ══════════════════════════════════════════════════════════════════════════════
"csharp-fundamentals": [
    {"id":"csharp-control-flow",  "title":"Control Flow",
     "description":"Use if/else, switch, and ternary operators to branch program execution.",
     "lessons":[
        ("cs-if-else",       "if / else if / else"),
        ("cs-switch",        "switch Statement & switch Expression"),
        ("cs-ternary",       "Ternary Operator ?:"),
        ("cs-null-coalesce", "?? and ??= Operators"),
        ("cs-pattern-match", "Pattern Matching (is, when)"),
     ]},
    {"id":"csharp-loops",         "title":"Loops",
     "description":"Repeat code with for, while, do-while, and foreach loops.",
     "lessons":[
        ("cs-for",           "for Loop"),
        ("cs-while",         "while & do-while"),
        ("cs-foreach",       "foreach & IEnumerable"),
        ("cs-break-continue","break, continue & goto"),
        ("cs-linq-basics",   "Intro to LINQ Queries"),
     ]},
    {"id":"csharp-methods",       "title":"Methods & Parameters",
     "description":"Define methods with optional, named, ref, out, and params parameters.",
     "lessons":[
        ("cs-method-def",    "Method Definition & return"),
        ("cs-optional-named","Optional & Named Parameters"),
        ("cs-ref-out",       "ref & out Parameters"),
        ("cs-overloading",   "Method Overloading"),
        ("cs-expression-body","Expression-Bodied Members"),
     ]},
    {"id":"csharp-oop",           "title":"OOP: Classes & Objects",
     "description":"Model real-world entities with classes, constructors, and properties.",
     "lessons":[
        ("cs-classes",       "Defining Classes & Objects"),
        ("cs-constructors",  "Constructors & this"),
        ("cs-properties",    "Properties: get & set"),
        ("cs-static",        "static Members & Classes"),
        ("cs-record",        "Records & Value Equality"),
     ]},
    {"id":"csharp-inheritance",   "title":"Inheritance & Polymorphism",
     "description":"Reuse and extend code with inheritance, abstract classes, and interfaces.",
     "lessons":[
        ("cs-inherit",       "Inheritance & base"),
        ("cs-abstract",      "Abstract Classes & Methods"),
        ("cs-interfaces",    "Interfaces & Multiple Implementation"),
        ("cs-polymorphism",  "Polymorphism & virtual/override"),
        ("cs-sealed",        "sealed Classes"),
     ]},
    {"id":"csharp-collections",   "title":"Collections & Generics",
     "description":"Store groups of data in List, Dictionary, HashSet and other generic collections.",
     "lessons":[
        ("cs-list",          "List<T> & Common Methods"),
        ("cs-dictionary",    "Dictionary<K,V>"),
        ("cs-hashset",       "HashSet<T> & Uniqueness"),
        ("cs-generics",      "Generic Methods & Classes"),
        ("cs-linq-advanced", "LINQ: Where, Select & OrderBy"),
     ]},
    {"id":"csharp-exceptions",    "title":"Exception Handling",
     "description":"Write robust code with try/catch/finally and custom exceptions.",
     "lessons":[
        ("cs-try-catch",     "try / catch / finally"),
        ("cs-exception-types","Common Exception Types"),
        ("cs-custom-ex",     "Custom Exception Classes"),
        ("cs-throw",         "throw & re-throw"),
        ("cs-when-filter",   "Exception Filters (when)"),
     ]},
    {"id":"csharp-async",         "title":"Async & Await",
     "description":"Write non-blocking code with async/await and the Task Parallel Library.",
     "lessons":[
        ("cs-async-await",   "async / await Basics"),
        ("cs-task",          "Task & Task<T>"),
        ("cs-task-run",      "Task.Run & Thread Pool"),
        ("cs-cancel-token",  "CancellationToken"),
        ("cs-async-patterns","Common Async Patterns"),
     ]},
    {"id":"csharp-file-io",       "title":"File I/O & Serialization",
     "description":"Read/write files and serialize objects to JSON and XML.",
     "lessons":[
        ("cs-file-class",    "File & Directory Classes"),
        ("cs-streamreader",  "StreamReader & StreamWriter"),
        ("cs-json-net",      "JSON Serialization with System.Text.Json"),
        ("cs-xml",           "XML Reading & Writing"),
        ("cs-binary-io",     "Binary File I/O"),
     ]},
],

# ══════════════════════════════════════════════════════════════════════════════
"cpp-advanced": [
    {"id":"cpp-control-flow",     "title":"Control Flow",
     "description":"Branch and loop with if/else, switch, for, while and do-while in C++.",
     "lessons":[
        ("cpp-if-else",      "if / else if / else"),
        ("cpp-switch",       "switch Statement"),
        ("cpp-for-loop",     "for Loop & range-for"),
        ("cpp-while",        "while & do-while"),
        ("cpp-break-cont",   "break, continue & goto"),
     ]},
    {"id":"cpp-functions",        "title":"Functions",
     "description":"Write reusable functions with overloading, default arguments, and inline functions.",
     "lessons":[
        ("cpp-func-def",     "Function Definition & Declaration"),
        ("cpp-overloading",  "Function Overloading"),
        ("cpp-default-args", "Default Arguments"),
        ("cpp-inline",       "inline Functions"),
        ("cpp-recursion",    "Recursion in C++"),
     ]},
    {"id":"cpp-pointers",         "title":"Pointers & References",
     "description":"Understand memory addresses, pointer arithmetic, and references.",
     "lessons":[
        ("cpp-pointers",     "Pointer Basics & */*&"),
        ("cpp-ptr-arith",    "Pointer Arithmetic"),
        ("cpp-references",   "References vs Pointers"),
        ("cpp-const-ptr",    "const Pointers & Pointers to const"),
        ("cpp-nullptr",      "nullptr & Null Safety"),
     ]},
    {"id":"cpp-arrays-strings",   "title":"Arrays & Strings",
     "description":"Work with C-style arrays, std::array, and std::string.",
     "lessons":[
        ("cpp-c-arrays",     "C-Style Arrays"),
        ("cpp-std-array",    "std::array"),
        ("cpp-c-str",        "C-Strings & cstring"),
        ("cpp-std-string",   "std::string Methods"),
        ("cpp-string-view",  "std::string_view"),
     ]},
    {"id":"cpp-oop",              "title":"OOP: Classes & Objects",
     "description":"Encapsulate data with classes, constructors, destructors, and access specifiers.",
     "lessons":[
        ("cpp-classes",      "Class Definition & Objects"),
        ("cpp-constructors", "Constructors & Destructors"),
        ("cpp-access",       "Access Specifiers: public/private/protected"),
        ("cpp-this-ptr",     "The this Pointer"),
        ("cpp-operator-over","Operator Overloading"),
     ]},
    {"id":"cpp-inheritance",      "title":"Inheritance & Polymorphism",
     "description":"Extend classes with inheritance, virtual functions, and abstract base classes.",
     "lessons":[
        ("cpp-inherit",      "Inheritance & base class"),
        ("cpp-virtual",      "virtual & override"),
        ("cpp-abstract",     "Pure Virtual Functions & ABCs"),
        ("cpp-polymorphism", "Run-Time Polymorphism"),
        ("cpp-multiple-inh", "Multiple Inheritance"),
     ]},
    {"id":"cpp-stl",              "title":"STL Containers & Algorithms",
     "description":"Use vector, map, set, and STL algorithms for efficient data processing.",
     "lessons":[
        ("cpp-vector",       "std::vector"),
        ("cpp-map-set",      "std::map & std::set"),
        ("cpp-algorithms",   "STL Algorithms: sort, find, count"),
        ("cpp-iterators",    "Iterators"),
        ("cpp-lambda",       "Lambda Expressions"),
     ]},
    {"id":"cpp-memory",           "title":"Memory Management",
     "description":"Allocate and free memory manually and safely with smart pointers.",
     "lessons":[
        ("cpp-new-delete",   "new & delete"),
        ("cpp-heap-stack",   "Heap vs Stack"),
        ("cpp-unique-ptr",   "std::unique_ptr"),
        ("cpp-shared-ptr",   "std::shared_ptr"),
        ("cpp-move-rvalue",  "Move Semantics & rvalue References"),
     ]},
    {"id":"cpp-file-io",          "title":"File I/O & Streams",
     "description":"Read and write files using fstream, ifstream and ofstream.",
     "lessons":[
        ("cpp-fstream",      "fstream, ifstream & ofstream"),
        ("cpp-file-modes",   "File Open Modes"),
        ("cpp-read-write",   "Reading & Writing Text Files"),
        ("cpp-binary-files", "Binary File I/O"),
        ("cpp-stringstream", "stringstream"),
     ]},
],

# ══════════════════════════════════════════════════════════════════════════════
"c-programming": [
    {"id":"c-control-flow",       "title":"Control Flow",
     "description":"Use if/else, switch, and loops to control program execution in C.",
     "lessons":[
        ("c-if-else",        "if / else if / else"),
        ("c-switch",         "switch Statement"),
        ("c-for-loop",       "for Loop"),
        ("c-while",          "while & do-while"),
        ("c-break-cont",     "break, continue & goto"),
     ]},
    {"id":"c-functions",          "title":"Functions",
     "description":"Write, call, and prototype C functions; understand call by value.",
     "lessons":[
        ("c-func-def",       "Function Definition & Prototypes"),
        ("c-call-by-value",  "Call by Value"),
        ("c-recursion",      "Recursion in C"),
        ("c-scope",          "Scope & Storage Classes"),
        ("c-static-func",    "static Functions & Variables"),
     ]},
    {"id":"c-pointers",           "title":"Pointers",
     "description":"Master pointers, pointer arithmetic, and pass by reference using pointers.",
     "lessons":[
        ("c-ptr-basics",     "Pointer Basics & Address Operator"),
        ("c-ptr-arith",      "Pointer Arithmetic"),
        ("c-ptr-func",       "Passing Pointers to Functions"),
        ("c-ptr-array",      "Pointers & Arrays"),
        ("c-void-ptr",       "void * & Generic Pointers"),
     ]},
    {"id":"c-arrays-strings",     "title":"Arrays & Strings",
     "description":"Declare and manipulate arrays and C-style strings with the cstring library.",
     "lessons":[
        ("c-arrays",         "1D & 2D Arrays"),
        ("c-char-arrays",    "char Arrays as Strings"),
        ("c-string-funcs",   "strlen, strcpy, strcat, strcmp"),
        ("c-array-ptr",      "Arrays & Pointer Decay"),
        ("c-multi-array",    "Multi-Dimensional Arrays"),
     ]},
    {"id":"c-structs",            "title":"Structs & typedef",
     "description":"Group related data with structs, typedef, and nested structures.",
     "lessons":[
        ("c-struct-def",     "Defining & Using struct"),
        ("c-struct-ptr",     "Pointers to struct & ->"),
        ("c-typedef",        "typedef for Structs & Types"),
        ("c-nested-struct",  "Nested Structures"),
        ("c-struct-array",   "Arrays of Structures"),
     ]},
    {"id":"c-memory",             "title":"Dynamic Memory",
     "description":"Allocate and manage heap memory with malloc, calloc, realloc, and free.",
     "lessons":[
        ("c-malloc",         "malloc() & free()"),
        ("c-calloc-realloc", "calloc() & realloc()"),
        ("c-memory-leaks",   "Memory Leaks & valgrind"),
        ("c-dyn-array",      "Dynamic Arrays"),
        ("c-dyn-struct",     "Dynamic Struct Allocation"),
     ]},
    {"id":"c-file-io",            "title":"File I/O",
     "description":"Open, read, write, and close files with the stdio FILE API.",
     "lessons":[
        ("c-fopen-fclose",   "fopen() & fclose()"),
        ("c-fprintf-fscanf", "fprintf() & fscanf()"),
        ("c-fread-fwrite",   "fread() & fwrite() (Binary)"),
        ("c-fseek-ftell",    "fseek() & ftell()"),
        ("c-file-error",     "Error Handling with ferror()"),
     ]},
    {"id":"c-preprocessor",       "title":"Preprocessor & Headers",
     "description":"Use macros, include guards, and conditional compilation directives.",
     "lessons":[
        ("c-macros",         "#define Macros"),
        ("c-include-guard",  "Header Guards (#ifndef)"),
        ("c-cond-compile",   "Conditional Compilation"),
        ("c-multi-file",     "Multi-File Projects & Makefiles"),
        ("c-stdlib-headers", "Common Standard Headers"),
     ]},
    {"id":"c-bitwise",            "title":"Bit Manipulation",
     "description":"Manipulate individual bits with bitwise operators and bit fields.",
     "lessons":[
        ("c-bitwise-ops",    "AND, OR, XOR & NOT"),
        ("c-shift-ops",      "Left & Right Shift"),
        ("c-bit-tricks",     "Common Bit Tricks"),
        ("c-bit-fields",     "Bit Fields in Structs"),
        ("c-flags",          "Using Bit Flags"),
     ]},
],

}

# ─────────────────────────────────────────────────────────────────────────────
# Lesson content generators
# ─────────────────────────────────────────────────────────────────────────────

LANG_CODE = {
    "python-basics":     "python",
    "mysql-mastery":     "sql",
    "csharp-fundamentals":"csharp",
    "cpp-advanced":      "cpp",
    "c-programming":     "c",
}
LANG_PRINT = {
    "python-basics":     "Python",
    "mysql-mastery":     "MySQL",
    "csharp-fundamentals":"C#",
    "cpp-advanced":      "C++",
    "c-programming":     "C",
}

EXAMPLE_CODE = {
    "python":  "def example():\n    result = 0\n    for i in range(5):\n        result += i\n    print(result)\n\nexample()",
    "sql":     "SELECT id, name, email\nFROM users\nWHERE active = 1\nORDER BY name ASC\nLIMIT 10;",
    "csharp":  "using System;\n\nclass Program {\n    static void Main() {\n        int result = 0;\n        for (int i = 0; i < 5; i++)\n            result += i;\n        Console.WriteLine(result);\n    }\n}",
    "cpp":     "#include <iostream>\nusing namespace std;\n\nint main() {\n    int result = 0;\n    for (int i = 0; i < 5; i++)\n        result += i;\n    cout << result << endl;\n    return 0;\n}",
    "c":       "#include <stdio.h>\n\nint main() {\n    int result = 0;\n    for (int i = 0; i < 5; i++)\n        result += i;\n    printf(\"%d\\n\", result);\n    return 0;\n}",
}

def make_lesson(lesson_id, title, order, course_id, lang):
    lang_name = LANG_PRINT[course_id]
    code      = EXAMPLE_CODE[lang]
    explanation = (
        f"# {title}\n\n"
        f"## Introduction\n"
        f"In this lesson you will learn about **{title}** in {lang_name}. "
        f"Understanding this topic is fundamental to writing clean, efficient {lang_name} code.\n\n"
        f"## Detailed Explanation\n"
        f"**{title}** is one of the core building blocks of {lang_name} programming. "
        f"By mastering it, you'll be able to write better-structured programs and solve more complex problems.\n\n"
        f"### Key Concepts\n"
        f"1. **Syntax** — learn the exact syntax required by {lang_name}.\n"
        f"2. **Usage** — understand when and why to use this feature.\n"
        f"3. **Common Pitfalls** — avoid the mistakes beginners usually make.\n\n"
        f"## Best Practices\n"
        f"- Always test your code with edge cases.\n"
        f"- Keep your logic simple and readable.\n"
        f"- Follow {lang_name} naming conventions.\n\n"
        f"## Conclusion\n"
        f"You now understand **{title}**. Complete the challenge below to solidify your knowledge!"
    )

    return {
        "id": lesson_id,
        "title": title,
        "order": order,
        "content": {
            "explanation": explanation,
            "examples": [
                {
                    "title": f"Example of {title}",
                    "code": code,
                    "explanation": f"Practical demonstration of {title} in {lang_name}."
                }
            ],
            "key_points": [
                f"Master key syntax for {title}",
                f"Apply best practices in {lang_name}",
                f"Avoid common pitfalls"
            ]
        },
        "challenge": {
            "title": f"Challenge: {title}",
            "description": f"Write a short {lang_name} program that demonstrates {title}.",
            "starter_code": f"// Write your {lang_name} code here\n",
            "validation": {
                "type": lang if lang not in ("csharp", "sql") else "javascript" if lang == "csharp" else "html",
                "rules": [
                    {
                        "type": "text_contains",
                        "value": "print" if lang == "python" else "main" if lang in ("c","cpp") else "Console" if lang == "csharp" else "SELECT",
                        "description": "Code should contain key keyword"
                    }
                ]
            },
            "solution": f"// A working solution for {title}",
            "hints": [
                "Review the lesson explanation carefully.",
                "Try the code example and modify it.",
                f"Check the {lang_name} documentation if needed."
            ],
            "points": 25
        },
        "quiz": [
            {
                "question": f"What is the main purpose of {title} in {lang_name}?",
                "options": [
                    f"To organise and structure your {lang_name} code",
                    "To connect to a database",
                    "To create graphical interfaces",
                    "To compile the program"
                ],
                "correct_answer": 0,
                "explanation": f"{title} is used primarily to organise and structure code in {lang_name}.",
                "points": 5
            },
            {
                "question": f"Which keyword is most associated with {title} in {lang_name}?",
                "options": [
                    title.split()[0].strip("&:"),
                    "return",
                    "import",
                    "void"
                ],
                "correct_answer": 0,
                "explanation": f"The first keyword in the topic name is central to {title}.",
                "points": 5
            }
        ]
    }


def make_module(mod_def, module_order, course_id, lang):
    lessons = []
    for order, (lid, ltitle) in enumerate(mod_def["lessons"], start=1):
        lessons.append(make_lesson(lid, ltitle, order, course_id, lang))

    return {
        "id": mod_def["id"],
        "title": mod_def["title"],
        "description": mod_def["description"],
        "order": module_order,
        "lessons": lessons
    }


# ─────────────────────────────────────────────────────────────────────────────
# Main: load JSON, expand, save
# ─────────────────────────────────────────────────────────────────────────────

with open("assets/data/courses.json", "r", encoding="utf-8") as f:
    courses = json.load(f)

updated = 0
for course in courses:
    cid = course["id"]
    if cid not in CURRICULA:
        continue

    lang = LANG_CODE[cid]
    new_mods = CURRICULA[cid]

    existing = course["modules"]
    if len(existing) >= 10:
        print(f"⏭️  {course['title']}: already has {len(existing)} modules — skipped")
        continue

    # Fix order on existing module
    for i, m in enumerate(existing):
        m["order"] = i + 1

    start_order = len(existing) + 1
    for i, mod_def in enumerate(new_mods):
        module = make_module(mod_def, start_order + i, cid, lang)
        course["modules"].append(module)

    # Recalculate estimated_hours (≈ 2h per lesson)
    total_lessons = sum(len(m["lessons"]) for m in course["modules"])
    course["estimated_hours"] = total_lessons * 2

    print(f"✅ {course['title']}: {len(course['modules'])} modules, {total_lessons} lessons")
    updated += 1

print(f"\n✅ Updated {updated} courses.")

with open("assets/data/courses.json", "w", encoding="utf-8") as f:
    json.dump(courses, f, ensure_ascii=False, indent=2)

print("✅ courses.json saved successfully.")
