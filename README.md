# bh2wordlist

A Bash script to extract and generate a unique wordlist from a bloodhound Neo4j database using `cypher-shell`.

## Prerequisites
- Bash
- Neo4j with `cypher-shell` accessible

## Setup
Ensure `cypher-shell` is installed and the Neo4j password is either set as an environment variable (`NEO4J_PASSWORD`) or be prompted.

## Usage
Run the script in your terminal and it will generate wordlist.txt in the same folder:
```bash
./bh2wordlist
```
