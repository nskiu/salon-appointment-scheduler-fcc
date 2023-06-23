#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my Salon, how can I help you?\n"

MAIN_MENU(){
  # show services offered
  SERVICE_LIST
  # prompt user to select service
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service selected does not exist
  while [[ -z $SERVICE_NAME ]]
  do
    echo -e "\nI could not find that service. What would you like today?"
    SERVICE_LIST
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  done
  
  # get customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer not in records
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert customer data
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # if something goes wrong
    if [[ !INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
      EXIT "ERROR INSERTING CUSTOMER DATA"
    fi
  fi
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # get user prefered time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?" | sed 's/  / /g'
  read SERVICE_TIME
  # insert appointment data
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  # if something goes wrong
  if [[ !$INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    EXIT "ERROR INSERTING APPOINTMENT DATA"
  fi

  EXIT "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." 
}

SERVICE_LIST(){
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

EXIT(){
  echo -e "\n$1" | sed 's/  / /g'
}

MAIN_MENU