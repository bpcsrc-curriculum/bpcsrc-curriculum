# SRC Viewer

The SRC Viewer is a web app developed using the Flutter framework that shows approved SRC curriculum submissions from BPCA SRC members.

This repository is hosted online at [https://curriculum.bpcsrc.org/](https://curriculum.bpcsrc.org/).

## Installing and Running

1. Install the latest release of [Flutter](https://docs.flutter.dev/get-started/install?_gl=1*11bkqd3*_gcl_aw*R0NMLjE3NDEyOTgyNTMuQ2p3S0NBaUFyS1ctQmhBekVpd0FaaFdzSUNYd3JPZlhKTjQtQzIySnI0eUg3U0lnQlNxM0Q2amNsNURxY2dsQTJjVWw4YXpUaURrSWVob0NSbUFRQXZEX0J3RQ..*_gcl_dc*R0NMLjE3NDEyOTgyNTMuQ2p3S0NBaUFyS1ctQmhBekVpd0FaaFdzSUNYd3JPZlhKTjQtQzIySnI0eUg3U0lnQlNxM0Q2amNsNURxY2dsQTJjVWw4YXpUaURrSWVob0NSbUFRQXZEX0J3RQ..*_ga*NTY2NjU2MDI4LjE3MzMyNTc2MTE.*_ga_04YGWK0175*MTc0MTMwMzc1MC43LjEuMTc0MTMwMzc2MC4wLjAuMA..), which will require you to install Android Studio along the way. When running `flutter doctor` in a terminal instance, all checks should pass.

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.29.1, on Microsoft Windows [Version 10.0.22631.4890], locale en-US)
[✓] Windows Version (11 Home 64-bit, 23H2, 2009)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.13.2)
[✓] Android Studio (version 2023.2)
[✓] VS Code (version 1.98.0)
[✓] Connected device (3 available)
[✓] Network resources
```

1. Clone the project.
2. In Android Studio, open the project at `/src_viewer` (not the project root)
3. Run `flutter pub get` in an Android Studio terminal instance.
4. Confirm that no compilation errors occur.
5. Configure the testing environment to "Chrome (Web)".

![](/README_pictures/Screenshot%202025-03-06%20145449.png)

6. Run the project. A new chrome browser window should appear.

## Deployment Procedures

Deploying the project requires a small bit of finessing.

1. A GitHub action is written for this project that should automatically build the flutter project as a website. If no errors occur, the action will create a branch in `origin/gh-pages`.

After confirming that the deployment action on the `gh-pages` branch is complete, you may check the website at [https://curriculum.bpcsrc.org/](https://curriculum.bpcsrc.org/).

However, it is oddly common for one of two (sometimes both) issues to occur, that may result in a 404 error. The exact solution to both problems has yet to be correctly addressed.

### 1. Incorrect Path Structure

1. Look at the `index.html` file in the `gh-pages` branch.

![](/README_pictures/Screenshot%202025-03-06%20150201.png)

2. Locate line 17 and modify `href` to use relative pathing (`./`) instead of absolute pathing (`/`).

![](/README_pictures/Screenshot%202025-03-06%20150228.png)

3. Afterwards, commit your changes.

![](/README_pictures/Screenshot%202025-03-06%20150233.png)

4. Wait for deployment to complete and check again.

### 2. DNS Loss

Weirdly, GitHub may remove the domain name assigned to the repository after pushing changes.

1. In the "Settings" page for the repository, locate the "Pages" section and check that the "Custom domain" was not reset. If it was, reassign the domain using `"curriculum.bpcsrc.org"`.

![](/README_pictures/Screenshot%202025-03-06%20150259.png)

2. Wait for the DNS check to resolve.

![](/README_pictures/Screenshot%202025-03-06%20150317.png)

![](/README_pictures/Screenshot%202025-03-06%20150323.png)

3. Assigning a new domain name will cause a change to be pushed to the `gh-pages` branch called `Create CNAME`. Wait for it to resolve and then check again after a few minutes.

## How Data is Added

Since the curriculum viewer reads off of submitted data, it is important to understand how data gets to the web app in the first place.

1. A member submits an entry using this [Google Form](https://docs.google.com/forms/d/e/1FAIpQLSfAN2FaAys-0DZd4W-a8y5M3V8r32NY7zg9ms7pBsv8oWfFQg/viewform).
2. The Google Form automatically adds a new row to a Google Sheet spreadsheet, found [here](https://docs.google.com/spreadsheets/d/1KnS93CZm1e3N0VMQyGoh_iZ65P16Dod8LokyT-VqhxM/edit?resourcekey=&gid=2127720475#gid=2127720475).
3. A Google Apps script attached to the spreadsheet will trigger whenever a new row is added, which adds a Firestore document to a Firebase instance.

The app reads and interacts with the data in the following way:

1. When visiting the main page, the app reads the documents from Firestore, but only those where the `Approved` field is `"APPROVED"`.
2. When a user clicks on a lesson, a table loads based on the document fields. As these documents have no set schema, the fields to load are based on a configurable list of fieldNames stored in `misc.dart` (see `fieldsToShowInTable`). It is done this way to future-proof from possible requests to modify what kinds of questions are asked in the form.
3. Users can approve submissions by going to the bottom left, clicking "Approve", and entering password "SRCManagement!01".

## File Explanation

- **firebase_options.dart** -- The config for Firebase.
- **main.dart** -- Runs the app.
- **misc.dart** -- Contains mainly frontend information such as what fields there are, and which ones are used in the app.

### Classes

- **RefreshNotifier.dart** -- A Singleton used by components to "refresh" the data read from Firestore.
- **IRefresh.dart** -- Interface for the Refresh singleton.
- **LessonEntry.dart** -- A data container for lesson submissions that are stored in Firestore. 
- **SubmissionField.dart** -- A data container used for frontend, which contains a value and a string describing what it represents. `misc.dart` supplies these values.

### Modals

- **LessonApprovalModal.dart** -- A modal used to show a lesson's content and approve it.
- **LessonEntryModal.dart** -- A modal used to show an approved lesson.
- **PasswordEntryModal.dart** -- A modal used to wall off entry into the approval section of the web app.

### Screens

- **display.dart** -- The main screen.
- **publish.dart** -- The approval screen.

### Widgets

- **LessonApprovalWidget.dart** -- A widget used in ListViews to show previews of approved lessons.
- **LessonEntryWidget** -- A widget used in ListViews to show previews of submitted lessons that require approval.
