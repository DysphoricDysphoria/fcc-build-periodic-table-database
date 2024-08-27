#!/bin/bash

# Utility func to rename column name in specified table
REMOVE_LEADING_AND_TRAILING_SPACES() {
  local result="$(echo $1 | sed -r 's/^ *| $//g')" # remove leading and trailing space
  echo $result
}

ELEMENT_IDENTIFIER=$(REMOVE_LEADING_AND_TRAILING_SPACES "$1")

# Echo message if element identifier is empty
if [[ -z "$ELEMENT_IDENTIFIER" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Variable to connect to the 'periodic_table' database
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

PSQL_QUERY="SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE "

if [[ $ELEMENT_IDENTIFIER =~ ^-?[0-9]+$ ]]; then
  PSQL_QUERY+="atomic_number = $ELEMENT_IDENTIFIER;"
else
  PSQL_QUERY+="symbol = '$ELEMENT_IDENTIFIER' OR name = '$ELEMENT_IDENTIFIER';"
fi

# Find element by atomic number, symbol or name
ELEMENT=$($PSQL "$PSQL_QUERY")

# Check if element is empty
if [[ -z "$ELEMENT" ]]; then
  echo "I could not find that element in the database."
else
  # Display element information
  echo "$ELEMENT" | while IFS="|" read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE; do
    ATOMIC_MASS=$(REMOVE_LEADING_AND_TRAILING_SPACES $ATOMIC_MASS)
    ATOMIC_NUMBER=$(REMOVE_LEADING_AND_TRAILING_SPACES $ATOMIC_NUMBER)
    BOILING_POINT=$(REMOVE_LEADING_AND_TRAILING_SPACES $BOILING_POINT)
    MELTING_POINT=$(REMOVE_LEADING_AND_TRAILING_SPACES $MELTING_POINT)
    NAME=$(REMOVE_LEADING_AND_TRAILING_SPACES $NAME)
    SYMBOL=$(REMOVE_LEADING_AND_TRAILING_SPACES $SYMBOL)
    TYPE=$(REMOVE_LEADING_AND_TRAILING_SPACES $TYPE)
    TYPE_ID=$(REMOVE_LEADING_AND_TRAILING_SPACES $TYPE_ID)
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi
