Original App Design Project - README Template
===

# Rx Keeper

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
2. [Demos](#Demos)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
An app that helps you manage your prescriptions by allowing you to see a list of prescriptions offered at Walgreens with their prices (Link to PDF: https://www.walgreens.com/images/adaptive/pdf/Walgreens-Plus_Drug-List_20180321.pdf, Information used starts on Page 5), lets you favorite/save the ones you're interested in, locate nearby Walgreens, and purchase the drugs.

### App Evaluation
- **Category:** Health
- **Mobile:** Can show you the location of nearby pharmacies and reminds you when to take your medications
- **Story:** Makes it easier for the user to keep track of their prescription information/reminders in one app
- **Market:** People who want help managing their prescriptions and buying them at Walgreens. 
- **Habit:** Depending on their health, interaction will probably only happen monthly but if they decide to use the reminders, then they'll use the app daily just to remember to take their medication
- **Scope:** 
    * Getting the location of Pharmacies - Utilize the Walgreens Store Locator API
    * Reminders and Alarms will be setup on your phone 
    * Integrates the openFDA API and uses RxNorm API to get more detailed information on a drug

## Demos
![](https://i.imgur.com/1hwEWbM.gif)
![](https://i.imgur.com/Z9XJJfc.gif)
![](https://i.imgur.com/N7I43VN.gif)
![](https://i.imgur.com/IimKZbl.gif)
![](https://i.imgur.com/Btu36Yy.gif)



## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can log in to their account or sign up to create one
* User can see list of prescriptions and their prices/pharamcies (using the GoodRX API)
* User can view a personal list of the prescriptions they liked/need 
* User can get daily reminders for when you should take your prescription - so if you want to do it at 6:00 PM daily, it'll alert you at the time and provide some information about the prescription you should be taking
* Checkout feature

**Optional Nice-to-have Stories**
*  User can get more information on their medication (side effects, recommended dosage/instruction, price)
*  Recommendation Feature Based on Price/Availability, Maybe evne recommend based on health issue (i.e. headache, diahrrea)
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
| brand_name| String | brand name of the prescription|
| generic_name| String | generic name of the prescription
| dosage | Number | number containing the quantity of the prescription |
| price | Number | price of the prescription 
| ** active_ingredient| String | main ingredient in the drug
| ** inactive_ingredients | String | stores the other inactive ingredients that make up the prescription (optional)|

** Part of the optionals


*User*

| Property | Type | Descripton |
| -------- | -------- | -------- |
| objectID | String     | unique ID for the user (default field)    |
| address      | String  | Contains user's home location for possible implementation of delivery and to help with the searching of pharmacies|
| savedDrugs | Array of Strings | Holds the names of the drugs they're interested in|
| buyingDrugs | Array of Arary of Strings | Holds the names of the drugs they're interested in buying - along with the dosage amount and manufacturer|

**Networking**

List of network requests by screen

* Profile Screen
    * (Read/GET - Parse) Query all favorited prescriptions by user

* Prescription Screen
    * (Create/POST - Parse) Update user - add another prescription to favorited list
    * (Delete - Parse) Delete favorited prescription
    * (Read/GET - openFDA) Collect data on drugs

* Pharamcy Map Screen
    * (Read/GET - MapKit and Walgreen Store Locator API) Find location of pharamacy based on current location 
