#!/bin/bash

# Function to find cypher-shell
find_cypher_shell() {
    if command -v cypher-shell &> /dev/null; then
        echo "cypher-shell"
    elif [ -x "/usr/share/neo4j/bin/cypher-shell" ]; then
        echo "/usr/share/neo4j/bin/cypher-shell"
    else
        echo ""
    fi
}

# Get the path to cypher-shell
CYPHER_SHELL=$(find_cypher_shell)

if [ -z "$CYPHER_SHELL" ]; then
    echo "Error: cypher-shell is not installed and not found in /usr/share/neo4j/bin. Please install it or adjust the script to point to the correct location."
    exit 1
fi

# Function to run Neo4j queries and check credentials
run_query() {
    local query="$1"
    local output

    output=$("$CYPHER_SHELL" -u "$USERNAME" -p "$NEO4J_PASSWORD" "$query" 2>&1)
    local status=$?

    if [[ $status -ne 0 ]]; then
        if [[ $output == *"authentication failure"* ]]; then
            echo "Error: Invalid Neo4j credentials."
            exit 1
        else
            echo "Error executing query: $output"
            exit 1
        fi
    fi

    # Remove the header line and double quotes
    echo "$output" | tail -n +2 | tr -d '"'
}

# Get Neo4j password from environment variable or prompt the user
if [ -z "$NEO4J_PASSWORD" ]; then
    read -s -p "Enter Neo4j password: " NEO4J_PASSWORD
    echo
fi

USERNAME="neo4j"  # Change this if your username is different

# Fetch data from Neo4j using the run_query function
echo "Fetching user samaccountnames..."
run_query 'MATCH (n:User) RETURN DISTINCT n.samaccountname' > user_samaccountnames.txt

echo "Fetching displaynames..."
run_query 'MATCH (n) WHERE n.displayname IS NOT NULL RETURN DISTINCT n.displayname' > displaynames.txt

echo "Fetching names..."
run_query 'MATCH (n) WHERE n.name IS NOT NULL RETURN DISTINCT n.name' > name.txt

echo "Fetching descriptions..."
run_query 'MATCH (n) WHERE n.description IS NOT NULL RETURN DISTINCT n.description' > descriptions.txt

echo "Fetching distinguishedname..."
run_query 'MATCH (n) WHERE n.distinguishedname IS NOT NULL RETURN DISTINCT n.distinguishedname' > distinguishedname.txt

# Combine all data into one file
echo "Combining data..."
cat name.txt user_samaccountnames.txt displaynames.txt descriptions.txt distinguishedname.txt > all_data.txt

# Generate unique wordlist
echo "Generating wordlist..."
cat all_data.txt \
    | tr '[:upper:]' '[:lower:]' \
    | tr ' @_\-/\\.,|()=:' '\n' \
    | tr -s '\n' \
    | sort -u > wordlist.txt

echo "Wordlist generated: wordlist.txt"

# Clean up temporary files
rm name.txt user_samaccountnames.txt displaynames.txt descriptions.txt distinguishedname.txt all_data.txt
