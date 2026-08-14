# FlashCart AI - Production Deployment Guide

This document describes the steps required to deploy the complete FlashCart AI ecosystem into a high-availability production cloud, compile native mobile application packages, and publish them to app stores.

---

## 1. Hosting Architecture Overview

```
 [ Shopper (Flutter iOS/Android) ] <---> [ Cloud Run load balancer ]
                                                  |
                                                  v
 [ Rider App (Flutter Mobile) ]    <---> [ Node.js Service (Express/Socket.IO) ]
                                                  |
                                                  +---> [ PostgreSQL / Cloud SQL ]
                                                  +---> [ Firebase Admin FCM / Auth ]
```

---

## 2. Deploying the Backend (Google Cloud Run / AWS ECS)

Because the backend is compiled into a lightweight TypeScript Node.js image, deploying it as a serverless container is highly recommended.

### Steps for Google Cloud Run:
1. **Containerize Service**: Navigate to `/backend` and build the Docker image:
   ```bash
   docker build -t gcr.io/flashcart-ai/api-service:latest .
   ```
2. **Push to Artifact Registry**:
   ```bash
   docker push gcr.io/flashcart-ai/api-service:latest
   ```
3. **Deploy Container**:
   ```bash
   gcloud run deploy flashcart-api-service \
     --image gcr.io/flashcart-ai/api-service:latest \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --port 3000 \
     --set-env-vars="NODE_ENV=production,PORT=3000"
   ```

---

## 3. Configuring Production Cloud SQL (PostgreSQL)

1. Create a **Cloud SQL for PostgreSQL** instance in Google Cloud Platform.
2. Configure **Private IP (VPC Peering)** to allow Cloud Run containers to access the database securely with sub-millisecond latencies.
3. Inject Database Secret Credentials into Cloud Run using Secret Manager (do not declare password variables in plain-text environment arrays).

---

## 4. Mobile Compilation & App Store Publishing (Flutter)

### A. Android Build & Publishing
1. **Keystore Generation**: Generate a secure upload keystore to sign the release build:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. **Configure build configuration**: Reference your keystore credentials in `/mobile/android/key.properties`.
3. **Build Android App Bundle (AAB)**:
   ```bash
   cd mobile
   flutter build appbundle --release
   ```
4. **Publish to Google Play Store**:
   * Open the **Google Play Console**.
   * Create an application and navigate to **Production**.
   * Upload the resulting `.aab` file located in `build/app/outputs/bundle/release/app-release.aab`.

### B. iOS Build & Publishing
1. **Certificates & Profiles**: Register your App ID and bundle identifiers in the Apple Developer portal. Generate an **iOS Distribution Certificate** and a **Provisioning Profile**.
2. **Xcode Configuration**: Open `/mobile/ios` in Xcode on a macOS workstation. Ensure the Bundle Identifier matches your profile.
3. **Build Native Archive**:
   ```bash
   cd mobile
   flutter build ipa --release
   ```
4. **Distribute via App Store Connect**:
   * Use the **Transporter** application or Xcode Organizer to upload the generated `.ipa` archive file to **App Store Connect**.
   * Configure app store graphics, metadata, and submit the release build for App Review.
