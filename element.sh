#! /bin/bash

if [[ -z "${1:-}" ]]; then
  printf 'Please provide an element as an argument.\n'
  exit 0
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --set=ON_ERROR_STOP=1 -c"

if [[ "$1" =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number=$1"
else
  INPUT_SQL=${1//\'/\'\'}
  CONDITION="e.symbol='$INPUT_SQL' OR e.name='$INPUT_SQL'"
fi

ELEMENT=$($PSQL "
SELECT e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius
FROM elements AS e
JOIN properties AS p ON p.atomic_number=e.atomic_number
JOIN types AS t ON p.type_id=t.type_id
WHERE $CONDITION
LIMIT 1;") || exit 1

if [[ -z "$ELEMENT" ]]; then
  printf 'I could not find that element in the database.\n'
  exit 0
fi

IFS='|' read -r NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$ELEMENT"
printf "The element with atomic number %s is %s (%s). It's a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n" \
  "$NUMBER" "$NAME" "$SYMBOL" "$TYPE" "$MASS" "$NAME" "$MELT" "$BOIL"
