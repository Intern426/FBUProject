Original App Design Project - README Template
===

# APP_NAME_HERE

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An app that helps you manage your health by letting you see the results of your doctor visits (medications prescribed, lab results, physical results) 

### App Evaluation
- **Category:** Health
- **Mobile:** Can show you the location of your pharmacy pickup you sent it too and it also has a reminder feature that lets you know when your next appointment is
- **Story:** Make it easier for the user to keep track of their health and get their appointments/information all in one location
- **Market:** People who have to juggle around all of doctor appointments will probably need it on a more daily basis - currently, I plan on making it just for one individual but it would probably be useful to add a dependents feature for parents who have multiple kids and want to see that data as well
- **Habit:** Depending on their health, it could be weekly
- **Scope:** Figuring out how to get the location, work out the calendar/notifications for appointments


## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can log in to their account or sign up to create one
* User can view their doctor visits and medications
* User can get information on their medication (pharmacy pickup, side effects, recommended dosage/instruction)
* User can set reminders for their next doctor appointment and get notifications

**Optional Nice-to-have Stories**

* User can write a note about issues/questions they may have for the doctor
* User can get their lab results
* Option for "Kids Mode" that features a lighter palatte and maybe small animal stickers/characters to make it more appealing/relaxing for kids
* Expand it to Dentist and Eye appointments that would have their own seperate page (like for Dentist, it could remind you that your next dentist appointment will involve an X-ray scan)
* Add a feature that would help you find a hospital
* 

### 2. Screen Archetypes

* Login Screen
   * User can log in to their account or sign up to create one
* Registration Screen
    * Users can create an account

* Reminders Screen
    *  User can set reminders for their next doctor appointment and get notifications
* Physical Checkup 
    * User can get information about their physical checkup: eye test, weight, height

* Medication Information
    *  User can get information on their medication (pharmacy pickup, side effects, recommended dosage/instruction)



* OPTIONAL: Lab Results
    * Users can get information about lab results

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Physical Checkups
* Lab Results
* Reminders
* Medications

**Flow Navigation** (Screen to Screen)
* Login Screen
   * Physical Checkup
* Registration Screen
    * Physical Checkup
* Physical Checkup 
    * Go to Medication Info
    * Go to Physical Checkup
* Reminders Screen
    *  Back to Physical Checkup/Medical Checkup (whichever screen you were previously on before selecting the reminders tab)


## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="YOUR_WIREFRAME_IMAGE_URL" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
User

### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]