from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.views import APIView
from django.core.mail import send_mail
from django.utils.timezone import now
import random

from .models import CustomUser
from .serializers import (
    RegisterSerializer, LoginSerializer, UserSerializer,
    ForgotPasswordSerializer, ResetPasswordSerializer
)


class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        refresh = RefreshToken.for_user(user)
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
        })


class UserProfileView(generics.RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

# Forgot Password View (Generate OTP & Send Email)


class ForgotPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data.get("email")

        # Generate a 6-digit OTP
        otp = str(random.randint(100000, 999999))

        user = get_object_or_404(CustomUser, email=email)
        user.reset_otp = otp
        user.otp_created_at = now()
        user.save()

        # Send OTP via email (Update with your email settings)
        send_mail(
            "Password Reset OTP",
            f"Your OTP for password reset is: {otp}",
            "no-reply@yourapp.com",
            [email],
            fail_silently=False,
        )

        return Response({"message": "OTP sent successfully!"}, status=200)

# Reset Password View (Verify OTP & Reset Password)


class ResetPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"message": "Password reset successful!"}, status=200)
