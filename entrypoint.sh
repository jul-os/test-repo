#!/bin/bash
set -e

# Параметры для поиска подов приложения
APP_LABEL="${APP_POD_LABEL:-app=test-repo-app}"
NAMESPACE="${NAMESPACE:-default}"
MAX_WAIT=300  # секунд ожидания завершения тестов

echo "🔍 Поиск подов с лейблом: $APP_LABEL в пространстве: $NAMESPACE"

# Ждём, пока появится хотя бы один под с нужным лейблом
wait_for_pods() {
  local count=0
  while [ $count -lt $MAX_WAIT ]; do
    if kubectl get pods -l "$APP_LABEL" -n "$NAMESPACE" --no-headers 2>/dev/null | grep -q "Running\|Succeeded"; then
      echo "✅ Под(ы) приложения обнаружены"
      return 0
    fi
    sleep 5
    count=$((count + 5))
    echo "⏳ Ожидание подов... ($count сек)"
  done
  echo "⚠️ Таймаут ожидания подов"
  return 1
}

# Получаем логи из завершённых подов приложения
fetch_app_logs() {
  local logs=""
  # Ищем поды, которые уже завершились (тесты прошли)
  for pod in $(kubectl get pods -l "$APP_LABEL" -n "$NAMESPACE" --no-headers -o name 2>/dev/null); do
    echo "📋 Получаем логи из $pod"
    logs+="\n=== Логы из $pod ===\n"
    logs+="$(kubectl logs "$pod" -n "$NAMESPACE" 2>&1 || echo '❌ Не удалось получить логи')"
    logs+="\n"
  done
  
  if [ -z "$logs" ]; then
    logs="⚠️ Логи не найдены. Убедитесь, что поды приложения запустились и завершили работу."
  fi
  echo "$logs"
}

# Основной цикл: ждём завершения тестов и забираем логи
if wait_for_pods; then
  # Даём время на завершение тестов в подах
  sleep 10
  TEST_OUTPUT=$(fetch_app_logs)
else
  TEST_OUTPUT="⚠️ Не удалось дождаться запуска подов приложения"
fi

# Сохраняем в файл для доступа через nginx
echo "$TEST_OUTPUT" > /usr/share/nginx/html/logs/test-output.txt

# Генерируем HTML-страницу
cat > /usr/share/nginx/html/index.html << HTMLEOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Результаты тестов Candle</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #1e1e1e; color: #d4d4d4; padding: 20px; margin: 0; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #569cd6; border-bottom: 1px solid #3e3e42; padding-bottom: 10px; }
        .timestamp { color: #808080; font-size: 0.9em; margin-bottom: 20px; }
        pre { background: #2d2d2d; padding: 15px; border-radius: 5px; overflow-x: auto; border: 1px solid #3e3e42; }
        .success { color: #6a9955; }
        .error { color: #f14c4c; }
        .warning { color: #cca700; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Результаты тестов Candle</h1>
        <p class="timestamp">Обновлено: $(date -u +"%Y-%m-%d %H:%M:%S UTC")</p>
        <p class="timestamp">Namespace: $NAMESPACE | Label: $APP_LABEL</p>
        <pre>$(echo "$TEST_OUTPUT" | sed 's/[&<>]/\&/g; s/</\&lt;/g; s/>/\&gt;/g')</pre>
    </div>
</body>
</html>
HTMLEOF

echo "✅ Страница с результатами обновлена"

# Передаём управление nginx
exec "$@"