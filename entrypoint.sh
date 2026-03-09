#!/bin/bash
set -e
             
# Запускаем тесты в отдельном контейнере и сохраняем вывод
TEST_OUTPUT=$(docker run --rm testproj-app 2>&1) || true

# Сохраняем сырой лог
echo "$TEST_OUTPUT" > /usr/share/nginx/html/logs/test-output.txt

# Генерируем  HTML-отчёт 
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title> Результаты тестов</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #1e1e1e;
            color: #d4d4d4;
            margin: 0;
            padding: 20px;
        }
        h1 { border-bottom: 2px solid #007acc; padding-bottom: 10px; }
        pre {
            background: #2d2d2d;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 13px;
        }
        .status-pass { color: #4ec9b0; font-weight: bold; }
        .status-fail { color: #f14c4c; font-weight: bold; }
        .timestamp { color: #808080; font-size: 12px; }
    </style>
</head>
<body>
    <h1> Результаты тестов Candle</h1>
    <p class="timestamp">Обновлено: $(date -u +"%Y-%m-%d %H:%M:%S UTC")</p>
    
</body>
</html>
EOF
exec "$@"