import { getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getMessaging } from 'firebase-admin/messaging';

const projectId = process.env.FIREBASE_PROJECT_ID || 'flashcart-ai';

const app = getApps().length === 0 
  ? initializeApp({ projectId }) 
  : getApps()[0];

export const adminAuth = getAuth(app);
export const adminMessaging = getMessaging(app);

/**
 * Dispatches an FCM push notification securely to a registered device
 */
export async function sendPushNotification(token: string, title: string, body: string, data?: Record<string, string>) {
  try {
    const payload = {
      notification: {
        title,
        body,
      },
      data,
      token,
    };
    const response = await adminMessaging.send(payload);
    console.log('Successfully dispatched FCM push:', response);
    return response;
  } catch (error) {
    console.error('Error sending push notification via FCM:', error);
    throw error;
  }
}
