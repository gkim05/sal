#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~~~ MY SALON ~~~~~\n'
echo -e '\nWelcome to My Salon, how can I help you?'
MAIN_MENU(){


echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $HAVE_CUST ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUST=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
  CUST_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUST_NAME_FORMATTED?"

  read SERVICE_TIME

  INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUST_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUST_NAME_FORMATTED."
fi


}
SERVICE_LIST(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_LIST "I could not find that service. What would you like today?"
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT SERVICE_ID FROM services WHERE SERVICE_ID=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      SERVICE_LIST "I could not find that service. What would you like today?"
    else
      MAIN_MENU
    fi

fi
}
SERVICE_LIST
