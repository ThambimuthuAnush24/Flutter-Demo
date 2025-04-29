import random
from django.utils.timezone import now
from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    phone_number = models.CharField(max_length=15, unique=True, null=True, blank=True)
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255, null=True, blank=True)

    # Fields for OTP
    reset_otp = models.CharField(max_length=6, null=True, blank=True)
    otp_created_at = models.DateTimeField(null=True, blank=True)

    # Additional fields for password confirmation
    password_confirmation = models.CharField(max_length=128, null=True, blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email

    def generate_otp(self):
        # Generate 6-digit OTP
        self.reset_otp = str(random.randint(100000, 999999))  # Example: "485729"
        self.otp_created_at = now()
        self.save()

    def save(self, *args, **kwargs):
        # Ensure password and password_confirmation match before saving
        if self.password and self.password_confirmation and self.password != self.password_confirmation:
            raise ValueError("Password and Confirm Password do not match")
        super().save(*args, **kwargs)