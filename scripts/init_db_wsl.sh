if [[ $# -eq 0 ]]; then 
    echo "A password has to be specified!"
    exit 1
fi

echo "Stopping existing database container"
docker stop taka_the_discord_bot_database
docker rm taka_the_discord_bot_database
docker network rm taka_the_discord_bot_db_network
echo "Creating database container"
docker network create taka_the_discord_bot_db_network
echo "Setting the .env settings properly"
docker run --network taka_the_discord_bot_db_network --name taka_the_discord_bot_database -e POSTGRES_PASSWORD="$1" -d postgres:16.0-alpine3.18
ip=$( docker inspect -f '{{ .NetworkSettings.Networks.taka_the_discord_bot_db_network.IPAddress }}' taka_the_discord_bot_database )
echo DATABASE_URL="postgres://postgres:$1@$ip:5432/taka_the_discord_bot">taka_the_discord_bot_client/.env.prod
cat taka_the_discord_bot_client/.env >> taka_the_discord_bot_client/.env.prod
echo "Restoring database dump."
sleep 2
cat ./taka_the_discord_bot_database/postgres_database_dump.sql | docker exec -i taka_the_discord_bot_database psql -U postgres 
