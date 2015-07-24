#! /bin/bash

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )";
SCRIPT=$(basename "${BASH_SOURCE[0]}")
USAGE="Usage: ./$SCRIPT <config>"

source "$PROJECT_DIR/scripts/exec_on_env.sh"

# set the pg password so you're not prompted for login..
PGPASSWORD=$POSTGRES_PASSWORD

function postgres_test_data {
    echo "Password: $PGPASSWORD"
    PGPASSWORD=$POSTGRES_PASSWORD psql --single-transaction -w -h $POSTGRES_HOST -U $POSTGRES_USERNAME -d $POSTGRES_NAME -f "$PROJECT_DIR/scripts/database/pg/populate-dojos.sql" --port $POSTGRES_PORT
}

function delete_elasticsearch_index {
    echo "Deleting http://$ES_HOST:9200/$ES_INDEX" ;
    curl -XDELETE "http://$ES_HOST:9200/$ES_INDEX?pretty"
}

function test_data {
    run_js "$PROJECT_DIR/scripts/add-geonames-data.js"
    run_js "$PROJECT_DIR/scripts/generate-slugs.js"
    run_js "$PROJECT_DIR/scripts/es-index-dojos-data.js"
}

postgres_test_data
delete_elasticsearch_index
test_data

echo "-------------------------------------------------------"
echo "-------Finished initializating dojos            -------"
echo "-------------------------------------------------------"

