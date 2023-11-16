
result=$( docker ps -q -f name="taka_the_discord_bot_database" )

if [[ $# -eq 0 ]]; then 
  echo "Database password is required to run this command!"
  exit 1
fi


if [[ -n "$result" ]]; then
  echo 'Database exists!'
else
  if [[ $# -eq 0 ]]; then 
    echo "Couldn't build because database was not started and the password was not initialized."
    exit 1
  fi

  ./scripts/init_db_wsl.sh $1
fi

docker network connect bridge taka_the_discord_bot_database
ip=$( docker inspect -f '{{ .NetworkSettings.Networks.bridge.IPAddress }}' taka_the_discord_bot_database )
cat taka_the_discord_bot_client/.env > taka_the_discord_bot_client/.env.dev
echo DATABASE_URL="postgres://postgres:$1@$ip:5432/taka_the_discord_bot" >> taka_the_discord_bot_client/.env
docker-compose down
docker image rm taka_the_discord_bot_taka_the_discord_bot_client taka_the_discord_bot_dependencies taka_the_discord_bot_taka_the_discord_bot_tetrio_html_server
docker-compose build
cat taka_the_discord_bot_client/.env.dev > taka_the_discord_bot_client/.env
rm taka_the_discord_bot_client/.env.dev
docker network disconnect bridge taka_the_discord_bot_database

