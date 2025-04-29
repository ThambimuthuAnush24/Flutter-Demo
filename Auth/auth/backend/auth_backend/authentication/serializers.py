from django.utils.timezone import now
from datetime import timedelta
from rest_framework import serializers
from .models import CustomUser
from django.contrib.auth.hashers import check_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'phone_number', 'full_name']

class RegisterSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'password',
                  'confirm_password', 'phone_number', 'full_name']
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords do not match")
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = CustomUser.objects.create_user(**validated_data)
        return user

# ✅ Fixed LoginSerializer
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data["email"]
        password = data["password"]

        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Invalid credentials")

        # Verify the password
        if not check_password(password, user.password):
            raise serializers.ValidationError("Invalid credentials")

        return {"user": user}

# Forgot Password Serializer (Sends OTP)
class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate(self, data):
        email = data.get("email")
        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError(
                "User with this email does not exist.")

        # Generate OTP
        user.generate_otp()
        return {"message": "OTP sent successfully!"}

# Reset Password Serializer (Verify OTP & Reset Password)
class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)
    new_password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get("email")
        otp = data.get("otp")
        new_password = data.get("new_password")
        confirm_password = data.get("confirm_password")

        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("User not found.")

        # Check if OTP matches
        if user.reset_otp != otp:
            raise serializers.ValidationError("Invalid OTP.")

        # Check if OTP is expired (valid for 10 minutes)
        if user.otp_created_at and now() - user.otp_created_at > timedelta(minutes=10):
            raise serializers.ValidationError(
                "OTP expired. Request a new one.")

        # Check password match
        if new_password != confirm_password:
            raise serializers.ValidationError("Passwords do not match.")

        return data

    def save(self):
        email = self.validated_data["email"]
        new_password = self.validated_data["new_password"]
        user = CustomUser.objects.get(email=email)

        # Reset password and clear OTP
        user.set_password(new_password)
        user.reset_otp = None
        user.otp_created_at = None
        user.save()
        return {"message": "Password reset successful!"}
