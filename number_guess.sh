#!/bin/bash

# ============================================
# Number Guessing Game Script
# FreeCodeCamp Project
# Author: Fahad
# ============================================

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ============================
# Function to check if input is integer
# ============================
check_integer() {
  if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    return 1
  fi
  return 0
}

# ============================
# Ask username
# ============================
echo "Enter your username:"
read USERNAME

# ============================
# Check if user exists
# ============================
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  IFS="|" read USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# ============================
# Generate secret number
# ============================
SECRET=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo "Guess the secret number between 1 and 1000:"

# ============================
# Main guessing loop
# ============================
while true
do
  read GUESS

  # Check integer input
  if ! check_integer "$GUESS"; then
    continue
  fi

  ((TRIES++))

  if [[ $GUESS -gt $SECRET ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
    break
  fi
done

# ============================
# Update database
# ============================
NEW_GAMES=$((GAMES_PLAYED + 1))

if [[ $BEST_GAME -eq 0 || $TRIES -lt $BEST_GAME ]]; then
  UPDATE=$($PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$TRIES WHERE username='$USERNAME'")
else
  UPDATE=$($PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE username='$USERNAME'")
fi
