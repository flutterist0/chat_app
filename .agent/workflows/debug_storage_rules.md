---
description: Check and Fix Firebase Storage Rules
---

If you are encountering `[firebase_storage/object-not-found]` or `The operation was cancelled` during upload, it is highly likely that **Firebase Storage Rules** are blocking the write operation.

1.  Go to **Firebase Console** -> **Storage** -> **Rules**.
2.  Ensure your rules allow authenticated users to write to `user_profiles/{userId}.jpg`.
3.  Replace your rules with this standard setup for testing:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /user_profiles/{userId}.jpg {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Allow read/write for other paths if needed, or global allow for testing (NOT RECOMMENDED FOR PRODUCTION)
    // match /{allPaths=**} {
    //   allow read, write: if request.auth != null;
    // }
  }
}
```

4.  **Wait 1-2 minutes** after publishing rules.
5.  Retry the upload in the app.
