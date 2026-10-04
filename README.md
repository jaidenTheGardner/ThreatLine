# ThreatLine

## Project Overview
ThreatLine is an incident-logging and triage tool for an informal security point of contact within small organisations without a dedicated SOC or IT security team. Turning small vulnerabilities into a tracked and timestamped queue.


## Domain Context
**Primary Stakeholder:** Designated security point of contact within a small organisation. 

**Problem:** Without a specialised tool reported phishing and suspicious content that arrives over Email gets noted informally, leading to genuine threats being unresolved or lost due to poor recording.

**Human Cost:** Time from having to manoeuvre through unorganised reports, risk and missed information from real threats being missed.


## Architecture Summary
**ThreatLineCore:** Domain Models, protocols, errors and use cases
**ThreatLinePersistence:** Core Data Stack
**ThreatLineUI:** SwiftUI views and view models

For full architecture diagram and primary use case data flow see attached pdf file (Advanced iOS Development Assessment 3 - Project 2: Platform-Integrated Solution)


## Chosen Extensions and justifications

**Share Extension** - Allows direct sharing of suspicious content from Mail/ Messages/ Safari into ThreatLine.
**Widget** - Shows open-incidnet count and SLA-breach status at a glance providing quick information.


## Database choice: Core Data

Chosen over CloudKit for its offline first private storage, sharing sensitive incident data only as far as the device's own App Group. Making it more ideal for a security based application.


## App Group identifier

group.com.jaidengardner.threatline

This requirements could not function as the university computers prevented Apple Account creation or sign in.


## Setup Instructions
When opening in XCode use the 'ThreatLine' folder next to the XCode project file, inside the initial ThreatLine folder. Extension capability has been commented out for project testing due to the issue related to not being able to sign into an Apple Account. To enable extensions follow the instructions below:
1. **Register App Group:** Log into your Apple Account, then in 'Main App Target' navigate to the signing and capabilities menu, '+ Capability' and check App Groups.
2. **Add the Widget Extension Target:** Navigate through File -> New -> Target -> Widget Extension. Afterwards replace the automatically generated file with ThreatLineWidget.swift, then in the signing and capabilities menu of the Project file's 'Widget Extension' menu navigate to Signing and Capabilities, '+ Capability' and check App Groups.
3. **Add the share Extension Target:** Navigate through File -> New -> Target -> Share Extension. Afterwards replace the automatically generated file with ShareViewController.swift, then in the signing and capabilities menu of the Project file's 'Share Extension' menu navigate to Signing and Capabilities, '+ Capability' and check App Groups.
4. **Remove Comments:** Remove the comment marks to re-enable the code
