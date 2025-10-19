#!/usr/bin/env python3
"""
디버그 로그 정리 스크립트
모든 print() 문을 if (kDebugMode) print()로 감싸고,
import 'package:flutter/foundation.dart'를 추가합니다.
"""

import re
import sys

def wrap_print_statements(content):
    """print문을 kDebugMode로 감싸기"""
    lines = content.split('\n')
    result_lines = []

    for i, line in enumerate(lines):
        # 이미 kDebugMode로 감싸진 print문은 건너뛰기
        if 'kDebugMode' in line:
            result_lines.append(line)
            continue

        # print문 찾기 (들여쓰기 유지)
        match = re.match(r'^(\s*)print\(', line)
        if match:
            indent = match.group(1)
            # 이미 if문 안에 있는지 확인
            if i > 0 and 'if' in lines[i-1]:
                result_lines.append(line)
            else:
                # if (kDebugMode)로 감싸기
                result_lines.append(f"{indent}if (kDebugMode) {line.strip()}")
        else:
            result_lines.append(line)

    return '\n'.join(result_lines)

def add_foundation_import(content):
    """flutter/foundation.dart import 추가"""
    # 이미 import가 있는지 확인
    if 'package:flutter/foundation.dart' in content:
        return content

    lines = content.split('\n')

    # import 섹션 찾기
    import_end_idx = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            import_end_idx = i + 1

    # import 추가
    if import_end_idx > 0:
        lines.insert(import_end_idx, "import 'package:flutter/foundation.dart';")

    return '\n'.join(lines)

def process_file(file_path):
    """파일 처리"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # import 추가
        content = add_foundation_import(content)

        # print문 감싸기
        content = wrap_print_statements(content)

        # 파일 저장
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"✓ {file_path} 처리 완료")
        return True
    except Exception as e:
        print(f"✗ {file_path} 처리 실패: {e}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python debug_log_wrapper.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    success = process_file(file_path)
    sys.exit(0 if success else 1)
