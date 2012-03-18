class MemberErrorMessage
  EMAIL_INVALID_FORMAT = "The email must contain @."
  EMAIL_EMPTY = "The email address must not be empty."
  EMAIL_MINIMUM_LENGTH = "The email must contain at least 4 characters."
  EMAIL_MAXIMUM_LENGTH = "The email can contain at most 255 characters."
  EMAIL_NOT_UNIQUE = "The email is already registered with us.<br/>If you forget the password,<br/>please use <a href='/member/forget_password_form'>Forget password</a> to retrieve password."
  
  USERNAME_EMPTY = "The username must not be empty."
  USERNAME_MINIMUM_LENGTH = "The username must contain at least 4 characters."
  USERNAME_MAXIMUM_LENGTH = "The username can contain at most 255 characters."
  USERNAME_NOT_UNIQUE = "The username is already registered with us.<br/>If you forget the password,<br/>please use <a href='/member/forget_password_form'>Forget password</a> to retrieve password."
  
  PASSWORD_EMPTY = "The password must not be empty."
  PASSWORD_CONFIRM_NOTMATCH = "Password confirmation does not match."
  PASSWORD_MAXIMUM_LENGTH = "Password can contain at most 255 characters."

end