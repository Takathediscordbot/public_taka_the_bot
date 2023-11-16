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

  ./scripts/init_db.sh $1
fi

sudo docker network connect bridge taka_the_discord_bot_database
ip=$(sudo docker inspect -f '{{ .NetworkSettings.Networks.bridge.IPAddress }}' taka_the_discord_bot_database )
cat taka_the_discord_bot_client/.env > taka_the_discord_bot_client/.env.dev
echo DATABASE_URL="postgres://postgres:$1@$ip:5432/taka_the_discord_bot" >> taka_the_discord_bot_client/.env
cat taka_the_discord_bot_client/.env > ./test.log
sudo docker compose down
sudo docker image rm taka_the_discord_bot_taka_the_discord_bot_client taka_the_discord_bot_dependencies taka_the_discord_bot_taka_the_discord_bot_tetrio_html_server
sudo docker compose build
cat taka_the_discord_bot_client/.env.dev > taka_the_discord_bot_client/.env
rm taka_the_discord_bot_client/.env.dev
sudo docker network disconnect bridge taka_the_discord_bot_database
