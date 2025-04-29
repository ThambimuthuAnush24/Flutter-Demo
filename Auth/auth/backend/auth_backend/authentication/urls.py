from django.urls import path
from .views import (
    RegisterView, LoginView, UserProfileView,
    ForgotPasswordView, ResetPasswordView
)

app_name = 'authentication' 

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
]