

#!/bin/bash
set -e

# Получаем логи запускаем тесты
TEST_OUTPUT=$(docker run --rm testproj-app 2>&1) || true

ESCAPED_OUTPUT=$(echo "$TEST_OUTPUT" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

# Формируем HTML-отчёт 
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Результаты тестов</title>
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
            white-space: pre-wrap;       /* Перенос длинных строк */
            word-wrap: break-word;       /* Разрыв слов */
        }
        .timestamp { color: #808080; font-size: 12px; }
    </style>
</head>
<body>
    <h1>Результаты тестов Candle</h1>
    <p class="timestamp">Обновлено: $(date -u +"%Y-%m-%d %H:%M:%S UTC")</p>
    <h2>Лог выполнения:</h2>
    <pre>$ESCAPED_OUTPUT</pre>
</body>
</html>
EOF

#запускаем Nginx в режиме демона 
exec nginx -g "daemon off;"