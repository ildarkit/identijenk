# Аргументы для Compose, определяемые по умолчанию
COMPOSE_ARGS=" -f jenkins.yml -p jenkins "
# Необходимо остановить и удалить все старые контейнеры
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v
# Создание (сборка) системы
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d
# Выполнение модульного тестирования
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?
# Выполнение тестирования системы в целом, если модульное тестирование завершилось успешно
if [ $ERR -eq 0 ]; then
        echo "Test passed - Tegging"
        HASH=$(git rev-parse --short HEAD)
        sudo docker tag -f jenkins_identidock localregistry:5000/identidock:$HASH
        sudo docker tag -f jenkins_identidock localregistry:5000/identidock:newest
        echo "Pushing"
        sudo docker push localregistry:5000/identidock:$HASH
        sudo docker push localregistry:5000/identidock:newest
        
        IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1)
        CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
    if [ $CODE -ne 200 ]; then
        echo "Site returned " $CODE
        ERR=1
    fi
fi
# Останов и удаление системы
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v
return $ERR