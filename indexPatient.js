//  Web3 intializer
//  ABI definition, Binary Data and contract Address in contractDetails.js

var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var kycContract = web3.eth.contract(abi);
var deployedContract = kycContract.new({
    data: binaryData,
    from: web3.eth.accounts[0],
    gas: 4700000
});
var contractInstance = kycContract.at(contractAddress);

function onClickLogin() {
    var username_c = document.getElementById("username").value;
    var password_c = document.getElementById("password").value;
    if (contractInstance.checkCustomer.call(username_c, password_c) == false) {
        alert("Sorry! Invalid username or password.");
        return false;
    }
    //  alert("Welcome "+username_c+" !");
    localStorage.username_c = username_c;
    localStorage.password_c = password_c;
    alert("Welcome " + localStorage.username_c + " !");
    window.location = './patientHomePage.html';
    return false;
}

function onClickSignUp() {
    var username_c = document.getElementById("usernamesignup").value;
    var password_c = document.getElementById("passwordsignup").value;
    var c_password_c = document.getElementById("passwordsignup_confirm").value;
    if (password_c != c_password_c) {
        alert("Wrong password");
        return false;
    }
    if (contractInstance.setPassword.call(username_c, password_c) == false) {
        alert("");
        return false;
    }
    alert("Welcome to Prescripto e-prescription network.");
    contractInstance.setPassword.sendTransaction(username_c, password_c, { from: web3.eth.accounts[0], gas: 4700000 });
    alert("Successfully registered account! Go to the login area to proceed!");
    return false;
}
