import re
from collections import defaultdict

with open('flutter_analyze_full.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 경고/에러 파싱
pattern = r'^\s*(info|warning|error)\s*•\s*(.+?)\s*•\s*(.+?)\s*•\s*(.+?)\s*$'
issues = []

for line in content.split('\n'):
    match = re.match(pattern, line)
    if match:
        level = match.group(1)
        message = match.group(2).strip()
        location = match.group(3).strip()
        code = match.group(4).strip()
        issues.append({
            'level': level,
            'message': message,
            'location': location,
            'code': code
        })

# 파일별 분류
by_file = defaultdict(list)
for issue in issues:
    file_path = issue['location'].split(':')[0]
    by_file[file_path].append(issue)

# 에러 코드별 분류
by_code = defaultdict(list)
for issue in issues:
    by_code[issue['code']].append(issue)

# 통계 출력
print("=== 파일별 경고 통계 (상위 20개) ===")
sorted_files = sorted(by_file.items(), key=lambda x: len(x[1]), reverse=True)[:20]
for file_path, file_issues in sorted_files:
    print(f"{len(file_issues):4d}  {file_path}")

print("\n=== 에러 코드별 통계 ===")
sorted_codes = sorted(by_code.items(), key=lambda x: len(x[1]), reverse=True)
for code, code_issues in sorted_codes:
    level_counts = defaultdict(int)
    for issue in code_issues:
        level_counts[issue['level']] += 1
    
    levels_str = ', '.join([f"{level}: {count}" for level, count in level_counts.items()])
    print(f"{len(code_issues):4d}  {code:40s}  ({levels_str})")

print(f"\n총 이슈 개수: {len(issues)}")
