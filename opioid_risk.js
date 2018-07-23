// JavaScript source code
function doSubmit() {
    var genderDropbox=document.getElementById("gender");
	var gender=genderDropbox.options[genderDropbox.selectedIndex].value;
    if (gender=="0") {
        alert("ERROR: Please select patient's gender");
        return false;
    } 
	else{
		return true;
	}
}

function scoreAssess(){
	var score=0;
	switch(gender){
		case "2":
			if(document.getElementById("1a").checked){
				score+=1;
				console.log("1a");
			}
			if(document.getElementById("1b").checked){
				score+=2;
				console.log("1a");
			}
			if(document.getElementById("1c").checked){
				score+=4;
				console.log("1a");
			}
			if(document.getElementById("2a").checked){
				score+=3;console.log("1a");
			}
			if(document.getElementById("2b").checked){
				score+=4;
			}
			if(document.getElementById("2c").checked){
				score+=5;
			}
			if(document.getElementById("3a").checked){
				score+=1;
			}
			if(document.getElementById("4a").checked){
				score+=3;
			}
			if(document.getElementById("5a").checked){
				score+=2;
			}
			if(document.getElementById("5b").checked){
				score+=1;
			}

		case "1":
			if(document.getElementById("1a").checked){
				score+=3;
			}
			if(document.getElementById("1b").checked){
				score+=3;
			}
			if(document.getElementById("1c").checked){
				score+=4;
			}
			if(document.getElementById("2a").checked){
				score+=3;
			}
			if(document.getElementById("2b").checked){
				score+=4;
			}
			if(document.getElementById("2c").checked){
				score+=5;
			}
			if(document.getElementById("3a").checked){
				score+=1;
			}
			if(document.getElementById("4a").checked){
				score+=0;
			}
			if(document.getElementById("5a").checked){
				score+=2;
			}
			if(document.getElementById("5b").checked){
				score+=1;
			}
	}
	return score;
}

function disableCheck(){
	//("1a","1b","1c","2a","2b","2c","3a","4a","5a","5b");
	document.getElementById("1a").disabled=true;
	document.getElementById("1b").disabled=true;
	document.getElementById("1c").disabled=true;
	document.getElementById("2a").disabled=true;
	document.getElementById("2b").disabled=true;
	document.getElementById("2c").disabled=true;
	document.getElementById("3a").disabled=true;
	document.getElementById("4a").disabled=true;
	document.getElementById("5a").disabled=true;
	document.getElementById("5b").disabled=true;

}

function displayResult(){
	if(doSubmit()){
		if(scoreAssess()<=3){
			document.getElementById("result").innerHTML="Patient has low risk for future opioid abuse.";
			disableCheck();
		}
		else if(scoreAssess()<=7){
			//moderate
			document.getElementById("result").innerHTML="Patient has moderate risk for future opioid abuse.";
			disableCheck();
		}
		else{
			//high
			document.getElementById("result").innerHTML="Patient has high risk for future opioid abuse.";
			disableCheck();
		}
	}
}

