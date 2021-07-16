Original App Design Project - README Template
===

# Prescription Helper

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
2. [Demos](#Demos)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
An app that helps you manage your prescriptions by allowing you to see a list of prescriptions offered by the GoodRX API, lets you favorite/save the ones you're interested in and can help you locate nearby pharmacies. 

### App Evaluation
- **Category:** Health
- **Mobile:** Can show you the location of nearby pharmacies you and it also has a reminder feature that lets you know when to take your next medication
- **Story:** Make it easier for the user to keep track of their prescription information/reminders in one app
- **Market:** People who want more information on their prescriptions and find pharmacies
- **Habit:** Depending on their health, heavy interaction will probably only happen monthly but if they decide to use the reminders, then they'll use the app daily just to remember to take their medication
- **Scope:** 
    * Getting the location of Pharmacies - one generic way could be utilizing a Map API like Google and just having the user insert their location than return nearby pharacies that way. 
        * While I'm not sure if there's a way to get this information currently (asides from having to actually call), it would be nice to implement a feature that tells you if the medication is actually in stock
    * Reminders and Alarms will be setup on your phone 
    * Integrating multiple Drug APIs... initialy I find the GoodRX because I thought it would be useful for the user to get prescriptions and find a reasonable cost -- however, GoodRX doesn't supply any information about the drug (beyond name, manufacturer, price and pharmacy) so I'm hoping to utilize another API like RxNorm API to retreive information about the ingredients in the drug and other information that the user might be interested in

## Demos

-Using dummy data for the prescriptions

![](https://i.imgur.com/KToNJLn.gif)



## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can log in to their account or sign up to create one
* User can see list of prescriptions, and their prices/pharamcies (using the GoodRX API)
* User can view a personal list of the prescriptions they liked/need 
* User can get daily reminders for when you should take your prescription - so if you want to do it at 6:00 PM daily, it'll alert you at the time and provide some information about the prescription you should be taking
* Recommendation Feature Based on Price/Availability, Maybe evne recommend based on health issue (i.e. headache, diahrrea)
* Delivery Schedule 

**Optional Nice-to-have Stories**
*  User can get more information on their medication (side effects, recommended dosage/instruction, price)
*  Under the Reminders Tab, keep track of quantity (like if a prescription starts with a 100 tablets, each time user takes medication, decrease by 1 and when you get around 10% or something, alert user that it's time to refill)
* Add an "Emergency Feature" that would help you find the nearest hospital and provide phone number information --> information about hospital gathered using Community Health API
* User can write a note about issues/questions they may have for the doctor

### 2. Screen Archetypes

* Login Screen
   * User can log in to their account or sign up to create one
 
* Registration Screen
    * Users can create an account

* Reminders Screen
    *  User can set reminders for when they have to take their prescription

* Prescription List Screen
    * User can see all the medications/prescription listed in the GoodRX database

* Details Screen
    *  User can get detailed information on their medication (pharmacy, side effects, recommended dosage/instruction, price)

* Locator Screen
    * User can find nearby pharmacies

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Prescription List
* Profile/Personal Prescription List
* Reminders
* Details List

**Flow Navigation** (Screen to Screen)
* Login Screen
   * Prescription List
* Registration Screen
    * Prescription List
* Prescription List
    * Go to Details Info
    * Go to Personal Prescription List
    * Go to Reminders Screen
* Details Info
    *  Back to Whole Prescription List/Personal Prescription List (whichever screen you were previously on before selecting the reminders tab)
    *  Go to Locator Screen (.... might have this on the starter screen instead actually)
* Reminders Screen
    * Go back to Profile


## Wireframes
Digital Wireframe: https://ninjamock.com/s/GST5TJx
![](https://i.imgur.com/ikpBnhi.png)


## Schema

**Models** 

*Prescription*

| Property | Type | Descripton |
| -------- | -------- | -------- |
| name     | String     | name of the prescription (required)     |
| ndc      | String (Number?)  | Unique code for a prescription (written out like a phone number) (required)
| dosage | Number | number containing the quantity of the prescription |
| price | Number | price of the prescription 
| price_pharamcy | String | name of the pharmacy that holds the prescription at the specified price |
| active_ingredient| String | main ingredient in the drug
| warning| String | a string that discusses the side effects as a result of the main ingredient**| 
| inactive_ingredients | Array of Strings? | stores the other inactive ingredients that make up the prescription (optional)|

** Written in paragraph format - information offered by the openFDA API, a drug API that doesn't require authentication


*User*

| Property | Type | Descripton |
| -------- | -------- | -------- |
| objectID | String     | unique ID for the user (default field)    |
| address      | String  | Contains user's home location for possible implementation of delivery and to help with the searching of pharmacies|
| array_ndc | Array of Strings | Holds the NDC codes for prescriptions the user liked/favorited to facilitate the gathering of information across APIs|

**Networking**

List of network requests by screen

* Profile Screen
    * (Read/GET) Query all favorited prescriptions by user

* Prescription Screen
    * (Create/POST) Update user - add another prescription to favorited list
    * (Delete) Delete favorited prescription
    * (Read/GET) Collect data on drugs

* Pharamcy Map Screen
    * (Read/GET) Find location of pharamacy based of home address (or whatever location you put down in profile) or ask for current location
