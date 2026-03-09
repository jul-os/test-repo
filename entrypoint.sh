#!/bin/bash
set -e

TEST_OUTPUT=$(docker run --rm test-repo-app:latest 2>&1) || true
echo "$TEST_OUTPUT" > /usr/share/nginx/html/logs/test-output.txt

cat > /usr/share/nginx/html/index.html << HTMLEOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Результаты тестов</title>
    <style>
        body { font-family: sans-serif; background: #1e1e1e; color: #d4d4d4; padding: 20px; }
        pre { background: #2d2d2d; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>Результаты тестов Candle</h1>
    <p>Обновлено: $(date -u +"%Y-%m-%d %H:%M:%S UTC")</p>
    <pre>$TEST_OUTPUT</pre>
</body>
</html>
HTMLEOF

exec "$@"
