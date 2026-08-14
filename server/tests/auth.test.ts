import { AuthService } from "../services/auth.service";
import { AuthRepository } from "../repositories/auth.repository";
import { hashPassword } from "../utils/auth";
import { DB_STATE } from "../config/dbState";

describe("FlashCart AI Module 1: Authentication Engine Tests", () => {
  const testEmail = "test_developer@flashcart.ai";
  const testPhone = "9988776655";
  const testPassword = "secure_dev_password_123";
  let passwordHash: string;

  beforeAll(async () => {
    passwordHash = await hashPassword(testPassword);
  });

  beforeEach(() => {
    // Reset DB_STATE memory tables for clean test isolation
    (DB_STATE as any).users = [];
    (DB_STATE as any).otps = [];
    (DB_STATE as any).sessions = [];
  });

  test("1. AuthService.registerWithEmailPassword creates user with bcrypt hash & tokens", async () => {
    const result = await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone,
      "USER",
      true
    );

    expect(result).toBeDefined();
    expect(result.user).toBeDefined();
    expect(result.user.email).toBe(testEmail);
    expect(result.user.firstName).toBe("John");
    expect(result.tokens.accessToken).toBeDefined();
    expect(result.tokens.refreshToken).toBeDefined();
    expect(result.user.role).toBe("USER");
  });

  test("2. Duplicate email registration is prevented", async () => {
    await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone
    );

    await expect(
      AuthService.registerWithEmailPassword(
        testEmail,
        passwordHash,
        "Another",
        "Name",
        "1212121212"
      )
    ).rejects.toThrow("Email is already registered");
  });

  test("3. AuthService.loginWithEmailPassword succeeds with correct credentials", async () => {
    await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone
    );

    const loginRes = await AuthService.loginWithEmailPassword(testEmail, undefined, testPassword, true);
    expect(loginRes.user.email).toBe(testEmail);
    expect(loginRes.tokens.accessToken).toBeDefined();
    expect(loginRes.tokens.refreshToken).toBeDefined();
  });

  test("4. AuthService.loginWithEmailPassword fails with invalid password", async () => {
    await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone
    );

    await expect(
      AuthService.loginWithEmailPassword(testEmail, undefined, "wrong_password_xyz")
    ).rejects.toThrow("Invalid credentials");
  });

  test("5. SMS OTP generation and single-use verification workflow", async () => {
    const sendResult = await AuthService.sendOTP(testPhone);
    expect(sendResult.success).toBe(true);

    const otpRecord = await AuthRepository.findLatestOTP(testPhone);
    expect(otpRecord).toBeDefined();
    expect(otpRecord.phone).toBe(testPhone);
    expect(otpRecord.otp.length).toBe(6);

    const verifyResult = await AuthService.verifyOTP(testPhone, otpRecord.otp, false);
    expect(verifyResult).toBeDefined();
    expect(verifyResult.user).toBeDefined();
    expect(verifyResult.tokens.accessToken).toBeDefined();
    expect(verifyResult.isNewUser).toBe(true);

    // Re-use attempt must fail
    await expect(
      AuthService.verifyOTP(testPhone, otpRecord.otp)
    ).rejects.toThrow();
  });

  test("6. Google OAuth Single Sign-On and account link/creation", async () => {
    const googleUid = "GOOGLE_AUTH_ID_883921";
    const result = await AuthService.loginWithGoogle(
      googleUid,
      testEmail,
      "GoogleUser",
      "FlashCart",
      testPhone,
      "https://lh3.googleusercontent.com/photo.png"
    );

    expect(result).toBeDefined();
    expect(result.user.firebaseUid).toBe(googleUid);
    expect(result.user.email).toBe(testEmail);
    expect(result.tokens.accessToken).toBeDefined();
    expect(result.tokens.refreshToken).toBeDefined();
  });

  test("7. Refresh Token Rotation invalidates old session and issues new tokens", async () => {
    const reg = await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone,
      "USER",
      true
    );

    const rotation = await AuthService.refresh(reg.refreshToken);
    expect(rotation.accessToken).toBeDefined();
    expect(rotation.refreshToken).toBeDefined();
    expect(rotation.refreshToken).not.toBe(reg.refreshToken);

    // Old refresh token must no longer be valid
    await expect(
      AuthService.refresh(reg.refreshToken)
    ).rejects.toThrow();
  });

  test("8. Forgot Password and Reset Password workflow", async () => {
    await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone
    );

    const forgotRes = await AuthService.forgotPassword(testEmail);
    expect(forgotRes.success).toBe(true);

    const otpRecord = await AuthRepository.findLatestOTP(testPhone || testEmail);
    expect(otpRecord).toBeDefined();

    const newPasswordHash = await hashPassword("new_secure_pass_456");
    const resetRes = await AuthService.resetPassword(testEmail, otpRecord.otp, newPasswordHash);
    expect(resetRes.success).toBe(true);

    // Logging in with new password should succeed
    const loginRes = await AuthService.loginWithEmailPassword(testEmail, undefined, "new_secure_pass_456");
    expect(loginRes.user.email).toBe(testEmail);
  });

  test("9. Logout invalidates session", async () => {
    const reg = await AuthService.registerWithEmailPassword(
      testEmail,
      passwordHash,
      "John",
      "Doe",
      testPhone
    );

    await AuthService.logout(reg.refreshToken, reg.accessToken, reg.user.id);

    // Using logged out refresh token should fail
    await expect(
      AuthService.refresh(reg.refreshToken)
    ).rejects.toThrow();
  });
});
