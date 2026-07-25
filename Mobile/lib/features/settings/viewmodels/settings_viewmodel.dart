import 'package:flutter/material.dart';
import 'package:gaspika_mobile/constants/enums/enums.dart';
import 'package:gaspika_mobile/models/auth_model.dart';
import 'package:gaspika_mobile/models/domains-object/notification_preference.dart';
import 'package:gaspika_mobile/models/domains-object/user.dart';
import 'package:gaspika_mobile/models/schemas/change_password_schema.dart';
import 'package:gaspika_mobile/models/schemas/notification_preference_schema.dart';
import 'package:gaspika_mobile/models/schemas/update_user_schema.dart';
import 'package:gaspika_mobile/models/user_model.dart';

class SettingsViewmodel extends ChangeNotifier {
  final UserModel _userModel = UserModel();
  final AuthModel _authModel = AuthModel();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController deletePasswordController =
      TextEditingController();

  bool _isLoadingUser = true;
  User? _user;
  bool _hasError = false;
  String _errorMessage = '';
  NetworkErrorType? _errorType;

  bool _isUpdatingUser = false;
  bool _hasUpdateUserError = false;
  String _updateUserErrorMessage = '';
  NetworkErrorType? _updateUserErrorType;

  bool _isChangingPassword = false;
  bool _hasChangePasswordError = false;
  String _changePasswordErrorMessage = '';
  NetworkErrorType? _changePasswordErrorType;

  bool _isLoadingPreferences = true;
  NotificationPreference? _preferences;
  bool _hasPreferencesError = false;
  String _preferencesErrorMessage = '';
  NetworkErrorType? _preferencesErrorType;

  bool _isUpdatingPreferences = false;
  bool _hasUpdatePreferencesError = false;
  String _updatePreferencesErrorMessage = '';

  bool _isDeletingAccount = false;
  bool _hasDeleteAccountError = false;
  String _deleteAccountErrorMessage = '';
  NetworkErrorType? _deleteAccountErrorType;

  // Getters
  bool get isLoadingUser => _isLoadingUser;
  User? get user => _user;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  NetworkErrorType? get errorType => _errorType;

  bool get isUpdatingUser => _isUpdatingUser;
  bool get hasUpdateUserError => _hasUpdateUserError;
  String get updateUserErrorMessage => _updateUserErrorMessage;
  NetworkErrorType? get updateUserErrorType => _updateUserErrorType;

  bool get isChangingPassword => _isChangingPassword;
  bool get hasChangePasswordError => _hasChangePasswordError;
  String get changePasswordErrorMessage => _changePasswordErrorMessage;
  NetworkErrorType? get changePasswordErrorType => _changePasswordErrorType;

  bool get isLoadingPreferences => _isLoadingPreferences;
  NotificationPreference? get preferences => _preferences;
  bool get hasPreferencesError => _hasPreferencesError;
  String get preferencesErrorMessage => _preferencesErrorMessage;
  NetworkErrorType? get preferencesErrorType => _preferencesErrorType;

  bool get isUpdatingPreferences => _isUpdatingPreferences;
  bool get hasUpdatePreferencesError => _hasUpdatePreferencesError;
  String get updatePreferencesErrorMessage => _updatePreferencesErrorMessage;

  bool get isDeletingAccount => _isDeletingAccount;
  bool get hasDeleteAccountError => _hasDeleteAccountError;
  String get deleteAccountErrorMessage => _deleteAccountErrorMessage;
  NetworkErrorType? get deleteAccountErrorType => _deleteAccountErrorType;

  String get fullName => '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}';

  // Clear all errors
  void clearAllErrors() {
    _hasError = false;
    _errorMessage = '';
    _errorType = null;

    _hasUpdateUserError = false;
    _updateUserErrorMessage = '';
    _updateUserErrorType = null;

    _hasChangePasswordError = false;
    _changePasswordErrorMessage = '';
    _changePasswordErrorType = null;

    _hasPreferencesError = false;
    _preferencesErrorMessage = '';
    _preferencesErrorType = null;

    _hasUpdatePreferencesError = false;
    _updatePreferencesErrorMessage = '';

    _hasDeleteAccountError = false;
    _deleteAccountErrorMessage = '';
    _deleteAccountErrorType = null;

    notifyListeners();
  }

  // Get user info
  Future fetchUserInfo() async {
    _isLoadingUser = true;
    _hasError = false;
    _errorMessage = '';
    _errorType = null;
    notifyListeners();

    final response = await _userModel.getUserInfo();

    if (response.hasError == true) {
      _isLoadingUser = false;
      _hasError = true;
      _errorType = response.errorType;
      _errorMessage = response.message!;
      notifyListeners();
      return;
    }

    _user = response.data!;
    hydrateUserFields();
    _isLoadingUser = false;
    notifyListeners();
  }

  // Update user info
  Future updateUserInfo() async {
    _isUpdatingUser = true;
    _hasUpdateUserError = false;
    _updateUserErrorMessage = '';
    _updateUserErrorType = null;
    notifyListeners();

    final response = await _userModel.updateUserInfo(
      UpdateUserSchema(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
      ),
    );

    if (response.hasError == true) {
      _isUpdatingUser = false;
      _hasUpdateUserError = true;
      _updateUserErrorType = response.errorType;
      _updateUserErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _user = response.data!;
    hydrateUserFields();
    _isUpdatingUser = false;
    notifyListeners();
  }

  // Change password
  Future changePassword() async {
    _isChangingPassword = true;
    _hasChangePasswordError = false;
    _changePasswordErrorMessage = '';
    _changePasswordErrorType = null;
    notifyListeners();

    final response = await _userModel.changePassword(
      ChangePasswordSchema(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      ),
    );

    if (response.hasError == true) {
      _isChangingPassword = false;
      _hasChangePasswordError = true;
      _changePasswordErrorType = response.errorType;
      _changePasswordErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _isChangingPassword = false;
    resetPasswordFields();
  }

  // Get notification preferences
  Future fetchNotificationPreferences() async {
    _isLoadingPreferences = true;
    _hasPreferencesError = false;
    _preferencesErrorMessage = '';
    _preferencesErrorType = null;
    notifyListeners();

    final response = await _userModel.getNotificationPreferences();

    if (response.hasError == true) {
      _isLoadingPreferences = false;
      _hasPreferencesError = true;
      _preferencesErrorType = response.errorType;
      _preferencesErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _preferences = response.data!;
    _isLoadingPreferences = false;
    notifyListeners();
  }

  // Toggle a notification preference
  Future togglePreference({
    bool? pushEnabled,
    bool? foodExpirationEnabled,
    bool? listExpirationEnabled,
  }) async {
    if (_preferences == null) return;

    final previousPreferences = _preferences;

    _preferences = _preferences!.copyWith(
      pushEnabled: pushEnabled,
      foodExpirationEnabled: foodExpirationEnabled,
      listExpirationEnabled: listExpirationEnabled,
    );
    _isUpdatingPreferences = true;
    _hasUpdatePreferencesError = false;
    _updatePreferencesErrorMessage = '';
    notifyListeners();

    final response = await _userModel.updateNotificationPreferences(
      NotificationPreferenceSchema(
        pushEnabled: pushEnabled,
        foodExpirationEnabled: foodExpirationEnabled,
        listExpirationEnabled: listExpirationEnabled,
      ),
    );

    if (response.hasError == true) {
      // rollback
      _preferences = previousPreferences;
      _isUpdatingPreferences = false;
      _hasUpdatePreferencesError = true;
      _updatePreferencesErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _preferences = response.data!;
    _isUpdatingPreferences = false;
    notifyListeners();
  }

  // Delete account
  Future deleteAccount() async {
    _isDeletingAccount = true;
    _hasDeleteAccountError = false;
    _deleteAccountErrorMessage = '';
    _deleteAccountErrorType = null;
    notifyListeners();

    final response = await _userModel.deleteAccount(
      deletePasswordController.text,
    );

    if (response.hasError == true) {
      _isDeletingAccount = false;
      _hasDeleteAccountError = true;
      _deleteAccountErrorType = response.errorType;
      _deleteAccountErrorMessage = response.message!;
      notifyListeners();
      return;
    }

    _isDeletingAccount = false;
    resetAllStates();
  }

  // Logout
  Future logout() async {
    await _authModel.logout();

    resetAllStates();
  }

  // Fill the form fields with the current user
  void hydrateUserFields() {
    firstNameController.text = _user?.firstName ?? '';
    lastNameController.text = _user?.lastName ?? '';
    emailController.text = _user?.email ?? '';
  }

  // Clear the password fields
  void resetPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    notifyListeners();
  }

  // reset all states
  void resetAllStates() {
    _user = null;
    _preferences = null;
    _isLoadingUser = true;
    _isLoadingPreferences = true;
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    deletePasswordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    deletePasswordController.dispose();
    super.dispose();
  }
}
