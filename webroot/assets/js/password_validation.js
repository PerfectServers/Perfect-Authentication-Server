function validatePassword(){
    var password = document.getElementById("password").value;
    var confirmPassword = document.getElementById("confirm_password").value;
    if (password != confirmPassword) {
        document.getElementById("password-msg").innerHTML = "Passwords Don't Match";
        return false;
    }
    return true;
}
